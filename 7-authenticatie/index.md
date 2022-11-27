# Authenticatie en autorisatie

## Inleiding

Authenticatie is bewijzen wie je bent, heel vaak met een gebruikersnaam en wachtwoord, en meer en meer in combinatie met TOTP (time based one time password), SMS en/of security keys als deel van two factor authentication (2FA).

Autorisatie is dan weer kijken of een gebruiker de juiste rechten heeft om toegang tot (een deel van) je webapplicatie te krijgen.

Zelf gebruikersnamen en wachtwoorden opslaan is niet triviaal, je kan niet zomaar een tabel maken waar je een wachtwoord en gebruikersnaam in opslaat, wachtwoorden moeten gehashed worden, met een salt om rainbow table attacks tegen te gaan.
Voor sommige toepassingen verwachten gebruikers dat ze via hun google of facebook account kunnen inloggen; soms vereist een platform zelfs dat je bepaalde inlogsystemen integreert (iOS en Apple login bijvoorbeeld).
Als je dan ook nog eens alles van 2FA wilt integreren besef je dat dit allemaal maken niet alleen niet triviaal is, maar ook best veel werk.

Daarom wordt er meer en meer gegrepen naar een third party service die deze taken op zich neemt, één zo'n service is Auth0.

### JWT

Het zou natuurlijk bijzonder onhandig zijn als je voor elke request opnieuw zou moeten inloggen, zeker bij moderne webapplicaties die vele requests gebruiken om één pagina op te bouwen. We moeten dus ergens kunnen 'onthouden' dat iemand ingelogd is, op een veilige manier.

