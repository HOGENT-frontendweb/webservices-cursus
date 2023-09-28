# Authenticatie en autorisatie

> **Startpunt voorbeeldapplicatie**
>
> Het volstaat om uit te checken op de `main` branch
>
> ```bash
> git clone https://github.com/HOGENT-Web/webservices-budget.git
> cd webservices-budget
> git checkout -b les7
> yarn install
> yarn start
> ```

## JWT

- [JSON Web Token (JWT)](https://jwt.io/introduction)
- open standaard
- wordt typisch gebruikt om sessie-informatie door te geven tussen client-server, bv. welke gebruiker aangemeld is, welke rollen/permissies die heeft, hoe lang hij aangemeld mag blijven, ...
- een JWT bevat deze gegevens in plain text
- de inhoud van een JWT kan je bekijken op [jwt.io](https://jwt.io)
- wordt per request doorgestuurd in de `Authorization` header met als prefix **"Bearer "**
- als een JWT alle sessie-info als plain text bevat, kan ik die wijzigen? ja, je kan dit wijzigen
- kan ik mij dan voordoen als iemand anders? nee, normaal niet

### JWT: structuur

Dit is een voorbeeld van een JWT:

`eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c`

een JWT bestaat uit 3 delen:

- header
- payload
- signature

Deze drie delen worden gescheiden door een punt en staan in `base64url` encodering

### JWT: header

Dit bestaat gewoonlijk uit twee delen:

- `type`: het type van token, in dit geval JWT
- `signing algorithm`: het algoritme gebruikt om de token te ondertekenen. bv. HMAC SHA256, RSA

Je kan de header gewoon van `base64url` naar plain text omvormen. Met het voorbeeld geeft dit:

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### JWT: payload

Dit bevat de sessie-info of zogenaamde claims. Er zijn enkele voorgedefinieerde claims, zoals

- `iss`: wie de token uitgaf
- `exp`: vervaldatum
- `sub`: waarvoor deze token dient (bv. authenticatie, password reset)
- `iat`: issued at time
- ...
- Je kan ook eigen properties toevoegen:
  - e-mailadres van de aangemelde gebruiker
  - naam van de aangemelde gebruiker
  - ...

Het token uit het voorbeeld bevat volgende payload:

```json
{
  "sub": "1234567890",
  "name": "John Doe",
  "iat": 1516239022
}
```

### JWT: signature

- de signature is wat een JWT veilig maakt
- het neemt de info uit de header, samen met een `secret` om zo de payload te ondertekenen
- niet meer dan een handtekening die aangeeft of de payload gewijzigd is
- als iemand de payload wijzigt, zal de signature anders zijn en wordt de token ongeldig beschouwd

## Wachtwoorden opslaan

We moeten onze wachtwoorden opslaan in de databank. We doen dit uiteraard niet in plain text. We `hashen` de wachtwoorden met [argon2](https://github.com/P-H-C/phc-winner-argon2). Dit is een van de nieuwste en beste hashing algoritmes voor o.a. wachtwoorden.

### Hashing: herhaling

- een hashing algoritme is een one-way algoritme
- het neemt een input en vormt deze om naar een output met een vast aantal bits
- als de input wijzigt, moet de output significant en willekeurig genoeg wijzigen
- zo kan je de bewerking niet omgekeerd doen en achterhalen wat de input was
- dit is wat we willen om wachtwoorden op te slaan

### Hashing: salt

- sommige hashing algoritmes gebruiken een **salt**
- dit is een willekeurig string (met vaste lengte)
- wordt gebruikt om een verschillende hash te genereren bij identieke input
- dus: hetzelfde wachtwoord hashen met een andere salt, geeft een andere hash
- dit maakt bv. dictionary attacks moeilijker

### Voorbeeld: helpers voor hashing

We gebruiken het package `argon2` om het `argon2` algoritme te gebruiken in NodeJS

```bash
yarn add argon2
```

### Voorbeeld: configuratie hashing

We voegen wat configuratie toe voor argon2.

`config/development.js`

```js
module.exports = {
  auth: {
    argon: {
      saltLength: 16,
      hashLength: 32,
      timeCost: 6,
      memoryCost: 2 ** 17,
    },
  },
};
```

- `saltLength`: we kiezen een salt van 16 bytes (128 bits)
- `hasLength`: onze hash moet 32 bytes groot zijn (256 bits)
- `timeCost`: we laten het hashing algoritme 6 iteraties uitvoeren
- `memoryCost`: elke thread van het algoritme mag 128MiB gebruiken

De laatste twee opties bepalen de duur van de hashing: hoe groter deze getallen, hoe langer het duurt. Langer is altijd beter, maar je applicatie moet nog bruikbaar blijven.

### Voorbeeld: helpers voor hashing

We definiëren een module met een aantal helpers om een wachtwoord te hashen/controlen.

`src/core/password.js`

```js
const config = require('config'); // 👈 1
const argon2 = require('argon2'); // 👈 2

const ARGON_SALT_LENGTH = config.get('auth.argon.saltLength'); // 👈 1
const ARGON_HASH_LENGTH = config.get('auth.argon.hashLength'); // 👈 1
const ARGON_TIME_COST = config.get('auth.argon.timeCost'); // 👈 1
const ARGON_MEMORY_COST = config.get('auth.argon.memoryCost'); // 👈 1

// 👈 3
const hashPassword = async (password) => {
  const passwordHash = await argon2.hash(password, {
    type: argon2.argon2id,
    saltLength: ARGON_SALT_LENGTH,
    hashLength: ARGON_HASH_LENGTH,
    timeCost: ARGON_TIME_COST,
    memoryCost: ARGON_MEMORY_COST,
  }); // 👈 4

  return passwordHash;
};

// 👈 3
const verifyPassword = async (password, passwordHash) => {
  const valid = await argon2.verify(passwordHash, password, {
    type: argon2.argon2id,
    saltLength: ARGON_SALT_LENGTH,
    hashLength: ARGON_HASH_LENGTH,
    timeCost: ARGON_TIME_COST,
    memoryCost: ARGON_MEMORY_COST,
  }); // 👈 5

  return valid;
};

module.exports = {
  hashPassword,
  verifyPassword,
}; // 👈 3
```

1. Importeer alle gedefinieerde configuratie.
2. Importeer het argon2 package.
3. Definieer twee helperfuncties om een wachtwoord te hashen en om te checken of een gegeven wachtwoord gelijk dezelfde hash oplevert. Wachtwoorden vergelijken kan enkel door te checken of ze dezelfde hash opleveren. Exporteer de functies.
4. De argon2 library exporteert een `hash`-functie om een gegeven string te hashen. Het verwacht de string als eerste argument en wat opties als tweede argument. We geven onze configuratie mee aan de juiste optie. We kiezen de `argon2id` versie van het algoritme (resistent tegen GPU en tradeoff attacks).
5. De argon2 library exporteert een `verify`-functie om te checken of een gegeven string dezelfde hash oplevert. We geven opnieuw alle configuratie mee.

### DIY: helpers voor hashing

Kopieer deze code in een `src/testpw.js` bestand en test zelf of jouw code werkt! Speel een beetje met de configuratie en bekijk de invloed op de uitvoeringstijd van het algoritme.

Om de code uit te voeren: `node src/testpw.js`

`src/testpw.js`

```js
const { hashPassword, verifyPassword } = require('./core/password');

async function main() {
  const password = 'verydifficult';
  const wrongPassword = 'verywrong';
  console.log('The password:', password);

  const hash = await hashPassword(password);
  // bekijk hoe de hash opgebouwd is, wat herken je?
  // waar staat de timeCost, memoryCost, salt en de hash zelf?
  console.log('The hash:', hash);

  let valid = await verifyPassword(password, hash);
  console.log('The password', password, 'is', valid ? 'valid' : 'incorrect');

  valid = await verifyPassword(wrongPassword, hash);
  console.log(
    'The password',
    wrongPassword,
    'is',
    valid ? 'valid' : 'incorrect'
  );
}

main();
```

## Voorbeeld: wachtwoord opslaan

Om te kunnen aanmelden, moeten we extra informatie van onze gebruikers opslaan: o.a. een e-mailadres en een wachtwoord. Om deze extra informatie in onze databank toe te voegen, maken we een nieuwe **migratie**.

`src/data/migrations/202309141600_addAuthInfoToUserTable.js`

```js
const { tables } = require('..');

module.exports = {
  up: async (knex) => {
    await knex.schema.alterTable(tables.user, (table) => {
      // 👈 1
      table.string('email').notNullable(); // 👈 2

      table.string('password_hash').notNullable(); // 👈 2

      table.jsonb('roles').notNullable(); // 👈 2

      table.unique('email', 'idx_user_email_unique'); // 👈 3
    });
  },
  down: (knex) => {
    return knex.schema.alterTable(tables.user, (table) => {
      table.dropColumns('email', 'password_hash', 'roles');
    }); // 👈 4
  },
};
```

1. We wijzigen dus de `users` tabel.
2. We voegen drie nieuwe kolommen toe: een `e-mailadres` een `gehashed wachtwoord` en de `rollen` van de gebruiker. Merk op: we slaan de rollen op als JSON, dit moeten we dus opvangen in de repository. De rollen gebruiken we straks voor de autorisatie.
3. We geven deze index een naam voor beter error handling (zie later).
4. In de down-functie verwijderen we de aangemaakte kolommen.

Pas de **seed** voor `users` aan met deze code. Deze seed stelt voor elke user het wachtwoord `12345678` in. Als rollen kunnen `user` en/of `admin` worden toegekend.

`sr/data/seeds/202309150900_users.js`

```js
const { tables } = require('..');

module.exports = {
  seed: async (knex) => {
    // first delete all entries
    await knex(tables.user).delete();

    // then add the fresh users (all passwords are 12345678)
    await knex(tables.user).insert([
      {
        id: 1,
        name: 'Thomas Aelbrecht',
        email: 'thomas.aelbrecht@hogent.be',
        password_hash:
          '$argon2id$v=19$m=131072,t=6,p=1$9AMcua9h7va8aUQSEgH/TA$TUFuJ6VPngyGThMBVo3ONOZ5xYfee9J1eNMcA5bSpq4',
        roles: JSON.stringify(['user', 'admin']),
      },
      {
        id: 2,
        name: 'Pieter Van Der Helst',
        email: 'pieter.vanderhelst@hogent.be',
        password_hash:
          '$argon2id$v=19$m=131072,t=6,p=1$9AMcua9h7va8aUQSEgH/TA$TUFuJ6VPngyGThMBVo3ONOZ5xYfee9J1eNMcA5bSpq4',
        roles: JSON.stringify(['user']),
      },
      {
        id: 3,
        name: 'Karine Samyn',
        email: 'karine.samyn@hogent.be',
        password_hash:
          '$argon2id$v=19$m=131072,t=6,p=1$9AMcua9h7va8aUQSEgH/TA$TUFuJ6VPngyGThMBVo3ONOZ5xYfee9J1eNMcA5bSpq4',
        roles: JSON.stringify(['user']),
      },
    ]);
  },
};
```

De extra kolommen hebben als gevolg dat de **user repository** nu ook een `e-mailadres` en `password hash` en `rollen` verwacht als parameter bij `create`.

`src/repository/user.js`

```js
// ...
const create = async ({
  name,
  email, // 👈 1
  passwordHash, // 👈 1
  roles, // 👈 3
}) => {
  const [id] = await getKnex()(tables.user).insert({
    id,
    name,
    email, // 👈 2
    password_hash: passwordHash, // 👈 2
    roles: JSON.stringify(roles), // 👈 4
  });
  return id;
};
// ...
```

1. E-mailadres, password hash voegen we toe als parameter bij create
2. Deze geven we dan ook mee aan onze insert
3. We voegen ook een extra parameter roles toe
4. Deze rollen moeten we dan omzetten naar JSON alvorens we ze opslaan in de databank (zie migratie). Bij het ophalen wordt deze kolom automatisch geparsed voor ons, m.a.w. we krijgen een array.

**Oefening**: pas ook de andere methodes aan waar nodig.

Ook in de **user service** komen deze extra kolommen mee als parameter. Let wel op: hier komt het wachtwoord nog als plain text binnen!

`src/service/user.js`

```js
// ...
const register = async ({
  name,
  email, // 👈 1
  password, // 👈 1
}) => {
  const passwordHash = await hashPassword(password); // 👈 2

  const userId = await userRepository
    .create({
      name,
      email, // 👈 2
      passwordHash, // 👈 2
      roles: ['user'], // 👈 3
    })
    .catch(handleDBError);

  const user = await userRepository.findById(userId);

  return await makeLoginData(user);
};
// ...
```

1. We voegen email en wachtwoord toe
2. We hashen het wachtwoord in de service-laag en geven het email en hashed wachtwoord door aan de repository
3. De rollen geven we als array mee. De repository zet deze voor ons om naar JSON

**Oefening**:

- pas ook de andere methodes aan waar nodig
- pas **user rest** aan waar nodig

## Voorbeeld: helpers voor JWT

We gebruiken het package [jsonwebtoken](https://www.npmjs.com/package/jsonwebtoken) om JWT's te signen en verifiëren

```bash
yarn add jsonwebtoken
```

We voegen wat configuratie toe voor jsonwebtoken

`config/development.js`

```js
module.exports = {
  auth: {
    jwt: {
      secret:
        'eenveeltemoeilijksecretdatniemandooitzalradenandersisdesitegehacked',
      expirationInterval: 60 * 60 * 1000, // ms (1 hour)
      issuer: 'budget.hogent.be',
      audience: 'budget.hogent.be',
    },
  },
};
```

- `secret`: we definiëren het secret waarmee de payload ondertekend zal worden.
- `experationInterval`: onze JWT's zullen in development verlopen na 1 uur, in productie zet je dit typisch langer. Dit hangt ook af van het type applicatie, bv. nooit heel lang bij een bankapplicatie. Je hanteert best één standaard voor tijdseenheden in je configuratie, wij kozen voor milliseconden. Het kan handig zijn om een human readable tijdseenheid in commentaar te zetten.
- We definiëren wie de JWT uitgeeft (`issuer`) en wie hem mag accepteren (`audience`).

We definiëren een module met een aantal helpers om een JWT te maken/controleren.

`src/core/jwt.js`

```js
const config = require('config'); // 👈 1
const jwt = require('jsonwebtoken'); // 👈 2

const JWT_AUDIENCE = config.get('auth.jwt.audience'); // 👈 1
const JWT_SECRET = config.get('auth.jwt.secret'); // 👈 1
const JWT_ISSUER = config.get('auth.jwt.issuer'); // 👈 1
const JWT_EXPIRATION_INTERVAL = config.get('auth.jwt.expirationInterval'); // 👈 1

// 👈 3
const generateJWT = (user) => {
  const tokenData = {
    userId: user.id,
    roles: user.roles,
  }; // 👈 4

  const signOptions = {
    expiresIn: Math.floor(JWT_EXPIRATION_INTERVAL / 1000),
    audience: JWT_AUDIENCE,
    issuer: JWT_ISSUER,
    subject: 'auth',
  }; // 👈 5

  return new Promise((resolve, reject) => {
    jwt.sign(tokenData, JWT_SECRET, signOptions, (err, token) => {
      if (err) {
        console.log('Error while signing new token:', err.message);
        return reject(err);
      }
      return resolve(token);
    });
  }); // 👈 6
};
module.exports = {
  generateJWT,
}; // 👈 3
```

1. Importeer alle gedefinieerde configuratie
2. Importeer het jsonwebtoken package
3. Definieer een helper `generateJWT` om een JWT te maken. Deze krijgt een gebruiker mee als argument
4. We geven deze twee properties mee als JWT payload. Je moet deze verplicht apart definiëren
5. Daarnaast definiëren we enkele properties nodig voor het ondertekenen van de JWT

   - `expiresIn`: hoelang deze token geldig is. Merk op: `expiresIn` staat in seconden en onze configuratie rekent met milliseconden, daarom moeten we dit omvormen.
   - `audience`: welke servers de token mogen accepteren
   - `issuer`: welke server(s) de token uitgeven
   - `subject`: waarvoor deze token dient, in dit geval voor authenticatie (auth)

6. We retourneren een `Promise` die zal resolven als de JWT ondertekend is. We moeten de `sign`-functie wrappen in een `Promise` aangezien deze werkt o.b.v. callbacks om asynchroon te zijn. Maar dit werkt niet makkelijk. De `sign`-functie neemt de JWT payload (`tokenData`), het secret en de sign opties als argument en als laatste argument verwacht deze een callback die opgeroepen zal worden als de token ondertekend is of als er iets fout liep. In deze callback resolven of rejecten we de `Promise` indien nodig.

We definiëren nog een tweede helper `verifyJWT` die een gegeven JWT zal controleren op geldigheid. Mogelijke problemen:

- JWT is verlopen
- er is geprutst aan de payload
- JWT is niet bedoeld voor deze server
- ...

`src/core/jwt.js`

```js
// ...
const verifyJWT = (authToken) => {
  const verifyOptions = {
    audience: JWT_AUDIENCE,
    issuer: JWT_ISSUER,
    subject: 'auth',
  }; // 👈 1

  return new Promise((resolve, reject) => {
    jwt.verify(authToken, JWT_SECRET, verifyOptions, (err, decodedToken) => {
      if (err || !decodedToken) {
        console.log('Error while verifying token:', err.message);
        return reject(err || new Error('Token could not be parsed'));
      }
      return resolve(decodedToken);
    });
  }); // 👈 2
};

module.exports = {
  generateJWT,
  verifyJWT,
};
```

1. We geven opnieuw de informatie mee die we verwachten in de token
2. Omdat `jwt.verify` ook met een callback werkt, moeten we deze wrappen in een Promise. `jwt.verify` verwacht de JWT, het secret en de opties als argumenten. Als laatste argument volgt een callback die opgeroepen zal worden als de token gecontroleerd is. In deze callback resolven of rejecten we de Promise indien nodig.

Kopieer onderstaande code in een `src/testjwt.js` bestand en test zelf of jouw code werkt!

Uitvoeren: `node src/testjwt.js`

`src/testjwt.js`

```js
const { generateJWT, verifyJWT } = require('./core/jwt');

function messWithPayload(jwt) {
  const [header, payload, signature] = jwt.split('.');
  const parsedPayload = JSON.parse(
    Buffer.from(payload, 'base64url').toString()
  );

  // make me admin please ^^
  parsedPayload.roles.push('admin');

  const newPayload = Buffer.from(
    JSON.stringify(parsedPayload),
    'ascii'
  ).toString('base64url');
  return [header, newPayload, signature].join('.');
}

async function main() {
  const fakeUser = {
    id: 1,
    firstName: 'Thomas',
    lastName: 'Aelbrecht',
    email: 'thomas.aelbrecht@hogent.be',
    roles: ['user'],
  };

  const jwt = await generateJWT(fakeUser);
  // copy and paste the JWT in the textfield on https://jwt.io
  // inspect the content
  console.log('The JWT:', jwt);

  let valid = await verifyJWT(jwt);
  console.log('This JWT is', valid ? 'valid' : 'incorrect');

  // Let's mess with the payload
  const messedUpJwt = messWithPayload(jwt);
  console.log('Messed up JWT:', messedUpJwt);

  console.log('Verifying this JWT will throw an error:');
  valid = await verifyJWT(messedUpJwt);
}

main();
```

## Voorbeeld: aanmelden

We definiëren alle rollen in onze applicatie in een constant object. Zo is het eenvoudig om ze te wijzigen indien nodig.

`src/core/roles.js`

```js
module.exports = Object.freeze({
  USER: 'user',
  ADMIN: 'admin',
});
```

We updaten de **seed voor users** met deze nieuwe rollen

`src/data/seed/202309150900_users.js`

```js
const { tables } = require('..');
const Role = require('../../core/roles'); // 👈

module.exports = {
  seed: async (knex) => {
    // first delete all entries
    await knex(tables.user).delete();

    // then add the fresh users (all passwords are 12345678)
    await knex(tables.user).insert([
      {
        id: '7f28c5f9-d711-4cd6-ac15-d13d71abff80',
        name: 'Thomas Aelbrecht',
        email: 'thomas.aelbrecht@hogent.be',
        password_hash:
          '$argon2id$v=19$m=131072,t=6,p=1$9AMcua9h7va8aUQSEgH/TA$TUFuJ6VPngyGThMBVo3ONOZ5xYfee9J1eNMcA5bSpq4',
        roles: JSON.stringify([Role.ADMIN, Role.USER]), // 👈
      },
      {
        id: '7f28c5f9-d711-4cd6-ac15-d13d71abff81',
        name: 'Pieter Van Der Helst',
        email: 'pieter.vanderhelst@hogent.be',
        password_hash:
          '$argon2id$v=19$m=131072,t=6,p=1$9AMcua9h7va8aUQSEgH/TA$TUFuJ6VPngyGThMBVo3ONOZ5xYfee9J1eNMcA5bSpq4',
        roles: JSON.stringify([Role.USER]), // 👈
      },
      {
        id: '7f28c5f9-d711-4cd6-ac15-d13d71abff82',
        name: 'Karine Samyn',
        email: 'karine.samyn@hogent.be',
        password_hash:
          '$argon2id$v=19$m=131072,t=6,p=1$9AMcua9h7va8aUQSEgH/TA$TUFuJ6VPngyGThMBVo3ONOZ5xYfee9J1eNMcA5bSpq4',
        roles: JSON.stringify([Role.USER]), // 👈
      },
    ]);
  },
};
```

We passen **ServiceError** aan. Mogelijke fouten zijn

- unauthorized: authenticatie faalt
- forbidden: autorisatie faalt

`core/serviceError.js`

```js
const UNAUTHORIZED = 'UNAUTHORIZED'; // 👈 1
const FORBIDDEN = 'FORBIDDEN'; // 👈 1

class ServiceError extends Error {
  //..

  static unauthorized(message, details) {
    return new ServiceError(UNAUTHORIZED, message, details);
  } // 👈 2

  static forbidden(message, details) {
    return new ServiceError(FORBIDDEN, message, details);
  } // 👈 2

  //..
  get isUnauthorized() {
    return this.code === UNAUTHORIZED;
  } // 👈 3

  get isForbidden() {
    return this.code === FORBIDDEN;
  } // 👈 3
}

module.exports = ServiceError;
```

1. Voeg de constanten toe
2. Voorzie de static methods
3. Voorzie de getters

In de **middleware voor het afhandelen van de ServiceError** voegen we de afhandeling van `isUnauthorized` en `isForbidden` toe

`core/installMiddlewares.js`

```js
//...
if (error instanceof ServiceError) {
  //...

  if (error.isUnauthorized) {
    statusCode = 401;
  }

  if (error.isForbidden) {
    statusCode = 403;
  }
}
//...
```

Pas in de **user service** ook de hard gecodeerde rol aan bij `register`.

We voegen een functie toe die een gebruiker met een bepaald e-mailadres ophaalt.

`src/repository/user.js`

```js
// ...
const findByEmail = (email) => {
  return getKnex()(tables.user).where('email', email).first();
}; // 👈 1

module.exports = {
  // ...
  findByEmail, // 👈2
};
```

1. Daarvoor schrijven we deze query. We kunnen veilig `first()` gebruiken aangezien er een UNIQUE index staat op de kolom `email`.
2. Vergeet deze functie dan ook niet te exporteren

We definiëren een functie `login` die een gebruiker met een bepaald e-mailadres probeert aan te melden. Als de gebruiker is aangemeld retourneren we het token en de publieke informatie van de gebruiker (id, name, email en rollen)

`src/service/user.js`

```js
// ...
const { verifyPassword } = require('../core/password'); // 👈 4
const { generateJWT } = require('../core/jwt'); // 👈 7
// 👈 8
const makeExposedUser = ({ id, name, email, roles }) => ({
  id,
  name,
  email,
  roles,
});

// 👈 6
const makeLoginData = async (user) => {
  const token = await generateJWT(user); // 👈 7
  return {
    user: makeExposedUser(user),
    token,
  }; // 👈 8
};

// 👈 1
const login = async (email, password) => {
  const user = await userRepository.findByEmail(email); // 👈 2

  if (!user) {
    // DO NOT expose we don't know the user
    throw ServiceError.unauthorized(
      'The given email and password do not match'
    );
  } // 👈 3

  const passwordValid = await verifyPassword(password, user.password_hash); // 👈 4

  if (!passwordValid) {
    // DO NOT expose we know the user but an invalid password was given
    throw ServiceError.unauthorized(
      'The given email and password do not match'
    );
  } // 👈 5

  return await makeLoginData(user); // 👈 6
};

module.exports = {
  // ...
  login, // 👈 9
};
```

1. De functie `login` krijgt een e-mailadres en wachtwoord als parameter
2. We kijken eerst of er een gebruiker met dit e-mailadres is
3. Als die gebruiker niet bestaat, doen we alsof het e-mailadres en wachtwoord niet matchen. We willen niet laten blijken dat we de gebruiker kennen.
4. Als we een gebruiker hebben, verifiëren we het opgegeven wachtwoord met de opgeslagen hash
5. Als het wachtwoord fout is, doen we weer alsof we de gebruiker niet kennen
6. Vervolgens maken we de data die geretourneerd moet worden na login. We maken hiervoor een helperfunctie aangezien we die data ook nodig hebben bij het registreren.
7. Eerst maken we een JWT voor die gebruiker
8. Vervolgens retourneren we de token en enkel de velden van de user die publiek zijn. Voor dit laatste maken we opnieuw een helperfunctie (we hebben deze nog nodig bij bv. `findById`)
9. Vergeet ook deze functie niet te exporteren

**Oefening**: pas ook de overige methodes aan

- register retourneert het token en de publieke user data
- getAll, ... retourneren de publieke user data (dus zeker geen wachtwoorden!)

Vervolgens passen we de **rest module** voor alle routes m.b.t. de gebruikers aan.

`src/rest/user.js`

```js
//..

// 👈 1
const login = async (ctx) => {
  const { email, password } = ctx.request.body; // 👈 2
  const token = await userService.login(email, password); // 👈 3
  ctx.status = 200; // 👈 4
  ctx.body = token; // 👈 4
};
login.validationScheme = {
  body: {
    email: Joi.string().email(),
    password: Joi.string(),
  },
}; // 👈 5

module.exports = function installUsersRoutes(app) {
  const router = new Router({
    prefix: '/users',
  });
  //..
  router.post('/login', validate(login.validationScheme), login); // 👈 6
  //..
};
```

1. We definiëren een functie voor onze `aanmeld`-route
2. We halen het e-mailadres en wachtwoord uit de HTTP body
3. We proberen de gebruiker aan te melden
4. Als dat gelukt is, geven we de token-informatie mee in de HTTP response body en geven we een status code 200
5. We valideren de input
6. We geven deze functie mee aan de POST op `/login`

## Voorbeeld: registreren

We overlopen hier nog eens de belangrijkste code van her registreer proces.

`src/service/user.js`

```js
// ...
const { verifyPassword, hashPassword } = require('../core/password'); // 👈 2
const Role = require('../core/roles'); // 👈 3

const register = async ({
  name,
  email, // 👈 1
  password, // 👈 1
}) => {
  const passwordHash = await hashPassword(password); // 👈 2

  const userId = await userRepository.create({
    name,
    email,
    passwordHash,
    roles: [Role.USER],
  }); // 👈 3

  const user = await userRepository.findById(userId); // 👈 4

  return await makeLoginData(user); // 👈 5
};
```

1. We geven nu ook een e-mailadres en wachtwoord mee als we een nieuwe gebruiker toevoegen
2. Hierbij moeten we eerst het wachtwoord hashen
3. Vervolgens maken we de gebruiker met deze gegevens. We maken elke nieuwe gebruiker standaard enkel `USER`
4. Vervolgens halen we de zojuist gecrëerde gebruiker op
5. Dan maken we voor deze gebruiker ook token-informatie en de publieke user info aan. Zo is een geregistreerde gebruiker meteen aangemeld.

We bekijken ook nog eens de `request handler` voor het registreren.

`src/rest/_user.js`

```js
const register = async (ctx) => {
  const token = await userService.register(ctx.request.body); // 👈 1
  ctx.body = token; // 👈 2
  ctx.status = 200; // 👈 2
};
register.validationScheme = {
  body: {
    name: Joi.string().max(255),
    email: Joi.string().email(),
    password: Joi.string().min(8).max(30),
  },
}; // 👈 3

module.exports = function installUsersRoutes(app) {
  // ...
  router.post('/register', validate(register.validationScheme), register); // 👈 4
  // ...
};
```

1. We registreren de nieuwe gebruiker (alle informatie zit in de HTTP body). We krijgen de token-informatie terug
2. We retourneren deze token-informatie in de HTTP response body, evenals een statuscode 200.
3. We definiëren de validatie van de input
4. We geven deze functie mee aan de POST op `/register`

## Voorbeeld: helpers voor authenticatie/autorisatie

We definiëren **een module die twee helpers** exporteert. Beide helpers zijn **middlewares** voor Koa.

- de eerste helper dwingt af dat de gebruiker moet aangemeld zijn om een endpoint uit te voeren
- de tweede helper dwingt af dat de gebruiker de juiste rollen heeft om een endpoint uit te voeren

`src/core/auth.js`

```js
const userService = require('../service/user');

// 👈 1
const requireAuthentication = async (ctx, next) => {
  const { authorization } = ctx.headers; // 👈 3

  const { authToken, ...session } = await userService.checkAndParseSession(
    authorization
  ); // 👈 4

  ctx.state.session = session; // 👈 5
  ctx.state.authToken = authToken; // 👈 6

  return next(); // 👈 7
};

// 👈 2
const makeRequireRole = (role) => async (ctx, next) => {
  const { roles = [] } = ctx.state.session; // 👈 8

  userService.checkRole(role, roles); // 👈 9
  return next(); // 👈 10
};

module.exports = {
  requireAuthentication, // 👈 1
  makeRequireRole, // 👈 2
};
```

1. Een eerste helper dwingt af om aangemeld te zijn (**authenticatie**)
2. Een andere helper die een middleware opmaakt die een bepaalde rol afdwingt (**autorisatie**)
3. We halen de `Authorization` header op
4. We laten de user service deze token verifiëren en parsen, en verwachten sessie-informatie terug. We implementeren deze functie later
5. We slaan de sessie-informatie op in de `state` van de huidige `context`. In de `ctx.state` kan je bijhouden wat je wil
6. We slaan ook de JWT op in `ctx.state`
7. We roepen de volgende middleware in de rij aan
8. We halen de rollen uit de sessie-informatie. Merk op: deze middleware vereist dat de `requireAuthentication` middleware reeds uitgevoerd is, let dus op de volgorde!!!
9. We laten de user service checken of de aangemelde gebruiker de vereiste rol heeft. We implementeren deze functie ook later
10. Als laatste roepen we ook de volgende middleware in de rij aan

We definiëren een eerste **functie om een JWT te verifiëren en te parsen**.

`src/service/user.js`

```js
const config = require('config'); // 👈 7
const { getLogger } = require('../core/logging'); // 👈 4
const { generateJWT, verifyJWT } = require('../core/jwt'); // 👈 5

const AUTH_DISABLED = config.get('auth.disabled'); // 👈 7

const checkAndParseSession = async (authHeader) => {
  // Allow any user if authentication/authorization is disabled
  // DO NOT use this config parameter in any production worthy application!
  if (AUTH_DISABLED) {
    // Create a session for user Thomas Aelbrecht
    return {
      userId: 1,
      roles: [Role.USER],
    };
  } // 👈 7

  if (!authHeader) {
    throw ServiceError.unauthorized('You need to be signed in');
  } // 👈 1

  if (!authHeader.startsWith('Bearer ')) {
    throw ServiceError.unauthorized('Invalid authentication token');
  } // 👈 2

  const authToken = authHeader.substr(7); // 👈 3
  try {
    const { roles, userId } = await verifyJWT(authToken); // 👈 5

    return {
      userId,
      roles,
      authToken,
    }; // 👈 6
  } catch (error) {
    getLogger().error(error.message, { error });
    throw new Error(error.message);
  } // 👈 4
};
```

1. Als er geen header meegegeven werd aan het request, gooien we een fout.
2. Indien de header niet start met "Bearer " gooien we ook een fout, dit moet zo per definitie.
3. Vervolgens verwijderen we de "Bearer " van de token, zo hebben we enkel de JWT over.
4. We wrappen alles in een try-catch om de fouten nog eens afzonderlijk te loggen. Alle fouten die gegooid worden hebben te maken met de geldigheid van de JWT (verlopen, ongeldig signature...)
5. We verifiëren de JWT. Als deze geldig is, dan krijgen we de payload van de token terug.
6. Als laatste retourneren we alle sessie-informatie, alsook de token
7. Opdat de applicatie ook zou runnen als de authenticatie disabled is... Maak de nodige aanpassing in de configs.

De laatste **functie** in de `user service` zal **checken of een gegeven rol in de array van rollen voorkomt**. De array bevat alle rollen van de grebuiker (uit de JWT payload gehaald).

`src/service/user.js`

```js
const checkRole = (role, roles) => {
  if (AUTH_DISABLED) {
    return;
  } // 👈 3

  const hasPermission = roles.includes(role); // 👈 1

  if (!hasPermission) {
    throw ServiceError.forbidden(
      'You are not allowed to view this part of the application'
    ); // 👈 2
  }
};
```

1. Met de functie includes kunnen we controleren of de rol voorkomt in de array
2. Als de rol niet in de array zit, wordt een Forbidden fout geworpen, die zal worden afgehandeld door de middleware
3. Als authenticatie disabled is,...

**Hoe gebruiken we deze middlewares nu?**

`src/rest/user/js`

```js
const { requireAuthentication, makeRequireRole } = require('../core/auth'); // 👈 2
const Role = require('../core/roles'); // 👈 4
// ...

module.exports = function installUsersRoutes(app) {
  const router = new Router({
    prefix: '/users',
  });

  // Public routes
  router.post('/login', validate(login.validationScheme), login); // 👈 1
  router.post('/register', validate(register.validationScheme), register); // 👈 1

  const requireAdmin = makeRequireRole(Role.ADMIN); // 👈 4

  // Routes with authentication/autorisation
  router.get(
    '/',
    requireAuthentication,
    requireAdmin,
    validate(getAllUsers.validationScheme),
    getAllUsers
  ); // 👈 3 en 4
  router.get(
    '/:id',
    requireAuthentication,
    validate(getUserById.validationScheme),
    getUserById
  ); // 👈 3
  router.put(
    '/:id',
    requireAuthentication,
    validate(updateUserById.validationScheme),
    updateUserById
  ); // 👈 3
  router.delete(
    '/:id',
    requireAuthentication,
    validate(deleteUserById.validationScheme),
    deleteUserById
  ); // 👈 3

  app.use(router.routes()).use(router.allowedMethods());
};
```

1. `login` en `register` zijn twee publieke API calls, die laten we gerust
2. We importeren onze nieuwe middlewares
3. en dwingen op elke andere route authenticatie af, we moeten dus aangemeld zijn. Aangemeld zijn = Authorization header bevat een geldige JWT
4. We willen ook de `GET /api/users` enkel toegankelijk maken voor admins. Daarom maken we een middleware die op deze rol checkt en voegen deze toe aan de route

## Controleer of de aangemelde gebruiker toegang heeft tot de gegeven user info

We dienen nog te controleren of de aangemelde gebruiker wel toegang heeft tot de gevraagde user informatie. Enkel de admin en de gebruiker zelf heeft daartoe toegang.

`src/rest/user.js`

```js
//..
// 👈
/**
 * Check if the signed in user can access the given user's information.
 */
const checkUserId = (ctx, next) => {
  const { userId, roles } = ctx.state.session;
  const { id } = ctx.params;

  // You can only get our own data unless you're an admin
  if (id !== userId && !roles.includes(Role.ADMIN)) {
    return ctx.throw(
      403,
      "You are not allowed to view this user's information",
      {
        code: 'FORBIDDEN',
      }
    );
  }
  return next();
};
//..
// Routes with authentication
router.get(
  '/',
  requireAuthentication,
  requireAdmin,
  validate(getAllUsers.validationScheme),
  getAllUsers
);
router.get(
  '/:id',
  requireAuthentication,
  validate(getUserById.validationScheme),
  checkUserId,
  getUserById
); // 👈
router.put(
  '/:id',
  requireAuthentication,
  validate(updateUserById.validationScheme),
  checkUserId,
  updateUserById
); // 👈
router.delete(
  '/:id',
  requireAuthentication,
  validate(deleteUserById.validationScheme),
  checkUserId,
  deleteUserById
); // 👈
```

## Sidenote

- in de praktijk wil je liever externe services gebruiken
- dit geeft minder problemen met o.a. GDPR
- authenticatie en autorisatie is toch altijd hetzelfde...
- voorbeelden: [Auth0](https://auth0.com/), [Amazon Cognito](https://aws.amazon.com/cognito/)
  ...

## Oefening: authenticatie

- scherm de routes van de places af: authenticatie vereist
- doe hetzelfde voor de transactions. Pas indien nodig ook de andere lagan aan.
- `GET /api/transactions` mag enkel de transacties van de aangemelde gebruiker retourneren, niet langer alle transacties. Pas ook de service en repository laag aan. Ook voor het tellen van het aantal rijen dient met de aangemelde gebruiker rekening gehouden te worden
- `GET /api/transactions/:id` retourneert de transactie met opgegeven id, maar dit mag enkel indien de transactie behoort tot de aangemelde gebruiker
- `POST /api/transactions/:id` de userId van de te creëeren transactie is de id van de aangemelde gebruiker. Dit geldt ook voor de `PUT` en de `DELETE`
- oplossing: authenticatie - check uit op commit ?????TODO van onze [voorbeeldapplicatie](https://github.com/HOGENT-Web/webservices-budget/tree/authenticatie)

```bash
git pull
git checkout -b authenticatie 129bdb6
```
