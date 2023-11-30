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

[JSON Web Token (JWT)](https://jwt.io/introduction) zijn tokens die typisch worden gebruikt om sessie-informatie door te geven tussen client-server, bv. welke gebruiker aangemeld is, welke rollen/permissies die heeft, hoe lang hij aangemeld mag blijven... Het is een open standaard.

De JWT bevat alle gegevens in plain text, maar geëncodeerd als `base64url` string. De inhoud van een JWT kan je bekijken op [jwt.io](https://jwt.io). De JWT wordt per request doorgestuurd in de `Authorization` header met als prefix **"Bearer "**.

Als een JWT alle sessie-info als plain text bevat, kan ik die wijzigen? Ja, je kan die informatie wijzigen. Kan ik mij dan voordoen als iemand anders? Nee, normaal niet. De JWT bevat ook een **signature**. Deze signature wordt berekend op basis van de payload en een `secret`. Als je de payload wijzigt, zal de signature niet meer kloppen en wordt de JWT ongeldig beschouwd.

### Structuur

Dit is een voorbeeld van een JWT:

<!-- cspell: disable -->
```text
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```
<!-- cspell: enable -->

Een JWT bestaat uit 3 delen:

- header
- payload
- signature

Deze drie delen worden gescheiden door een punt en staan in [`base64url` encodering](https://en.wikipedia.org/wiki/Base64). Elk van deze delen kan je dus gewoon decoderen naar plain text en dan zal je een JSON object krijgen.

### Header

Dit bestaat gewoonlijk uit twee delen:

- `type`: het type van token, in dit geval JWT
- `alg` (= signing algorithm): het algoritme gebruikt om de token te ondertekenen, bv. [HMAC](https://en.wikipedia.org/wiki/HMAC), [SHA256](https://en.wikipedia.org/wiki/SHA-2), [RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem)).

Je kan de header gewoon van `base64url` naar plain text omvormen. Met het voorbeeld geeft dit:

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### Payload

Dit bevat de sessie-info of zogenaamde claims. Er zijn enkele voorgedefinieerde claims, zoals

- `iss`: wie de token uitgaf
- `exp`: vervaldatum
- `sub`: waarover deze token gaat, bv. het id van de gebruiker
- `iat`: datum en tijd waarop de token uitgegeven werd
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

### Signature

De signature is wat een JWT veilig maakt. Het neemt de info uit de header, samen met een _secret_ om zo de payload te ondertekenen. Het is niet meer dan een handtekening die aangeeft of de payload gewijzigd is. Als iemand de payload wijzigt, zal de signature anders zijn en wordt de token ongeldig beschouwd.

### Helpers voor JWT's

We gebruiken het package [jsonwebtoken](https://www.npmjs.com/package/jsonwebtoken) om JWT's te ondertekenen en verifiëren:

```bash
yarn add jsonwebtoken
```

We voegen wat configuratie toe voor jsonwebtoken in `config/development.js`, `config/production.js` en `config/test.js`:

<!-- cSpell: disable -->
```js
module.exports = {
  auth: {
    jwt: {
      secret: 'eenveeltemoeilijksecretdatniemandooitzalradenandersisdesitegehacked',
      expirationInterval: 60 * 60 * 1000, // ms (1 hour)
      issuer: 'budget.hogent.be',
      audience: 'budget.hogent.be',
    },
  },
};
```
<!-- cSpell: enable -->

- `secret`: we definiëren het secret waarmee de payload ondertekend zal worden.
- `expirationInterval`: onze JWT's zullen in development verlopen na 1 uur, in productie zet je dit typisch langer. Dit hangt ook af van het type applicatie, bv. nooit heel lang bij een bankapplicatie. Je hanteert best één standaard voor tijdseenheden in je configuratie, wij kozen voor milliseconden. Het kan handig zijn om een human readable tijdseenheid in commentaar te zetten.
- We definiëren wie de JWT uitgeeft (`issuer`) en wie hem mag accepteren (`audience`).

We definiëren een module met een aantal helpers om een JWT te maken/controleren in `src/core/jwt.js`:

```js
const config = require('config'); // 👈 1
const jwt = require('jsonwebtoken'); // 👈 2
const { getLogger } = require('./logging'); // 👈 6

const JWT_AUDIENCE = config.get('auth.jwt.audience'); // 👈 1
const JWT_SECRET = config.get('auth.jwt.secret'); // 👈 1
const JWT_ISSUER = config.get('auth.jwt.issuer'); // 👈 1
const JWT_EXPIRATION_INTERVAL = config.get('auth.jwt.expirationInterval'); // 👈 1

// 👇 3
const generateJWT = (user) => {
  // 👇 4
  const tokenData = {
    userId: user.id,
    roles: user.roles,
  };

  // 👇 5
  const signOptions = {
    expiresIn: Math.floor(JWT_EXPIRATION_INTERVAL / 1000),
    audience: JWT_AUDIENCE,
    issuer: JWT_ISSUER,
    subject: 'auth',
  };

  // 👇 6
  return new Promise((resolve, reject) => {
    jwt.sign(tokenData, JWT_SECRET, signOptions, (err, token) => {
      if (err) {
        getLogger().error('Error while signing new token:', err.message);
        return reject(err);
      }
      return resolve(token);
    });
  });
};

// 👇 7
const verifyJWT = (authToken) => {
  // 👇 8
  const verifyOptions = {
    audience: JWT_AUDIENCE,
    issuer: JWT_ISSUER,
    subject: 'auth',
  };

  // 👇 9
  return new Promise((resolve, reject) => {
    jwt.verify(authToken, JWT_SECRET, verifyOptions, (err, decodedToken) => {
      if (err || !decodedToken) {
        getLogger().error('Error while verifying token:', err.message);
        return reject(err || new Error('Token could not be parsed'));
      }
      return resolve(decodedToken);
    });
  });
};

// 👇 10
module.exports = {
  generateJWT,
  verifyJWT,
};
```

1. Importeer alle gedefinieerde configuratie.
2. Importeer het `jsonwebtoken` package.
3. Definieer een helper `generateJWT` om een JWT te maken, deze krijgt een gebruiker mee als argument.
4. We geven deze twee properties mee als JWT payload. Je moet deze verplicht apart definiëren
5. Daarnaast definiëren we enkele properties nodig voor het ondertekenen van de JWT:

   - `expiresIn`: hoelang deze token geldig is. Merk op: `expiresIn` staat in seconden en onze configuratie rekent met milliseconden, daarom moeten we dit omvormen.
   - `audience`: welke servers de token mogen accepteren.
   - `issuer`: welke server(s) de token uitgeven.
   - `subject`: waarvoor deze token dient, in dit geval voor authenticatie (auth).

6. We retourneren een `Promise` die zal resolven als de JWT ondertekend is. We moeten de `sign`-functie wrappen in een `Promise` aangezien deze werkt o.b.v. callbacks om asynchroon te zijn. Maar dit werkt niet makkelijk. De `sign`-functie neemt de JWT payload (`tokenData`), het secret en de sign opties als argument en als laatste argument verwacht deze een callback die opgeroepen zal worden als de token ondertekend is of als er iets fout liep. In deze callback resolven of rejecten we de `Promise` indien nodig.
7. We definiëren nog een tweede helper `verifyJWT` (in `src/core/jwt.js`) die een gegeven JWT zal controleren op geldigheid. Mogelijke problemen:

   - JWT is verlopen
   - Er is geprutst aan de payload
   - JWT is niet bedoeld voor deze server
   - ...

8. We geven opnieuw de informatie mee die we verwachten in de token.
9. Omdat `jwt.verify` ook met een callback werkt, moeten we deze wrappen in een Promise. `jwt.verify` verwacht de JWT, het secret en de opties als argumenten. Als laatste argument volgt een callback die opgeroepen zal worden als de token gecontroleerd is. In deze callback resolven of rejecten we de `Promise` indien nodig.
10. Exporteer de twee helpers.

Kopieer onderstaande code in een `src/testjwt.js` bestand en test zelf of jouw code werkt! Je kan dit script uitvoeren d.m.v. `node src/testjwt.js`

```js
process.env.NODE_CONFIG = JSON.stringify({
  env: 'development',
});

const { generateJWT, verifyJWT } = require('./core/jwt');

function messWithPayload(jwt) {
  const [header, payload, signature] = jwt.split('.');
  const parsedPayload = JSON.parse(
    Buffer.from(payload, 'base64url').toString(),
  );

  // make me admin please ^^
  parsedPayload.roles.push('admin');

  const newPayload = Buffer.from(
    JSON.stringify(parsedPayload),
    'ascii',
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

  try {
    console.log('Verifying this JWT will throw an error:');
    valid = await verifyJWT(messedUpJwt);
  } catch (err) {
    console.log('We expected an error:', err.message);
  }
}

main();
```

## Wachtwoorden opslaan

We moeten onze wachtwoorden opslaan in de databank. We doen dit uiteraard niet in plain text. We **hashen** de wachtwoorden met [argon2](https://github.com/P-H-C/phc-winner-argon2). Dit is een van de nieuwste en beste hashing algoritmes voor o.a. wachtwoorden.

### Hashing: herhaling

Een hashing algoritme is een one-way algoritme. Het neemt een input en vormt deze om naar een output met een vast aantal bits. Als de input wijzigt, moet de output significant en willekeurig genoeg wijzigen. Zo kan je de bewerking niet omgekeerd doen en achterhalen wat de input was. Dit is net wat we willen om wachtwoorden op te slaan.

### Hashing: salt

Sommige hashing algoritmes gebruiken een **salt**. Dit is een willekeurig string (met vaste lengte) en wordt gebruikt om een verschillende hash te genereren bij een identieke input. Dus: hetzelfde wachtwoord hashen met een andere salt, geeft een andere hash. Dit maakt bv. [dictionary attacks](https://www.sciencedirect.com/topics/computer-science/dictionary-attack) moeilijker.

### Helpers voor hashing

We gebruiken het package `argon2` om het argon2 algoritme te gebruiken in Node.js:

```bash
yarn add argon2
```

We voegen wat configuratie toe voor argon2 `config/development.js`, `config/production.js` en `config/test.js`:

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
- `hashLength`: onze hash moet 32 bytes groot zijn (256 bits)
- `timeCost`: we laten het hashing algoritme 6 iteraties uitvoeren
- `memoryCost`: elke thread van het algoritme mag 128MiB gebruiken

De laatste twee opties bepalen de duur van de hashing: hoe groter deze getallen, hoe langer het duurt. Langer is altijd beter, maar je applicatie moet nog bruikbaar blijven.

Als laatste definiëren we een module met een aantal helpers om een wachtwoord te hashen/controleren in `src/core/password.js`:

```js
const config = require('config'); // 👈 1
const argon2 = require('argon2'); // 👈 2

const ARGON_SALT_LENGTH = config.get('auth.argon.saltLength'); // 👈 1
const ARGON_HASH_LENGTH = config.get('auth.argon.hashLength'); // 👈 1
const ARGON_TIME_COST = config.get('auth.argon.timeCost'); // 👈 1
const ARGON_MEMORY_COST = config.get('auth.argon.memoryCost'); // 👈 1

// 👇 3
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

// 👇 3
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

// 👇 3
module.exports = {
  hashPassword,
  verifyPassword,
};
```

1. Importeer alle gedefinieerde configuratie.
2. Importeer het argon2 package.
3. Definieer twee helperfuncties om een wachtwoord te hashen en om te checken of een gegeven wachtwoord dezelfde hash oplevert. Wachtwoorden vergelijken kan enkel door te checken of ze dezelfde hash opleveren. Exporteer de functies.
4. De argon2 library exporteert een `hash`-functie om een gegeven string te hashen. Het verwacht de string als eerste argument en wat opties als tweede argument. We geven onze configuratie mee aan de juiste optie. We kiezen de `argon2id` versie van het algoritme (resistent tegen GPU en tradeoff attacks).
5. De argon2 library exporteert een `verify`-functie om te checken of een gegeven string dezelfde hash oplevert. We geven opnieuw alle configuratie mee.

Kopieer deze code in een `src/testpw.js` bestand en test zelf of jouw code werkt! Speel een beetje met de configuratie en bekijk de invloed op de uitvoeringstijd van het algoritme.

Je kan onderstaande code uitvoeren m.b.v. `node src/testpw.js`.

<!-- cSpell: disable -->
```js
process.env.NODE_CONFIG = JSON.stringify({
  env: 'development',
});

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
<!-- cSpell: enable -->

### Wachtwoord opslaan in de databank

Om te kunnen aanmelden, moeten we extra informatie van onze gebruikers opslaan: o.a. een e-mailadres en een wachtwoord. Om deze extra informatie in onze databank toe te voegen, maken we een nieuwe **migratie** in `src/data/migrations/202309191630_addAuthInfoToUserTable.js`:

```js
const { tables } = require('..');

module.exports = {
  up: async (knex) => {
    await knex.schema.alterTable(tables.user, (table) => { // 👈 1
      table.string('email').notNullable(); // 👈 2

      table.string('password_hash').notNullable(); // 👈 2

      table.jsonb('roles').notNullable(); // 👈 2

      table.unique('email', 'idx_user_email_unique'); // 👈 3
    });
  },
  down: (knex) => {
    // 👇 4
    return knex.schema.alterTable(tables.user, (table) => {
      table.dropColumns('email', 'password_hash', 'roles');
    });
  },
};
```

1. We wijzigen dus de `users` tabel.
2. We voegen drie nieuwe kolommen toe: een e-mailadres een gehasht wachtwoord en de rollen van de gebruiker. Merk op: we slaan de rollen op als JSON, dit moeten we dus opvangen in de repository. De rollen gebruiken we straks voor de autorisatie.
   - Je zou deze ook in een aparte tabel kunnen opslaan, maar dat laten we voor de eenvoud even achterwege hier.
3. We zetten een UNIQUE index op het e-mailadres en geven deze index een naam voor beter error handling (zie later).
4. In de `down` functie verwijderen we de aangemaakte kolommen.

Pas de **seed** voor `users` aan met deze code. Deze seed stelt voor elke user het wachtwoord `12345678` in. Als rollen kunnen `user` en/of `admin` worden toegekend.

<!-- cSpell: disable -->
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
<!-- cSpell: enable -->

De extra kolommen hebben als gevolg dat de user repository (in `src/repository/user.js`) nu ook een `email`, `passwordHash` en `roles` verwacht als parameter bij `create`.

```js
// ...
const create = async ({
  name,
  email, // 👈 1
  passwordHash, // 👈 1
  roles, // 👈 1
}) => {
  try {
    const [id] = await getKnex()(tables.user).insert({
      id,
      name,
      email, // 👈 2
      password_hash: passwordHash, // 👈 2
      roles: JSON.stringify(roles), // 👈 3
    });
    return id;
  } catch (error) {
    getLogger().error('Error in create', {
      error,
    });
    throw error;
  }
};
// ...
```

1. We voegen de nieuwe kolommen toe als parameter.
2. Deze geven we dan ook mee aan onze insert, we vormen de `passwordHash` om naar `password_hash`.
3. Deze rollen moeten we omzetten naar JSON alvorens we ze opslaan in de databank (zie migratie). Bij het ophalen wordt deze kolom automatisch geparsed voor ons, m.a.w. we krijgen een array.

Ook in de user service (in `src/service/user.js`) komen deze extra kolommen mee als parameter. Let wel op: hier komt het wachtwoord nog als plain text binnen!

```js
// ...
const register = async ({
  name,
  email, // 👈 1
  password, // 👈 1
}) => {
  try {
    const passwordHash = await hashPassword(password); // 👈 2

    const userId = await userRepository.create({
      name,
      email, // 👈 2
      passwordHash, // 👈 2
      roles: ['user'], // 👈 3
    });
    return await userRepository.findById(userId);
  } catch (error) {
    throw handleDBError(error);
  }
};
// ...
```

1. We voegen e-mail en wachtwoord toe.
2. We hashen het wachtwoord in de service-laag en geven het e-mailadres en hashed wachtwoord door aan de repository
3. De rollen geven we als array mee. De repository zet deze voor ons om naar JSON

### Oefening 1

- Pas ook de andere functies aan waar nodig (in de repository en service).
- Pas ook de REST-laag van de users aan waar nodig.

<!-- markdownlint-disable-next-line -->
+ Oplossing +

  Een voorbeeldoplossing is te vinden op <https://github.com/HOGENT-Web/webservices-budget> in de branch `authenticatie` op commit `8c2a689`

  ```bash
  git clone https://github.com/HOGENT-Web/webservices-budget.git
  git checkout -b authenticatie-oef1 8c2a689
  yarn install
  yarn start
  ```

## Aanmelden

We definiëren alle rollen in onze applicatie in een constant object. Zo is het eenvoudig om ze te wijzigen indien nodig. Voeg onderstaande code toe aan `src/core/roles.js`

```js
module.exports = Object.freeze({
  USER: 'user',
  ADMIN: 'admin',
});
```

We updaten de **seed voor users** met deze nieuwe rollen:

<!-- cSpell: disable -->
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
<!-- cSpell: enable -->

We passen `ServiceError` aan. Mogelijke nieuwe fouten zijn:

- unauthorized: authenticatie faalt
- forbidden: autorisatie faalt

`core/serviceError.js`

```js
const UNAUTHORIZED = 'UNAUTHORIZED'; // 👈 1
const FORBIDDEN = 'FORBIDDEN'; // 👈 1

class ServiceError extends Error {
  // ...

  // 👇 2
  static unauthorized(message, details) {
    return new ServiceError(UNAUTHORIZED, message, details);
  }

  // 👇 2
  static forbidden(message, details) {
    return new ServiceError(FORBIDDEN, message, details);
  }

  // ...

  // 👇 3
  get isUnauthorized() {
    return this.code === UNAUTHORIZED;
  }

  // 👇 3
  get isForbidden() {
    return this.code === FORBIDDEN;
  }
}

module.exports = ServiceError;
```

1. Voeg de constanten toe.
2. Voorzie de static functies om een `ServiceError` te maken voor deze fouten.
3. Voorzie de getters om te checken of een `ServiceError` een bepaalde fout bevat.

In de middleware voor het afhandelen van de `ServiceError` (in `core/installMiddlewares.js`) voegen we de afhandeling van `isUnauthorized` en `isForbidden` toe:

```js
// ...
if (error instanceof ServiceError) {
  // ...

  if (error.isUnauthorized) {
    statusCode = 401;
  }

  if (error.isForbidden) {
    statusCode = 403;
  }
}
// ...
```

Pas in de user service ook de hard gecodeerde rol in de `register` functie.

We voegen in `src/repository/user.js` een functie toe die een gebruiker met een bepaald e-mailadres ophaalt:

```js
// ...

// 👇 1
const findByEmail = (email) => {
  return getKnex()(tables.user).where('email', email).first();
};

module.exports = {
  // ...
  findByEmail, // 👈 2
};
```

1. Daarvoor schrijven we deze query. We kunnen veilig `first()` gebruiken aangezien er een UNIQUE index staat op de kolom `email`.
2. Vergeet deze functie dan ook niet te exporteren.

We definiëren een functie `login` in `src/service/user.js` die een gebruiker met een bepaald e-mailadres probeert aan te melden. Als de gebruiker is aangemeld, retourneren we het token en de publieke informatie van de gebruiker (id, naam, e-mail en rollen):

```js
// ...
const { verifyPassword, verifyPassword } = require('../core/password'); // 👈 4
const { generateJWT } = require('../core/jwt'); // 👈 7

// 👇 8
const makeExposedUser = ({ id, name, email, roles }) => ({
  id,
  name,
  email,
  roles,
});

// 👇 6
const makeLoginData = async (user) => {
  const token = await generateJWT(user); // 👈 7
  return {
    user: makeExposedUser(user),
    token,
  }; // 👈 8
};

// 👇 1
const login = async (email, password) => {
  const user = await userRepository.findByEmail(email); // 👈 2

  // 👇 3
  if (!user) {
    // DO NOT expose we don't know the user
    throw ServiceError.unauthorized(
      'The given email and password do not match'
    );
  }

  const passwordValid = await verifyPassword(password, user.password_hash); // 👈 4

  // 👇 5
  if (!passwordValid) {
    // DO NOT expose we know the user but an invalid password was given
    throw ServiceError.unauthorized(
      'The given email and password do not match'
    );
  }

  return await makeLoginData(user); // 👈 6
};

module.exports = {
  // ...
  login, // 👈 9
};
```

1. De functie `login` krijgt een e-mailadres en wachtwoord als parameter.
2. We kijken eerst of er een gebruiker met dit e-mailadres is.
3. Als die gebruiker niet bestaat, doen we alsof het e-mailadres en wachtwoord niet matchen. We willen niet laten blijken dat we de gebruiker kennen.
4. Als we een gebruiker hebben, verifiëren we het opgegeven wachtwoord met de opgeslagen hash.
5. Als het wachtwoord fout is, zeggen we opnieuw dat het e-mailadres en wachtwoord niet matchen.
6. Vervolgens maken we de data die geretourneerd moet worden na login. We maken hiervoor een helperfunctie aangezien we die data ook nodig hebben bij het registreren.
7. Eerst maken we een JWT voor die gebruiker.
8. Vervolgens retourneren we de token en enkel de velden van de user die publiek zijn. Voor dit laatste maken we opnieuw een helperfunctie (we hebben deze nog nodig bij bv. `findById`).
9. Vergeet ook de `login` functie niet te exporteren.

Vervolgens passen we de rest module voor alle routes m.b.t. de gebruikers aan (`src/rest/user.js`):

```js
// ...

// 👇 1
const login = async (ctx) => {
  const { email, password } = ctx.request.body; // 👈 2
  const token = await userService.login(email, password); // 👈 3
  ctx.body = token; // 👈 4
};
login.validationScheme = { // 👈 5
  body: {
    email: Joi.string().email(),
    password: Joi.string(),
  },
};

module.exports = function installUsersRoutes(app) {
  const router = new Router({
    prefix: '/users',
  });
  // ...
  router.post('/login', validate(login.validationScheme), login); // 👈 6
  // ...
};
```

1. We definiëren een functie voor onze `login` route.
2. We halen het e-mailadres en wachtwoord uit de HTTP body.
3. We proberen de gebruiker aan te melden.
4. Als dat gelukt is, geven we de token-informatie mee in de HTTP response body.
5. We voorzien ook een validatieschema voor de input.
6. We geven deze functie mee aan de POST op `/login` en doen ook de invoervalidatie.

### Oefening 2

Pas ook de overige functies aan:

- `register` retourneert enkel het token en de publieke user data
- `getAll` en `getById` mogen enkel de publieke user data retourneren (dus zeker geen wachtwoorden!)

## Registreren

We overlopen hier nog eens de belangrijkste code van het registreerproces. In `src/service/user.js` hebben we:

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

  // 👇 3
  const userId = await userRepository.create({
    name,
    email,
    passwordHash,
    roles: [Role.USER],
  });

  const user = await userRepository.findById(userId); // 👈 4
  return await makeLoginData(user); // 👈 5
};
```

1. We geven nu ook een e-mailadres en wachtwoord mee als we een nieuwe gebruiker toevoegen.
2. Hierbij moeten we eerst het wachtwoord hashen.
3. Vervolgens maken we de gebruiker met deze gegevens. We maken elke nieuwe gebruiker standaard enkel `USER`.
4. Vervolgens halen we de zojuist gecreëerde gebruiker op.
5. Dan maken we voor deze gebruiker ook token-informatie en de publieke user info aan. Zo is een geregistreerde gebruiker meteen aangemeld.

We bekijken ook nog eens de request handler voor het registreren in `src/rest/_user.js`:

```js
const register = async (ctx) => {
  const token = await userService.register(ctx.request.body); // 👈 1
  ctx.body = token; // 👈 2
  ctx.status = 200; // 👈 2
};
register.validationScheme = { // 👈 3
  body: {
    name: Joi.string().max(255),
    email: Joi.string().email(),
    password: Joi.string().min(8).max(30),
  },
};

module.exports = function installUsersRoutes(app) {
  // ...
  router.post('/register', validate(register.validationScheme), register); // 👈 4
  // ...
};
```

1. We registreren de nieuwe gebruiker (alle informatie zit in de HTTP body). We krijgen de token-informatie en publieke user informatie terug.
2. We retourneren deze token-informatie en publieke user informatie in de HTTP response body, evenals een statuscode 200.
3. We voorzien ook een validatieschema voor de input.
4. We geven deze functie mee aan de POST op `/register` en doen ook de invoervalidatie.

## Helpers voor authenticatie/autorisatie

We definiëren een module `src/core/auth.js` die twee helpers exporteert. Beide helpers zijn middlewares voor Koa.

- De eerste helper dwingt af dat de gebruiker moet aangemeld zijn om een endpoint uit te voeren.
- De tweede helper dwingt af dat de gebruiker de juiste rollen heeft om een endpoint uit te voeren.

```js
const userService = require('../service/user');

// 👇 1
const requireAuthentication = async (ctx, next) => {
  const { authorization } = ctx.headers; // 👈 3

  // 👇 4
  const { authToken, ...session } = await userService.checkAndParseSession(
    authorization
  );

  ctx.state.session = session; // 👈 5
  ctx.state.authToken = authToken; // 👈 6

  return next(); // 👈 7
};

// 👇 2
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

1. Een eerste helper dwingt af om aangemeld te zijn (= **authenticatie**).
2. Een andere helper die een middleware opmaakt die een bepaalde rol afdwingt (= **autorisatie**).
3. We halen de `Authorization` header op.
4. We laten de user service deze token verifiëren en parsen, en verwachten sessie-informatie terug. We implementeren deze functie later.
5. We slaan de sessie-informatie op in de `state` van de huidige `context`. In de `ctx.state` kan je bijhouden wat je wil.
6. We slaan ook de JWT op in `ctx.state`.
7. We roepen de volgende middleware in de rij aan.
8. We halen de rollen uit de sessie-informatie.
   - **Merk op:** deze middleware vereist dat de `requireAuthentication` middleware reeds uitgevoerd is, let dus op de volgorde!!!
9. We laten de user service checken of de aangemelde gebruiker de vereiste rol heeft. We implementeren deze functie ook later.
10. Als laatste roepen we ook de volgende middleware in de rij aan.

We definiëren een eerste functie om een JWT te verifiëren en te parsen in `src/service/user.js`:

```js
const config = require('config'); // 👈 7
const { getLogger } = require('../core/logging'); // 👈 4
const { generateJWT, verifyJWT } = require('../core/jwt'); // 👈 5

const checkAndParseSession = async (authHeader) => {
  // 👇 1
  if (!authHeader) {
    throw ServiceError.unauthorized('You need to be signed in');
  } 

  // 👇 2
  if (!authHeader.startsWith('Bearer ')) {
    throw ServiceError.unauthorized('Invalid authentication token');
  }

  const authToken = authHeader.substring(7); // 👈 3
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

// ...
module.exports = {
  checkAndParseSession,
  // ...
};
```

1. Als er geen header meegegeven werd aan het request, gooien we een fout.
2. Indien de header niet start met "Bearer " gooien we ook een fout, dit moet zo per definitie.
3. Vervolgens verwijderen we de "Bearer " van de token, zo hebben we enkel de JWT over.
4. We wrappen alles in een try-catch om de fouten nog eens afzonderlijk te loggen. Alle fouten die gegooid worden, hebben te maken met de geldigheid van de JWT (verlopen, ongeldig signature...)
5. We verifiëren de JWT. Als deze geldig is, dan krijgen we de payload van de token terug.
6. Als laatste retourneren we alle sessie-informatie, alsook de token.

De laatste functie in de user service (`src/service/user.js`) zal checken of een gegeven rol in de array van rollen voorkomT. De array bevat alle rollen van de gebRuiker (uit de JWT payload gehaald).

```js
const checkRole = (role, roles) => {
  const hasPermission = roles.includes(role); // 👈 1

  if (!hasPermission) {
    throw ServiceError.forbidden(
      'You are not allowed to view this part of the application'
    ); // 👈 2
  }
};

// ...
module.exports = {
  checkRole,
  // ...
};
```

1. Met de functie includes kunnen we controleren of de rol voorkomt in de array
2. Als de rol niet in de array zit, wordt een Forbidden fout geworpen, die zal worden afgehandeld door de middleware

**Hoe gebruiken we deze middlewares nu?**

Pas `src/rest/user/js` als volgt aan:

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

  // Routes with authentication/authorization
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

  app.use(router.routes())
    .use(router.allowedMethods());
};
```

1. `login` en `register` zijn twee publieke API calls, die laten we gerust.
2. We importeren onze nieuwe middlewares.
3. En dwingen op elke andere route authenticatie af, we moeten dus aangemeld zijn.
   - Aangemeld zijn = `Authorization` header bevat een geldige JWT.
4. We willen ook de `GET /api/users` enkel toegankelijk maken voor admins. Daarom maken we een middleware die op deze rol checkt en voegen deze toe aan de route.

## Controleer of de aangemelde gebruiker toegang heeft tot de gegeven user info

We dienen nog te controleren of de aangemelde gebruiker wel toegang heeft tot de gevraagde user informatie. Enkel de admin en de gebruiker zelf heeft daartoe toegang.

Voeg toe aan `src/rest/user.js`:

```js
// ...
// 👇
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
// ...
router.get(
  '/:id',
  requireAuthentication,
  validate(getUserById.validationScheme),
  checkUserId, // 👈
  getUserById
);
router.put(
  '/:id',
  requireAuthentication,
  validate(updateUserById.validationScheme),
  checkUserId, // 👈
  updateUserById
);
router.delete(
  '/:id',
  requireAuthentication,
  validate(deleteUserById.validationScheme),
  checkUserId, // 👈
  deleteUserById
);
```

## Opmerking

In de praktijk wil je liever externe services gebruiken voor authenticatie en autorisatie. Dit geeft minder problemen met o.a. GDPR en authenticatie en autorisatie is toch altijd hetzelfde...

Voorbeelden zijn [Auth0](https://auth0.com/), [Amazon Cognito](https://aws.amazon.com/cognito/)...

## Oefening 3 - Authenticatie

- Scherm de routes van de places af, authenticatie is vereist.
- Doe hetzelfde voor de transactions. Pas indien nodig ook de andere lagan aan.
- `GET /api/transactions` mag enkel de transacties van de aangemelde gebruiker retourneren, niet langer alle transacties. Pas ook de service- en repositorylaag aan. Ook voor het tellen van het aantal rijen dient met de aangemelde gebruiker rekening gehouden te worden.
- `GET /api/transactions/:id` retourneert de transactie met opgegeven id, maar dit mag enkel indien de transactie behoort tot de aangemelde gebruiker.
- `POST /api/transactions`: de `userId` van de te creëren transactie is de id van de aangemelde gebruiker. Dit geldt ook voor de `PUT /api/transactions/:id`.
- `DELETE /api/transactions/:id`: verwijder enkel transacties van de aangemelde gebruiker.

<!-- markdownlint-disable-next-line -->
+ Oplossing +

  Een voorbeeldoplossing is te vinden op <https://github.com/HOGENT-Web/webservices-budget> in de branch `authenticatie` in de commit `90d9ffd`

  ```bash
  git clone https://github.com/HOGENT-Web/webservices-budget.git
  git checkout -b authenticatie-oef2 90d9ffd
  yarn install
  yarn start
  ```