Hiervoor kan je (o.a.) een JSON Web Token (JWT) gebruiken, dat is in se een (BASE64) string die bij elke request meegestuurd wordt in de `Authorization` header. Een JWT bestaat uit drie delen (zie een voorbeeld op <https://jwt.io>)

1. een deel met meta informatie over het token (hash algoritme)
2. een deel met de echte data, de payload (wie ingelogd is, wat de rechten zijn, wanneer de token vervalt, etc)
3. een hash signature waarmee kan gecontroleerd worden dat het een echte token is.

Het concept is als volgt: de server kan een signature (= handtekening) genereren voor een bepaalde payload. Deze signature wordt berekend o.b.v. een secret dat enkel door de server gekend is. Als iemand anders een token probeert te faken, zal de server dit altijd merken. Als een client correct inlogt, krijgt hij zo'n token van de server. Deze token moet bij elk request door de client meegestuurd worden (natuurlijk enkel waar authenticatie/autorisatie nodig is).

Als zo'n request met token binnenkomt, kan de server de signature opnieuw genereren. Als het overeenkomt met het origineel weet hij dat het token van hem afkomstig is en de payload dus geldig is (en dus de gebruiker is wij hij beweert te zijn).

Dat wil dus zeggen dat iedereen die zo'n token heeft effectief een ingelogde gebruiker is (je hoeft dus iemand zijn username en wachtwoord niet te kennen als je zijn token kan bemachtigen). Daarom vervallen tokens na een tijd, en zal de gebruiker opnieuw moeten inloggen.

## Auth0 opzetten

### PKCE

Er bestaan vele soorten flows om autorisatie af te dwingen. Aangezien alle code van een SPA in de browser te zien is, is gewoon een 'secret key' meegeven geen veilige optie. Tegenwoordig wordt vooral gebruikt gemaakt van **Proof Key for Code Exchange (PKCE)** voor native applicaties en SPA's.

Lees de [How it works](https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-proof-key-for-code-exchange-pkce#how-it-works) alvorens verder te gaan. (10min)

### Auth0

Auth0 is een bedrijf dat authenticatie en autorisatie makkelijk maakt, vooral als je meer wilt dan een simpele gebruikersnaam met een wachtwoord. Het is ook helemaal gratis tot 7000 actieve gebruikers. Er zijn heel veel opties en mogelijkheden, en het kan dus ook wel wat overweldigend overkomen. We overlopen hoe je Auth0 kan configureren voor een REST backend.

Er bestaan veel goede tutorials/libraries en voorbeeldapplicaties om Auth0 te doen werken met vele front- en backends. Er is, jammer genoeg, wel (nog) geen off-the-shelf oplossing voor Koa beschikbaar. Dus we puzzelen hier zelf alles samen.

We creëeren eerst een API. Open het menu-item `Applications` > `APIs` en klik op `Create API`. Hierbij is vooral de identifier belangrijk, deze kan je later niet meer wijzigen. Kies een unieke url. (neem hier iets dat altijd met `https://` begint, sommige packages die we later gebruiken werken anders niet altijd naar behoren, en de foutboodschappen zijn niet fantastisch)

![Create API](./images/new_api.png ':size=70%')

In de settings van deze API gaan we **Role-based Access Control (RBAC)** aanzetten, zodat we verschillende gebruikers verschillende toegangsrechten kunnen geven.

![RBAC settings](./images/rbac_settings.png ':size=70%')

Het uiteindelijke doel is dat de server toegang tot bepaalde REST routes gaat afschermen. M.a.w. de client zal inloggen bij Auth0, een token krijgen, en die dan meesturen met de headers van elke request. Onze server moet vervolgens kijken of deze token echt is, en op basis daarvan requests al dan niet blokkeren.

## Middleware om token te checken

### JWKS

(yups, qua afkortingen gebruik is 't nóg erger dan gemiddeld in de informatica)

Om de echtheid van een token na te gaan, maken we gebruik van public keys verkregen uit [JSON Web Key Sets (JWKS)](https://auth0.com/docs/secure/tokens/json-web-tokens/json-web-key-sets), hiervoor gebruiken we de [jwks-rsa](https://github.com/auth0/node-jwks-rsa) library

(goede uitleg over wat en hoe in deze [blogpost over JWKS](https://auth0.com/blog/navigating-rs256-and-jwks/))

```zsh
yarn add jwks-rsa
```

We voegen nu een bestand `auth.js` toe aan de `core` map:

```js
const jwksrsa = require('jwks-rsa');
const config = require('config');

function getJwtSecret() {
  try {
    let secretFunction = jwksrsa.koaJwtSecret({
      jwksUri: config.get('auth.jwksUri'), // 👈
      cache: true,
      cacheMaxEntries: 5,
  });
  return secretFunction;
 } catch (error) {
  console.error(error);
  throw error;
 }
}
```

De url met JWKS is altijd `{TENANT}/.well-known/jwks.json`. Zoals we ook met alle configuratie van de databank deden, voegen we de configuratie toe aan onze `.env`:

```.env
AUTH_JWKS_URI='https://pieter-hogent.eu.auth0.com/.well-known/jwks.json'
```

(uiteraard hebben jullie een andere tenant, niet gewoon copy-pasten)

En dan in de `custom-environment-variables.js`:

```js
// ...
  auth: {
    jwksUri: 'AUTH_JWKS_URI',
  },
// ...
```

### JWT middleware

Met behulp van deze secret genererende functie kunnen we dan een middleware inschakelen om JWT tokens te verifiëren, nl. [koa-jwt](https://github.com/koajs/jwt)

We voegen een functie toe aan de `core/auth.js` om deze middleware beschikbaar te maken.

```js
const jwt = require('koa-jwt');
const config = require('config');

function checkJwtToken() {
  try {
    let secretFunction = getJwtSecret();
    return jwt({
      secret: secretFunction,
      audience: config.get('auth.audience'),
      issuer: config.get('auth.issuer'),
      algorithms: ['RS256'],
      passthrough: true, // 👈 
    });
    // .unless({
    //   path: [], // whitelist urls
    // }),
  } catch (error) {
    logger.error(error);
    throw error;
  }
}

module.exports = {
 checkJwtToken,
};
```

Je kan deze middleware ofwel blocking maken ofwel `passthrough: true` aanzetten, zoals wij doen. Met deze optie gaat de middleware een `ctx.state.user` aanmaken met alle info als de token ok is, en deze gewoon op null zetten indien niet. We gaan dit dus zelf nog moeten checken (maar dit maakt wel dat we makkelijk kunnen kiezen om sommige routes wel, en andere niet toe te laten).

We dienen in de configuratie nu ook nog de audience en issuer mee te geven, issuer is jouw tenant, en audience de ID van je API:

```.env
AUTH_AUDIENCE='https://budget-transaction.pieter-hogent.com'
AUTH_ISSUER='https://pieter-hogent.eu.auth0.com/'
```

En deze dan ook weer beschikbaar maken via `custom-environment-variables`:

```js
 auth: {
    jwksUri: 'AUTH_JWKS_URI',
    audience: 'AUTH_AUDIENCE',
    issuer: 'AUTH_ISSUER',
  },
```

Deze middleware dienen we dan nog op te roepen voor elke request dus in de `createServer.js`, bijvoorbeeld net voor de bodyparser.
(zeker vóór de installRest, zodat we in de rest afhandeling kunnen checken of de user wel correct is ingelogd)

```js

  const logger = getLogger();
  
  app.use(checkJwtToken());

  app.use(bodyParser());

```

## User informatie

Als we de `ctx.state.user` loggen krijgen we zijn volledige token:

```js
{
  "iss":"https://pieter-hogent.eu.auth0.com/",
  "sub":"auth0|632ee656ee00e7cb2b01b9b4",
  "aud":["https://budget-transaction-api.com","https://pieter-hogent.eu.auth0.com/userinfo"],
  "iat":1668504331,
  "exp":1668590731,
  "azp":"ofivFlVa82eaD3TTQOMz345ppYFcoVEE",
  "scope":"openid profile email offline_access",
  "permissions":["read"]
}
```

De belangrijkste keys voor ons zijn de `permissions` en de `sub` (= Auth0 id), maar merk op dat we geen gebruikersnaam of e-mail of iets dergelijks hebben. Auth0 kan je deze informatie bezorgen via de userinfo-route, maar voor elke request naar onze API een request naar Auth0 uitvoeren is niet ideaal.

Dus we gaan als volgt te werk:

- `user` tabel aanpassen om ook een Auth0 Id op te slaan  
- als we de user nodig hebben, kijken of we via de Auth0 Id hem terug vinden in onze databank  
  - zo ja: alles ok  
  - zo nee: Auth0 userinfo request uitvoeren en onze databank aanvullen  

### Extra info opvragen

Met de token de juiste url aanspreken bij Auth0 is alles wat we moeten doen. We gebruiken axios om requests uit te voeren, dus dat voegen we eerst toe.

```zsh
yarn add axios
```

Dan vragen we de info op en voegen ze toe aan het `ctx.state.user` object dat al aanwezig was door de token de checken.

```js
const axios = require('axios');

const AUTH_USER_INFO = config.get('auth.userInfo');


async function addUserInfo(ctx) {
  const logger = getLogger();
  try {
    const token = ctx.headers.authorization;
    const url = AUTH_USER_INFO;
    if (token && url && ctx.user.state) {
      logger.debug(`addUserInfo: ${url}, ${JSON.stringify(token)}`);

      const userInfo = await axios.get(url, {
        headers: {
          Authorization: token,
        },
      });

      ctx.state.user = {
        ...ctx.state.user,
        ...userInfo.data,
      };
    }
  } catch (error) {
    logger.error(error);
    throw error;
  }
}
```

Met user info url weer toegevoegd aan het environment:

```.env
AUTH_USER_INFO='https://pieter-hogent.eu.auth0.com/userinfo'
```

En, dit kennen we ondertussen, ook aan de config:

```js
  auth: {
    jwksUri: 'AUTH_JWKS_URI',
    audience: 'AUTH_AUDIENCE',
    issuer: 'AUTH_ISSUER',
    userInfo: 'AUTH_USER_INFO',
  },
```

### User tabel aanpassen

We creëeren een nieuwe migrations file `202211151435_alterUserTable.js`:

```js
const {
  tables,
} = require('..');

module.exports = {
  up: async (knex) => {
    await knex.schema.alterTable(tables.user, (table) => {
      table.string('auth0id', 255)
        .notNullable();
    });
  },
  down: (knex) => {
    return knex.schema.dropTableIfExists(tables.user);
  },
};
```

Pas ook de user seed aan zodat er iets in de `auth0id` velden terecht komt.

### Repository en service uitbreiden

In de `repository/user.js` voegen we een extra functie toe `findByAuth0Id`:

```js
const findByAuth0Id = (auth0id) => {
  return getKnex()(tables.user)
    .where('auth0id', auth0id)
    .first();
};
```

Verder passen we ook de create en update aan om een `auth0id` parameter mee te krijgen
(dit zou moeten lukken zonder voorbeeldcode).

Dan passen we in de `service/user.js` de create functie aan:

```js
const register = ({
  name,
  auth0id,
}) => {
  debugLog('Creating a new user', {
    name,
  });
  return userRepository.create({
    name,
    auth0id,
  });
};
```

En dan voegen we hier een `getByAuth0Id` functie toe:

```js
const getByAuth0Id = async (auth0id) => {
  debugLog(`Fetching user with auth0id ${auth0id}`);
  const user = await userRepository.findByAuth0Id(auth0id);

  if (!user) {
    throw ServiceError.notFound(`No user with id ${auth0id} exists`, {
      auth0id,
    });
  }

  return user;
};
```

Als we nu een transactie toevoegen laten gebeuren door de 'huidige gebruiker' kunnen we dat als volgt bekomen.

In `rest/_transactions.js`:

```js
const createTransaction = async (ctx) => {
  let userId = 0;
  try {
    const user = await userService.getByAuth0Id(ctx.state.user.sub); // 👈 1
    userId = user.id;
  } catch (err) {
    await addUserInfo(ctx); // 👈 2
    userId = await userService.register({ // 👈 3
      auth0id: ctx.state.user.sub,
      name: ctx.state.user.name,
    });
  }

  const newTransaction = await transactionService.create({
    ...ctx.request.body,
    placeId: Number(ctx.request.body.placeId),
    date: new Date(ctx.request.body.date),
    userId, // 👈 4
  });
  ctx.body = newTransaction;
  ctx.status = 201;
};
createTransaction.validationScheme = {
  body: {
    amount: Joi.number().invalid(0),
    date: Joi.date().iso().less('now'),
    placeId: Joi.number().integer().positive(),
  }, // 👈 5
};
```

1) Als de user reeds gekend is, nemen we gewoon zijn id en is alles ok
2) Anders vragen we eerst de extra informatie op via onze net toegevoegd auth functie...
3) ...en registreren dan deze user in onze eigen tabel (zodat we de volgende keer de Auth0 call niet hoeven te doen)
4) bij het creëeren van een transactie hebben we nu een userId i.p.v. de user zelf
5) en dus ook bij de validatie dienen we de user niet langer te valideren (komt niet meer via de body)

## Roles bepalen en checken

### Rollen en permissies toevoegen

Bij Auth0 zelf dien je Roles aan te maken en deze dan aan users toe te kennen.

Voor onze applicatie creëren we een `boekhouder` (read) role en een `gebruiker` role (read & write):

![create role](./images/create_roles.png ':size=70%')

Gevolgd door het toewijzen van permissies aan deze rollen:

![assign permission](./images/assign_permission_to_role.png ':size=70%')

En dan wijzen we deze rollen toe aan onze gebruiker(s):

![assign role](./images/assign_roles_to_users.png ':size=70%')

(merk op: in se kan die ook via een Management API, zodat je er zelf ook een interface kan rond schrijven, dat is wel zeer goed gedocumenteerd dus laten we even als oefening)

### Permissies checken

De permissies zitten automatisch in de `permissions` key van het `ctx.state.user` object (als we RBAC hebben aangezet bij Auth0). Dus een middleware schrijven die deze permissies nakijkt is triviaal.

In `core/auth.js` voegen we het volgende toe.

```js

const permissions = Object.freeze({
  loggedIn: 'loggedIn',
  read: 'read',
  write: 'write',
});

function hasPermission(permission) {
  return async (ctx, next) => {
    const logger = getLogger();
    const user = ctx.state.user;
    logger.debug(`hasPermission: ${JSON.stringify(user)}`);

    // simply having a user object means they are logged in
    if (user && permission === permissions.loggedIn) {  // 👈
      await next();
    } else if (user && user.permissions && user.permissions.includes(permission)) {
      await next();
    } else {
      ctx.throw(403, 'Forbidden');
    }
  };
}
```

We hebben geen expliciete 'is logged in' permissie voorzien, gewoon een geldig token (en dus geldig `ctx.state.user` object) wilt zeggen dat we ingelogd zijn.

Deze `hasPermission` kunnen we dan gewoon toevoegen aan de REST routes. Dit doe je best voor de validatie (als we toch niet verder mogen, heeft valideren ook geen zin).

Bijvoorbeeld bij `rest/_transactions.js`:

```js
module.exports = (app) => {
  const router = new Router({
    prefix: '/transactions',
  });

  router.get('/', hasPermission(permissions.read), validate(getAllTransactions.validationScheme), getAllTransactions);
  router.post('/', hasPermission(permissions.write), validate(createTransaction.validationScheme), createTransaction);
  router.get('/:id', hasPermission(permissions.read), validate(getTransactionById.validationScheme), getTransactionById);
  router.put('/:id', hasPermission(permissions.write), validate(updateTransaction.validationScheme), updateTransaction);
  router.delete('/:id', hasPermission(permissions.write), validate(deleteTransaction.validationScheme), deleteTransaction);

  app.use(router.routes()).use(router.allowedMethods());
};
```

Alle andere routes aanpassen laten we als oefening.
