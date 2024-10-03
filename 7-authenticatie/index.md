# Authenticatie en autorisatie

<!-- TODO: startpunt en oplossing toevoegen -->

## JWT

[JSON Web Token (JWT)](https://jwt.io/introduction) zijn tokens die typisch worden gebruikt om sessie-informatie door te geven tussen client-server, bv. welke gebruiker aangemeld is, welke rollen/permissies die heeft, hoe lang hij aangemeld mag blijven... Het is een open standaard.

De JWT bevat alle gegevens in plain text, maar geëncodeerd als `base64url` string. De inhoud van een JWT kan je bekijken op [jwt.io](https://jwt.io). De JWT wordt per request doorgestuurd in de `Authorization` header met als prefix **"Bearer "**.

Als een JWT alle sessie-info als plain text bevat, kan ik die wijzigen? Ja, je kan die informatie wijzigen. Kan ik mij dan voordoen als iemand anders? Nee, normaal niet. De JWT bevat ook een **signature**. Deze signature wordt berekend op basis van de payload en een **secret**. Dit secret is enkel gekend door de server. Als je de payload wijzigt, zal de signature niet meer kloppen en wordt de JWT ongeldig beschouwd.

### Structuur

Dit is een voorbeeld van een JWT:

<!-- cspell: disable -->

<span style="text-wrap: wrap; word-wrap: break-word;">
  <span style="color: #fb015b;">eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9</span>.<span style="color: #d63aff;">eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ</span>.<span style="color: #00b9f1;">flKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c</span>
</span>

<!-- cspell: enable -->

Een JWT bestaat uit 3 delen:

- <span style="color: #fb015b;">header</span>
- <span style="color: #d63aff;">payload</span>
- <span style="color: #00b9f1;">signature</span>

Deze drie delen worden gescheiden door een punt en staan in [base64url encodering](https://en.wikipedia.org/wiki/Base64). Elk van deze delen kan je dus gewoon decoderen naar plain text en zal een JSON object bevatten.

### Header

De header bevat gewoonlijk twee properties:

- `type`: het type van token, in dit geval JWT
- `alg` (= signing algorithm): het algoritme gebruikt om de token te ondertekenen, bv. [HMAC](https://en.wikipedia.org/wiki/HMAC), [SHA256](https://en.wikipedia.org/wiki/SHA-2), [RSA](<https://en.wikipedia.org/wiki/RSA_(cryptosystem)>).

Je kan de header gewoon van `base64url` naar plain text omvormen. Met het bovenstaande voorbeeld geeft dit:

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

Het token uit het bovenstaande voorbeeld bevat volgende payload:

```json
{
  "sub": "1234567890",
  "name": "John Doe",
  "iat": 1516239022
}
```

### Signature

De signature is wat een JWT veilig maakt. Het neemt de info uit de header, samen met een _secret_ om zo de payload te ondertekenen. Het is niet meer dan een handtekening die aangeeft of de payload gewijzigd is. Als iemand de payload wijzigt, zal de signature anders zijn en wordt de token ongeldig beschouwd.

## User types uitbreiden

Voor we aan de slag gaan, definiëren we een aantal extra types voor onze entiteit gebruiker. We breiden de bestaande types ook een beetje uit. Voeg onderstaande code toe aan `src/types/user.ts`:

```ts
import type { Prisma } from '@prisma/client';
import type { Entity, ListResponse } from './common';

// 👇 1
export interface User extends Entity {
  name: string;
  email: string;
  passwordHash: string;
  roles: string[];
}

// 👇 2
export interface UserRecord {
  id: number;
  name: string;
  email: string;
  password_hash: string;
  roles: Prisma.JsonValue;
}
```

1. We voegen `email`, `passwordHash` en `roles` toe aan de `User` interface.
2. We definiëren ook een interface die een record van een gebruiker voorstelt. Deze interface hebben we nodig omdat onze JWT helpers zullen werken met de raw data uit de databank.
   - Later zal je zien dat we nooit de volledige `User` interface zullen teruggeven. Die bevat nl. `passwordHash` en dat willen we niet zomaar teruggeven.

## Helpers voor JWT's

We gebruiken het package [jsonwebtoken](https://www.npmjs.com/package/jsonwebtoken) om JWT's te ondertekenen en verifiëren:

```bash
yarn add jsonwebtoken
```

We voegen wat configuratie toe voor jsonwebtoken in `config/development.ts`, `config/production.ts` en `config/test.ts`:

<!-- cSpell: disable -->

```ts
export default {
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

<!-- cSpell: enable -->

- `secret`: we definiëren het secret waarmee de payload ondertekend zal worden.
  - Dit secret is voor onze development omgeving, dus deze mag gewoon in onze code staan. Hoe we het secret voor onze productie-omgeving meegeven, zien we in een later hoofdstuk.
- `expirationInterval`: onze JWT's zullen in development verlopen na 1 uur, in productie zet je dit typisch langer. Dit hangt ook af van het type applicatie, bv. nooit heel lang bij een bankapplicatie. Je hanteert best één standaard voor tijdseenheden in je configuratie, wij kozen voor milliseconden. Het kan handig zijn om een human readable tijdseenheid in commentaar te zetten.
- We definiëren wie de JWT uitgeeft (`issuer`) en wie hem mag accepteren (`audience`).

We definiëren een module met een aantal helpers om een JWT te maken/controleren in `src/core/jwt.ts`:

```ts
import config from 'config'; // 👈 1
import type {
  JwtPayload,
  Secret,
  SignOptions,
  VerifyOptions,
} from 'jsonwebtoken'; // 👈 2
import jwt from 'jsonwebtoken'; // 👈 2
import util from 'node:util'; // 👈 3
import type { UserRecord } from '../types/user';

// 👇 1
const JWT_AUDIENCE = config.get<string>('auth.jwt.audience');
const JWT_SECRET = config.get<string>('auth.jwt.secret');
const JWT_ISSUER = config.get<string>('auth.jwt.issuer');
const JWT_EXPIRATION_INTERVAL = config.get<number>(
  'auth.jwt.expirationInterval',
);

// 👇 4
const asyncJwtSign = util.promisify<JwtPayload, Secret, SignOptions, string>(
  jwt.sign,
);
const asyncJwtVerify = util.promisify<
  string,
  Secret,
  VerifyOptions,
  JwtPayload
>(jwt.verify);

// 👇 5
export const generateJWT = async (user: UserRecord): Promise<string> => {
  const tokenData = { roles: user.roles }; // 👈 6

  // 👇 7
  const signOptions = {
    expiresIn: Math.floor(JWT_EXPIRATION_INTERVAL / 1000),
    audience: JWT_AUDIENCE,
    issuer: JWT_ISSUER,
    subject: `${user.id}`,
  };

  // 👇 8
  return asyncJwtSign(tokenData, JWT_SECRET, signOptions);
};

// 👇 9
export const verifyJWT = async (authToken: string): Promise<JwtPayload> => {
  // 👇 10
  const verifyOptions = {
    audience: JWT_AUDIENCE,
    issuer: JWT_ISSUER,
  };

  // 👇 11
  return asyncJwtVerify(authToken, JWT_SECRET, verifyOptions);
};
```

1. Importeer alle gedefinieerde configuratie.
2. Importeer het `jsonwebtoken` package. We importeren ook enkele types uit dit package.
3. We importeren de in Node.js ingebouwde `util` module om de `sign` en `verify` functies van `jsonwebtoken` om te vormen naar `Promise`-gebaseerde functies.
4. Met de `promisify` functie van `util` kunnen we een callback-gebaseerde functie omvormen naar een `Promise`-gebaseerde functie. De `promisify` functie verwacht dat de callback als laatste argument wordt meegegeven aan de originele functie.
   - We geven ook de nodige type mee zodat we correcte typechecking hebben bij de geretourneerde functie.
   - We geven steeds 4 types mee waarvan het laatste type de returnwaarde is. De overige types zijn de argumenten van de originele functie.
5. Definieer (en exporteer) een helper `generateJWT` om een JWT te maken. Deze krijgt een gebruiker mee als argument en geeft een JWT terug. De functie is asynchroon dus we geven `Promise<string>` terug i.p.v. `string`.
6. We geven de `roles` mee als extra JWT payload, je moet deze verplicht apart definiëren.
   - Let wel op: enkel controle op een rol doen in de frontend is niet voldoende. De backend moet altijd controleren of de gebruiker de actie mag uitvoeren. In de frontend wordt nl. de signature van de JWT niet geverifieerd, dus kan een gebruiker in principe zijn rol wijzigen.
   - Onze API calls zullen dus altijd de nodige rollen controleren.
7. Daarnaast definiëren we enkele properties nodig voor het ondertekenen van de JWT:
   - `expiresIn`: hoelang deze token geldig is. Merk op: `expiresIn` moet in seconden meegegeven worden en onze configuratie rekent in milliseconden, daarom moeten we dit omvormen.
   - `audience`: welke servers de token mogen accepteren.
   - `issuer`: welke server(s) de token uitgeven.
   - `subject`: voor wie deze token dient (bv. het id van de gebruiker), dit moet een string zijn.
8. Vervolgens retourneren we het resultaat van de Promise-gebaseerde `sign` functie.
9. We definiëren (en exporteren) nog een tweede helper `verifyJWT` die een gegeven JWT zal controleren op geldigheid. Deze functie geeft de payload van de JWT terug. Mogelijke problemen:
   - JWT is verlopen
   - Er is geprutst aan de payload
   - JWT is niet bedoeld voor deze server
   - ...
10. We geven opnieuw de informatie mee die we verwachten in de token. Hier moeten we enkel de `audience` en `issuer` meegeven omdat we moeten controleren of de token bedoeld is voor onze server.
11. Vervolgens retourneren we het resultaat van de Promise-gebaseerde `verify` functie.

Kopieer onderstaande code in een `src/testjwt.ts` bestand en test zelf of jouw code werkt! Je kan dit script uitvoeren met het commando `yarn tsx src/testjwt.ts`.

```ts
process.env.NODE_CONFIG = JSON.stringify({
  env: 'development',
});

import { generateJWT, verifyJWT } from './core/jwt';

function messWithPayload(jwt: string) {
  const [header, payload, signature] = jwt.split('.');
  const parsedPayload = JSON.parse(
    Buffer.from(payload!, 'base64url').toString(),
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
    name: 'Thomas Aelbrecht',
    email: 'thomas.aelbrecht@hogent.be',
    roles: ['user'],
    password_hash: 'ongeldigehash',
  };

  const jwt = await generateJWT(fakeUser);
  // copy and paste the JWT in the textfield on https://jwt.io
  // inspect the content
  console.log('The JWT:', jwt);

  let valid = await verifyJWT(jwt);
  console.log('This JWT is', valid ? 'valid' : 'incorrect');
  console.log('\n');

  // Let's mess with the payload
  const messedUpJwt = messWithPayload(jwt);
  console.log('Messed up JWT:', messedUpJwt);

  try {
    console.log('Verifying this JWT will throw an error:');
    valid = await verifyJWT(messedUpJwt);
  } catch (err: any) {
    console.log('We expected an error:', err.message);
  }
}

main();
```

?> Het is niet de bedoeling om dit script in je eigen repository te houden! Dit is enkel om te testen of je code werkt, gooi het weg na gebruik.

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

We voegen wat configuratie toe voor argon2 `config/development.ts`, `config/production.ts` en `config/test.ts`:

```ts
export default = {
  auth: {
    argon: {
      hashLength: 32,
      timeCost: 6,
      memoryCost: 2 ** 17,
    },
  },
};
```

- `hashLength`: onze hash moet 32 bytes groot zijn (256 bits)
- `timeCost`: we laten het hashing algoritme 6 iteraties uitvoeren
- `memoryCost`: elke thread van het algoritme mag 128 MiB gebruiken

De laatste twee opties bepalen de duur van de hashing: hoe groter deze getallen, hoe langer het duurt. Langer is altijd beter, maar je applicatie moet natuurlijk nog bruikbaar blijven.

Als laatste definiëren we een module met een aantal helpers om een wachtwoord te hashen/controleren in `src/core/password.ts`:

```ts
import config from 'config'; // 👈 1
import argon2 from 'argon2'; // 👈 2

// 👇 1
const ARGON_HASH_LENGTH = config.get<number>('auth.argon.hashLength');
const ARGON_TIME_COST = config.get<number>('auth.argon.timeCost');
const ARGON_MEMORY_COST = config.get<number>('auth.argon.memoryCost');

// 👇 3
export const hashPassword = async (password: string): Promise<string> => {
  // 👇 4
  return argon2.hash(password, {
    type: argon2.argon2id,
    hashLength: ARGON_HASH_LENGTH,
    timeCost: ARGON_TIME_COST,
    memoryCost: ARGON_MEMORY_COST,
  });
};

// 👇 5
export const verifyPassword = async (
  password: string,
  passwordHash: string,
): Promise<boolean> => {
  // 👇 6
  return argon2.verify(passwordHash, password);
};
```

1. Importeer alle gedefinieerde configuratie.
2. Importeer het `argon2` package.
3. Definieer (en exporteer) een helper om een wachtwoord te hashen. Deze functie ontvangt het wachtwoord in plain text en retourneert de hash van het wachtwoord.
4. De argon2 library exporteert een `hash`-functie om een gegeven string te hashen. Het verwacht de string als eerste argument en wat opties als tweede argument. We geven onze configuratie mee aan de juiste optie. We kiezen de `argon2id` versie van het algoritme (resistent tegen GPU en tradeoff attacks).
5. Definieer (en exporteer) een helper om een wachtwoord te controleren. Deze functie ontvangt het wachtwoord in plain text en de hash van het wachtwoord en retourneert `true` of `false`, afhankelijk of het wachtwoord overeenkomt met de hash.
6. De argon2 library exporteert een `verify`-functie om te checken of een gegeven string dezelfde hash oplevert. Het verwacht de hash als eerste argument en de string als tweede argument. De opties die gebruikt zijn bij het hashen zitten in de hash zelf, dus deze moeten niet meegegeven worden.

Kopieer deze code in een `src/testpw.ts` bestand en test zelf of jouw code werkt! Speel een beetje met de configuratie en bekijk de invloed op de uitvoeringstijd van het algoritme.

Je kan onderstaande code uitvoeren met het commando `yarn tsx src/testpw.ts`.

<!-- cSpell: disable -->

```ts
process.env.NODE_CONFIG = JSON.stringify({
  env: 'development',
});

import { hashPassword, verifyPassword } from './core/password';

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
  console.log('');

  valid = await verifyPassword(wrongPassword, hash);
  console.log(
    'The password',
    wrongPassword,
    'is',
    valid ? 'valid' : 'incorrect',
  );
}

main();
```

?> Het is niet de bedoeling om dit script in je eigen repository te houden! Dit is enkel om te testen of je code werkt, gooi het weg na gebruik.

<!-- cSpell: enable -->

### Wachtwoord opslaan in de databank

Om te kunnen aanmelden, moeten we extra informatie van onze gebruikers opslaan: o.a. een e-mailadres en een wachtwoord. We voegen deze informatie toe aan onze User entiteit in het Prisma schema. We voegen ook een unique index toe op het e-mailadres, zodat we geen twee gebruikers met hetzelfde e-mailadres kunnen hebben.

```prisma
// src/data/schema.prisma
// ...

model User {
  @@map("users")               // Set the table name to "users"

  id            Int            @id @default(autoincrement()) @db.UnsignedInt
  name          String         @db.VarChar(255)
  email         String         @unique(map: "idx_user_email_unique") @db.VarChar(255)
  password_hash String         @db.VarChar(255)
  roles         Json
  transactions  Transaction[]
}
```

Vervolgens maken we een nieuwe migratie:

```bash
yarn prisma migrate dev --name addAuthInfoToUserTable
```

Pas de **seed** voor `users` aan met deze code. Deze seed stelt voor elke user het wachtwoord `12345678` in. Als rollen wordt `user` en/of `admin` toegekend.

<!-- cSpell: disable -->

```ts
// ... (imports)
import { hashPassword } from '../core/password';

const prisma = new PrismaClient();

async function main() {
  // Seed users
  // ==========
  const passwordHash = await hashPassword('12345678');

  await prisma.user.createMany({
    data: [
      {
        id: 1,
        name: 'Thomas Aelbrecht',
        email: 'thomas.aelbrecht@hogent.be',
        password_hash: passwordHash,
        roles: ['admin', 'user'],
      },
      {
        id: 2,
        name: 'Pieter Van Der Helst',
        email: 'pieter.vanderhelst@hogent.be',
        password_hash: passwordHash,
        roles: ['user'],
      },
      {
        id: 3,
        name: 'Karine Samyn',
        email: 'karine.samyn@hogent.be',
        password_hash: passwordHash,
        roles: ['user'],
      },
    ],
  });
  // ...
}

// ...
```

<!-- cSpell: enable -->

De extra kolommen hebben als gevolg dat de user service nu ook een `email`, `password` (geen hash!) en `roles` verwacht als parameter bij `create`.

We passen eerst het type aan en voegen meteen een type toe voor de publieke informatie van een gebruiker:

```ts
// src/types/user.ts
export interface UserCreateInput {
  name: string;
  email: string;
  password: string;
  roles: string[];
}

export interface PublicUser extends Pick<User, 'id' | 'name' | 'email'> {}
```

En vervolgens passen we de user service aan. We hernoemen ook de `create` functie naar `register`:

```ts
// src/service/user.ts
// ... (imports)
import type {
  // ...
  PublicUser, // 👈 1
} from '../types/user';
import { hashPassword } from '../core/password'; // 👈 3

// 👇 1
const makeExposedUser = ({ id, name, email }: UserRecord): PublicUser => ({
  id,
  name,
  email,
});

export const register = async ({
  name,
  email, // 👈 2
  password, // 👈 2
  roles, // 👈 2
}: UserCreateInput): Promise<User> => {
  try {
    const passwordHash = await hashPassword(password); // 👈 3

    // 👇 3
    const user = await prisma.user.create({
      data: {
        name,
        email,
        password,
        roles: ['user'], // 👈 4
      },
    });

    return makeExposedUser(user); // 👈 5
  } catch (error) {
    throw handleDBError(error); // 👈 6
  }
};
// ...
```

1. We voegen een functie toe die een `UserRecord` omvormt naar een `PublicUser`. Deze functie zal gebruikt worden om enkel de publieke informatie van een gebruiker terug te geven.
2. We voegen de nieuwe kolommen toe als parameter.
3. We maken een hash van het wachtwoord voor we de gebruiker aanmaken.
4. Standaard maken we nieuwe gebruikers enkel `user`.
5. We geven enkel de publieke informatie van de gebruiker terug.
6. We wrappen alles in een try/catch en gebruiken de `handleDBError` functie om de fouten af te handelen.

### Oefening 1

- Pas de andere functies in user service aan waar nodig.
- Pas ook de REST-laag van de users aan waar nodig.

- Oplossing +

  TODO: voorbeeldoplossing toevoegen

## Aanmelden

We definiëren alle rollen in onze applicatie in een constant object. Zo is het eenvoudig om ze te wijzigen indien nodig. Voeg onderstaande code toe aan `src/core/roles.ts`

```ts
// src/core/roles.ts

export default {
  USER: 'user',
  ADMIN: 'admin',
};
```

We updaten de **seed voor users** met deze nieuwe rollen:

<!-- cSpell: disable -->

```ts
// src/data/seed.ts
// ... (imports)
import Role from '../core/roles'; // 👈

const prisma = new PrismaClient();

async function main() {
  // Seed users
  // ==========
  const passwordHash = await hashPassword('12345678');

  await prisma.user.createMany({
    data: [
      {
        id: 1,
        name: 'Thomas Aelbrecht',
        email: 'thomas.aelbrecht@hogent.be',
        password_hash: passwordHash,
        roles: JSON.stringify([Role.ADMIN, Role.USER]), // 👈
      },
      {
        id: 2,
        name: 'Pieter Van Der Helst',
        email: 'pieter.vanderhelst@hogent.be',
        password_hash: passwordHash,
        roles: JSON.stringify([Role.USER]), // 👈
      },
      {
        id: 3,
        name: 'Karine Samyn',
        email: 'karine.samyn@hogent.be',
        password_hash: passwordHash,
        roles: JSON.stringify([Role.USER]), // 👈
      },
    ],
  });

  // ...
}

// ...
```

<!-- cSpell: enable -->

Pas in de user service ook de hard gecodeerde rol in de `register` functie aan.

We definiëren eerst een type voor het request en response van onze login API call:

```ts
// src/types/user.ts
export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  user: PublicUser;
  token: string;
}
```

We definiëren een functie `login` in `src/service/user.ts` die een gebruiker met een bepaald e-mailadres probeert aan te melden. Als de gebruiker is aangemeld, retourneren we het token en de publieke informatie van de gebruiker (id, naam, e-mail en rollen):

```ts
// src/service/user.ts
// ... (imports)
import type {
  // ...
  LoginResponse, // 👈 1
} from '../types/user';
import { hashPassword, verifyPassword } from '../core/password'; // 👈 4
import { generateJWT } from '../core/jwt'; // 👈 7

// 👇 6
const makeLoginData = async (user: UserRecord): Promise<LoginResponse> => {
  const token = await generateJWT(user); // 👈 7

  // 👇 8
  return {
    user: makeExposedUser(user),
    token,
  };
};

// 👇 1
export const login = async (
  email: string,
  password: string,
): Promise<LoginResponse> => {
  const user = await prisma.user.findUnique({ where: { email } }); // 👈 2

  // 👇 3
  if (!user) {
    // DO NOT expose we don't know the user
    throw ServiceError.unauthorized(
      'The given email and password do not match',
    );
  }

  // 👇 4
  const passwordValid = await verifyPassword(password, user.password_hash);

  // 👇 5
  if (!passwordValid) {
    // DO NOT expose we know the user but an invalid password was given
    throw ServiceError.unauthorized(
      'The given email and password do not match',
    );
  }

  return await makeLoginData(user); // 👈 6
};
```

1. De functie `login` krijgt een e-mailadres en wachtwoord als parameter en geeft een `LoginResponse` terug.
2. We kijken eerst of er een gebruiker met dit e-mailadres bestaat.
3. Als die gebruiker niet bestaat, doen we alsof het e-mailadres en wachtwoord niet matchen. We willen niet laten blijken dat we de gebruiker kennen.
4. Als we een gebruiker hebben, verifiëren we het opgegeven wachtwoord met de opgeslagen hash.
5. Als het wachtwoord fout is, zeggen we opnieuw dat het e-mailadres en wachtwoord niet matchen.
6. Vervolgens maken we de data die geretourneerd moet worden na login. We maken hiervoor een helperfunctie aangezien we diezelfde data ook nodig hebben bij het registreren.
7. Eerst maken we een JWT voor die gebruiker.
8. Vervolgens retourneren we de token en enkel de velden van de user die publiek zijn.
9. Vergeet ook de `login` functie niet te exporteren.

Vervolgens voegen we een nieuw bestand `src/rest/session.ts` toe voor de login route.

```ts
// src/rest/session.ts
import Router from '@koa/router';
import Joi from 'joi';
import validate from '../core/validation';
import { userService } from '../service';
import type {
  KoaContext,
  LoginResponse,
  LoginRequest,
  KoaRouter,
  BudgetAppState,
  BudgetAppContext,
} from '../types';

// 👇 1
const login = async (ctx: KoaContext<LoginResponse, void, LoginRequest>) => {
  // 👇 2
  const { email, password } = ctx.request.body;
  const token = await userService.login(email, password); // 👈 3

  // 👇 4
  ctx.status = 200;
  ctx.body = token;
};
// 👇 5
login.validationScheme = {
  body: {
    email: Joi.string().email(),
    password: Joi.string(),
  },
};

// 👇 6
export default function installSessionRoutes(parent: KoaRouter) {
  const router = new Router<BudgetAppState, BudgetAppContext>({
    prefix: '/sessions',
  });

  router.post('/', validate(login.validationScheme), login);

  parent.use(router.routes()).use(router.allowedMethods());
}
```

1. We definiëren een functie voor onze `login` route.
2. We halen het e-mailadres en wachtwoord uit de HTTP body.
3. We proberen de gebruiker aan te melden.
4. Als dat gelukt is, stellen we de HTTP statuscode in en geven we de token-informatie mee in de HTTP response body.
5. We voorzien ook een validatieschema voor de input.
6. We definiëren een nieuwe router en de route voor de login (inclusief de invoervalidatie).

Als laatste voegen we deze nieuwe router toe aan onze applicatie in `src/rest/index.ts`:

```ts
// src/rest/index.ts
// ... (imports)
import installSessionRoutes from './session';

export default function installRoutes(app: KoaApplication) {
  // ... (router aanmaken + routes installeren)
  installSessionRoutes(router);

  // ... (router in app plaatsen)
}
```

Waarom definiëren we een API call `POST /api/sessions` i.p.v. `POST /api/users/login`?

- Antwoord +

  Een API call moet altijd RESTful zijn. Dit betekent dat je geen werkwoorden of acties in je URL's steekt (dus ook geen `login`). Je werkt met resources en je voert acties uit op die resources. In dit geval is de resource een sessie en de actie is aanmelden. Daarom is `POST /api/sessions` correct en `POST /api/users/login` niet.

### Oefening 2

Pas ook de overige functies in de user service aan:

- `register` retourneert nu ook het token en de publieke user data.
- `getAll` en `getById` mogen enkel de publieke user data retourneren (dus zeker geen wachtwoorden!).

## Registreren

We overlopen hier nog eens de belangrijkste code van het registreerproces. In `src/service/user.ts` hebben we:

```ts
export const register = async ({
  name,
  email,
  password,
}: RegisterUserRequest): Promise<LoginResponse> => {
  // 👈 1
  try {
    const passwordHash = await hashPassword(password);

    const user = await prisma.user.create({
      data: {
        name,
        email,
        password_hash: passwordHash,
        roles: [Role.USER],
      },
    });

    // 👇 2
    if (!user) {
      throw ServiceError.internalServerError(
        'An unexpected error occured when creating the user',
      );
    }

    return await makeLoginData(user); // 👈 1
  } catch (error: any) {
    throw handleDBError(error);
  }
};
```

1. We retourneren hetzelfde response als bij het aanmelden.
2. We gooien een interne serverfout als de gebruiker niet gemaakt kon worden.

We bekijken ook nog eens de request handler voor het registreren in `src/rest/user.ts`:

```ts
const register = async (
  ctx: KoaContext<LoginResponse, void, RegisterUserRequest>,
) => {
  const token = await userService.register(ctx.request.body); // 👈 1

  // 👇 2
  ctx.status = 200;
  ctx.body = token;
};
// 👇 3
register.validationScheme = {
  body: {
    name: Joi.string().max(255),
    email: Joi.string().email(),
    password: Joi.string().min(12).max(128),
  },
};

module.exports = function installUsersRoutes(app) {
  // ...
  router.post('/', validate(register.validationScheme), register); // 👈 4
  // ...
};
```

1. We registreren de nieuwe gebruiker (alle informatie zit in de HTTP body). We krijgen de token-informatie en publieke user informatie terug.
2. We retourneren deze token-informatie en publieke user informatie in de HTTP response body, evenals een statuscode 200.
3. We voorzien ook een validatieschema voor de input. We vereisen een wachtwoord van minimum 12 karakters en maximum 128 karakters.
4. We geven deze functie mee aan de POST op `/api/users` en doen ook de invoervalidatie.
   - Merk op: we gebruiken niet `POST /api/users/register` omdat dit geen RESTful route is. Je mag nl. geen werkwoorden of acties in je URL's steken.

## Helpers voor authenticatie/autorisatie

We definiëren een module `src/core/auth.ts` die twee helpers exporteert.

- De eerste helper dwingt af dat de gebruiker moet aangemeld zijn om een endpoint uit te voeren. Dit is een middleware.
- De tweede helper dwingt af dat de gebruiker de juiste rollen heeft om een endpoint uit te voeren. Deze helper geeft een middleware terug (= currying).

```ts
// src/core/auth.ts
import type { Next } from 'koa'; // 👈 1
import type { KoaContext } from '../types/koa'; // 👈 1
import { userService } from '../service'; // 👈 1

// 👇 1
export const requireAuthentication = async (ctx: KoaContext, next: Next) => {
  const { authorization } = ctx.headers; // 👈 3

  //  👇 4
  ctx.state.session = await userService.checkAndParseSession(authorization);

  return next(); // 👈 5
};

// 👇 6
export const makeRequireRole =
  (role: string) => async (ctx: KoaContext, next: Next) => {
    const { roles = [] } = ctx.state.session; // 👈 7

    userService.checkRole(role, roles); // 👈 8

    return next(); // 👈 9
  };
```

1. Importeer de nodige types voor de middleware, alsook de user service.
2. Een eerste helper dwingt af om aangemeld te zijn (= **authenticatie**).
3. We halen de `Authorization` header op.
4. We laten de user service deze token verifiëren en parsen, en verwachten sessie-informatie terug. We implementeren deze functie later. We slaan de sessie-informatie op in de `state` van de huidige `context`. In de `ctx.state` kan je bijhouden wat je wil.
   - Later passen we het type van de `ctx.state` aan zodat we correcte typechecking hebben.
5. We roepen de volgende middleware in de rij aan.
6. Een andere helper maakt een middleware die een bepaalde rol afdwingt (= **autorisatie**).
7. We halen de rollen uit de sessie-informatie.
   - **Merk op:** deze middleware vereist dat de `requireAuthentication` middleware reeds uitgevoerd is, let dus op de volgorde!!!
8. We laten de user service checken of de aangemelde gebruiker de vereiste rol heeft. We implementeren deze functie ook later.
9. Als laatste roepen we ook de volgende middleware in de rij aan.

Vervolgens definiëren we een nieuw type in `src/types/auth.ts`:

```ts
export interface SessionInfo {
  userId: number;
  roles: string[];
}
```

En passen we de `BudgetAppState` interface aan in `src/types/koa.ts`:

```ts
import type { SessionInfo } from './auth';

export interface BudgetAppState {
  session: SessionInfo;
}
```

Daarna definiëren we in `src/service/user.ts` een eerste functie om een JWT te verifiëren en te parsen:

```ts
// src/service/user.ts
import config from 'config'; // 👈 7
import { getLogger } from '../core/logging'; // 👈 4
import { generateJWT, verifyJWT } from '../core/jwt'; // 👈 5
import type { SessionInfo } from '../types/auth'; // 👈 1

// 👇 1
export const checkAndParseSession = async (
  authHeader?: string,
): Promise<SessionInfo> => {
  // 👇 2
  if (!authHeader) {
    throw ServiceError.unauthorized('You need to be signed in');
  }

  // 👇 3
  if (!authHeader.startsWith('Bearer ')) {
    throw ServiceError.unauthorized('Invalid authentication token');
  }

  // 👇 4
  const authToken = authHeader.substring(7);

  // 👇 5
  try {
    const { roles, sub } = await verifyJWT(authToken); // 👈 6

    // 👇 7
    return {
      userId: Number(sub),
      roles,
    };
  } catch (error: any) {
    // 👇 8
    getLogger().error(error.message, { error });

    // 👇 8
    if (error instanceof jwt.TokenExpiredError) {
      throw ServiceError.unauthorized('The token has expired');
    } else if (error instanceof jwt.JsonWebTokenError) {
      throw ServiceError.unauthorized(
        `Invalid authentication token: ${error.message}`,
      );
    } else {
      throw ServiceError.unauthorized(error.message);
    }
  }
};
```

1. We definiëren een functie die de sessie-informatie controleert en parset. Ze krijgt de `Authorization` header mee en retourneert de sessie-informatie.
2. Als er geen header meegegeven werd aan het request, gooien we een gepaste fout.
3. Indien de header niet start met "Bearer " gooien we ook een gepast fout, dit moet zo per definitie.
4. Vervolgens verwijderen we de "Bearer " van de token, zo hebben we enkel de JWT over.
5. We wrappen alles in een try-catch om de fouten nog eens afzonderlijk te loggen. Alle fouten die gegooid worden, hebben te maken met de geldigheid van de JWT (verlopen, ongeldig signature...)
6. We verifiëren de JWT. Als deze geldig is, dan krijgen we de payload van de token terug.
   - Merk op: de `sub` property van de payload bevat de id van de gebruiker maar als string. We zetten deze om naar een getal.
7. Als laatste retourneren we alle sessie-informatie: het id van de gebruiker en de rollen.
8. Als er een fout optreedt, loggen we deze alvast.
9. We proberen de fout om te vormen naar een gepaste foutmelding. Als de token verlopen is, geven we een andere foutmelding dan als de token ongeldig is. We kunnen dit afleiden uit het type van de fout.

De laatste functie in de user service zal checken of een gegeven rol in de array van rollen voorkomt. De array bevat alle rollen van de gebruiker (uit de JWT payload gehaald). De functie geeft niets terug, maar gooit een gepaste fout als de rol niet voorkomt.

```ts
// src/service/user.ts
export const checkRole = (role: string, roles: string[]): void => {
  const hasPermission = roles.includes(role); // 👈 1

  // 👇 2
  if (!hasPermission) {
    throw ServiceError.forbidden(
      'You are not allowed to view this part of the application',
    );
  }
};
```

1. Met de `includes` functie kunnen we controleren of de rol voorkomt in de array
2. Als de rol niet in de array voorkomt, wordt een forbidden fout geworpen. Die zal worden afgehandeld door onze middleware uit het vorige hoofdstuk.

### Auth middlewares toevoegen aan de REST-laag

Pas `src/rest/user.ts` als volgt aan:

```ts
// src/rest/user.ts
// ... (imports)
import { requireAuthentication, makeRequireRole } from '../core/auth'; // 👈 1
import Role from '../core/roles'; // 👈 4

export default function installUsersRoutes(parent: KoaRouter) {
  // ...

  const requireAdmin = makeRequireRole(Role.ADMIN); // 👈 3

  router.get(
    '/',
    requireAuthentication, // 👈 2
    requireAdmin, // 👈 3
    validate(getAllUsers.validationScheme),
    getAllUsers,
  );
  router.get(
    '/:id',
    requireAuthentication, // 👈 2
    validate(getUserById.validationScheme),
    getUserById,
  );
  router.put(
    '/:id',
    requireAuthentication, // 👈 2
    validate(updateUserById.validationScheme),
    updateUserById,
  );
  router.delete(
    '/:id',
    requireAuthentication, // 👈 2
    validate(deleteUserById.validationScheme),
    deleteUserById,
  );

  // ...
}
```

1. We importeren onze nieuwe middlewares.
2. En dwingen op elke andere route authenticatie af, we moeten dus aangemeld zijn.
   - Aangemeld zijn = `Authorization` header bevat een geldige JWT.
3. We willen ook de `GET /api/users` enkel toegankelijk maken voor admins. Daarom maken we een middleware die op deze rol checkt en voegen deze toe aan de route.

## Controleer of de aangemelde gebruiker toegang heeft tot de gegeven user info

We dienen nog te controleren of de aangemelde gebruiker wel toegang heeft tot de gevraagde user informatie. Enkel de admin en de gebruiker zelf heeft daartoe toegang.

Voeg toe aan `src/rest/user.ts`:

```ts
// src/rest/user.ts

// 👇
const checkUserId = (ctx: KoaContext<unknown, GetUserRequest>, next: Next) => {
  const { userId, roles } = ctx.state.session;
  const { id } = ctx.params;

  // You can only get our own data unless you're an admin
  if (id !== 'me' && id !== userId && !roles.includes(Role.ADMIN)) {
    return ctx.throw(
      403,
      "You are not allowed to view this user's information",
      { code: 'FORBIDDEN' },
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
  getUserById,
);
router.put(
  '/:id',
  requireAuthentication,
  validate(updateUserById.validationScheme),
  checkUserId, // 👈
  updateUserById,
);
router.delete(
  '/:id',
  requireAuthentication,
  validate(deleteUserById.validationScheme),
  checkUserId, // 👈
  deleteUserById,
);
```

We passen ook de `getUserById` functie aan in `src/rest/user.ts` zodat we `me` kunnen gebruiken om de informatie van de aangemelde gebruiker op te vragen:

```ts
const getUserById = async (
  ctx: KoaContext<GetUserByIdResponse, GetUserRequest>,
) => {
  // 👇
  const user = await userService.getById(
    ctx.params.id === 'me' ? ctx.state.session.userId : ctx.params.id,
  );
  ctx.status = 200;
  ctx.body = user;
};
getUserById.validationScheme = {
  params: { id: [Joi.number().integer().positive(), 'me'] }, // 👈
};
```

Hierdoor moeten we ook het type van `GetUserRequest` aanpassen in `src/types/user.ts`:

```ts
// src/types/user.ts

export interface GetUserRequest {
  id: number | 'me'; // 👈
}
```

## Willekeurige vertragingsfunctie

Om zogenaamde [timing attacks](https://en.wikipedia.org/wiki/Timing_attack) te voorkomen, kunnen we een willekeurige vertragingsfunctie toevoegen aan onze authenticatie. Deze functie wacht een willekeurige tijd vooraleer het request effectief te verwerken. Zo kan een aanvaller niet aan de hand van de responstijd afleiden of een wachtwoord correct is of niet.

We voegen een nieuwe middleware-functie toe aan `src/core/auth.ts`:

```ts
// src/core/auth.ts
import config from 'config'; // 👈 1

const AUTH_MAX_DELAY = config.get<number>('auth.maxDelay'); // 👈 1

// 👇 2
export const authDelay = async (_: KoaContext, next: Next) => {
  // 👇 3
  await new Promise((resolve) => {
    const delay = Math.round(Math.random() * AUTH_MAX_DELAY);
    setTimeout(resolve, delay);
  });
  // 👇 4
  return next();
};
```

1. We importeren de configuratie en halen de maximale vertraging op.
   - Voeg zelf `auth.maxDelay` toe aan elk configuratiebestand. Stel dit default in op 5000 ms (= 5 seconden).
2. We definiëren een middleware die een willekeurige vertraging toevoegt aan het request. De vertraging is tussen 0 en de maximale vertraging.
3. We maken een Promise die na een willekeurige tijd opgelost wordt.
4. We roepen de volgende middleware in de rij aan wanneer de Promise afgelopen is en de vertraging dus voorbij is.

Voeg vervolgens deze middleware toe aan het request voor registreren in `src/rest/user.ts`:

```ts
// src/rest/user.ts
import {
  // ...
  authDelay, // 👈
} from '../core/auth';

// ...

router.post('/', authDelay, validate(register.validationScheme), register); // 👈
```

Herhaal hetzelfde voor de login route in `src/rest/session.ts`:

```ts
import { authDelay } from '../core/auth'; // 👈

// ...

router.post('/', authDelay, validate(login.validationScheme), login); // 👈
```

## Opmerking

In de praktijk wil je liever externe services gebruiken voor authenticatie en autorisatie. Dit geeft minder problemen met o.a. veiligheid, GDPR... Authenticatie en autorisatie is ook altijd hetzelfde!

Voorbeelden zijn [Auth0](https://auth0.com/), [Userfront](https://userfront.com/), [SuperTokens (open source)](https://supertokens.com/), [Amazon Cognito](https://aws.amazon.com/cognito/)...

Bij Web Services zie je hoe je manueel authenticatie en autorisatie kan implementeren. Bij Enterprise Web Development: C# zal je zien hoe je hiervoor Auth0 kan gebruiken.

## Oefening 3 - Authenticatie

- Scherm de routes van de places af, authenticatie is vereist.
- Doe hetzelfde voor de transactions. Pas, indien nodig, ook de andere lagan aan.
- `GET /api/transactions` mag enkel de transacties van de aangemelde gebruiker retourneren, niet langer alle transacties. Pas ook de servicelaag aan.
- `GET /api/transactions/:id` retourneert de transactie met opgegeven id, maar dit mag enkel indien de transactie behoort tot de aangemelde gebruiker.
- `POST /api/transactions`: de `userId` van de te creëren transactie is de id van de aangemelde gebruiker. Dit geldt ook voor de `PUT /api/transactions/:id`.
- `DELETE /api/transactions/:id`: verwijder enkel transacties van de aangemelde gebruiker.

- Oplossing +

  TODO: voorbeeldoplossing toevoegen

## Extra's voor de examenopdracht

- Gebruik van een externe authenticatieprovider (bv. [Auth0](https://auth0.com/), [Userfront](https://userfront.com/)...)
- Gebruik [Passport.js](https://www.passportjs.org/) voor authenticatie en integreer met bv. aanmelden via Facebook, Google...
- Schrijf een custom validator voor Joi om de sterkte van een wachtwoord te controleren, gebruik bv. [zxcvbn](https://www.npmjs.com/package/zxcvbn)
  - Dit is een vrij kleine extra, dus zorg ervoor dat je nog een andere extra toevoegt.
