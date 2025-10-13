# Authenticatie en autorisatie (WIP)

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les6 TODO:
> pnpm install
> pnpm db:migrate
> pnpm db:seed
> pnpm start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.

In dit hoofdstuk voegen we authenticatie en autorisatie toe aan onze applicatie:

- **Authenticatie** is het proces waarbij je controleert of iemand is wie hij zegt dat hij is. Dit gebeurt typisch door een gebruikersnaam en wachtwoord te vragen.
- **Autorisatie** is het proces waarbij je controleert of iemand de juiste rechten heeft om bepaalde acties uit te voeren of toegang te krijgen tot bepaalde gegevens.

In deze cursus zullen we deze twee concepten manueel implementeren maar in een echte applicatie gebruik je best een bestaande oplossing zoals [Passport.js](https://www.passportjs.org/) of een externe authenticatieprovider zoals [Auth0](https://auth0.com/) of [Userfront](https://userfront.com/). Door dit toch eens manueel te implementeren, leer je beter hoe het allemaal werkt.

## JWT

[JSON Web Token (JWT)](https://jwt.io/introduction) zijn tokens die typisch worden gebruikt om sessie-informatie door te geven tussen client-server, bv. welke gebruiker aangemeld is, welke rollen/permissies die heeft, hoe lang hij aangemeld mag blijven... Het is een open standaard.

De JWT bevat alle gegevens in plain text, maar geëncodeerd als `base64url` string. De inhoud van een JWT kan je bekijken op <https://jwt.io>. De JWT wordt per request doorgestuurd in de `Authorization` header met als prefix **"Bearer "**.

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

De signature is wat een JWT veilig maakt. Het neemt de info uit de header, samen met een _secret_ om zo de payload te ondertekenen. Het is niet meer dan een handtekening die aangeeft of de payload gewijzigd is. Als iemand de payload wijzigt, zal de signature anders zijn en wordt de token als ongeldig beschouwd.

## User uitbreiden

Voor we aan de slag gaan, breiden we onze `users` tabel uit met een paar extra kolommen:

- `email`: het e-mailadres van de gebruiker, dit moet uniek zijn
- `password_hash`: de hash van het wachtwoord van de gebruiker
- `roles`: JSON-kolom met een lijst van rollen die de gebruiker heeft, bv. `user`, `admin`, ...

```ts
// src/drizzle/schema.ts
export const users = mysqlTable(
  'users',
  {
    id: int('id', { unsigned: true }).primaryKey().autoincrement(),
    name: varchar('name', { length: 255 }).notNull(),
    email: varchar('email', { length: 255 }).notNull(), // 👈
    passwordHash: varchar('password_hash', { length: 255 }).notNull(), // 👈
    roles: json('roles').notNull(), // 👈
  },
  (table) => [uniqueIndex('idx_user_email_unique').on(table.email)], // 👈
);
```

Maak vervolgens een nieuwe migratie aan en voer deze uit:

```bash
pnpm db:generate
pnpm db:migrate
```

## Wachtwoorden opslaan

We moeten onze wachtwoorden opslaan in de databank. We doen dit uiteraard niet in plain text. We **hashen** de wachtwoorden met [argon2](https://github.com/P-H-C/phc-winner-argon2). Dit is een van de nieuwste en beste hashing algoritmes voor o.a. wachtwoorden.

### Hashing: herhaling

Een hashing algoritme is een one-way algoritme. Het neemt een input en vormt deze om naar een output met een vast aantal bits. Als de input wijzigt, moet de output significant en willekeurig genoeg wijzigen. Zo kan je de bewerking niet omgekeerd doen en achterhalen wat de input was. Dit is net wat we willen om wachtwoorden op te slaan.

### Hashing: salt

Sommige hashing algoritmes gebruiken een **salt**. Dit is een willekeurig string (met vaste lengte) en wordt gebruikt om een verschillende hash te genereren bij een identieke input. Dus: hetzelfde wachtwoord hashen met een andere salt, geeft een andere hash. Dit maakt bv. [dictionary attacks](https://www.sciencedirect.com/topics/computer-science/dictionary-attack) moeilijker.

### Seed uitbreiden

Als voorbeeld van hashing breiden we de gebruikers in onze seed uit met een aantal gebruikers met een gehashte wachtwoord:

```ts
// src/drizzle/seed.ts
// ...
import argon2 from 'argon2'; // 👈 2

// 👇 1
async function hashPassword(password: string): Promise<string> {
  // 👇 2
  return argon2.hash(password, {
    type: argon2.argon2id, // 👈 3
    hashLength: 32, // 👈 4
    timeCost: 2, // 👈 5
    memoryCost: 2 ** 16, // 👈 6
  });
}

// ...

async function seedUsers() {
  console.log('👥 Seeding users...');

  // 👇 7
  const passwordHash = await hashPassword('12345678');
  await db.insert(schema.users).values([
    {
      id: 1,
      name: 'Thomas Aelbrecht',
      email: 'thomas.aelbrecht@hogent.be', // 👈 9
      passwordHash: passwordHash, // 👈 8
      roles: [Role.ADMIN, Role.USER], // 👈 9
    },
    {
      id: 2,
      name: 'Pieter Van Der Helst',
      email: 'pieter.vanderhelst@hogent.be', // 👈 9
      passwordHash: passwordHash, // 👈 8
      roles: [Role.USER], // 👈 9
    },
    {
      id: 3,
      name: 'Karine Samyn',
      email: 'karine.samyn@hogent.be', // 👈 9
      passwordHash: passwordHash, // 👈 8
      roles: [Role.USER], // 👈 9
    },
  ]);

  console.log('✅ Users seeded successfully\n');
}

// ...
```

1. We definiëren een functie `hashPassword` die een wachtwoord als string neemt en een gehashte versie teruggeeft.
2. We importeren de `argon2` bibliotheek.
3. We gebruiken het `argon2id` algoritme, een combinatie van `argon2i` en `argon2d`, en is momenteel de aanbevolen variant.
4. We vragen een hash van 32 bytes.
5. `timeCost` bepaalt hoeveel iteraties het algoritme moet uitvoeren. Dit verhoogt de tijd die nodig is om de hash te berekenen.
6. `memoryCost` bepaalt hoeveel geheugen (in KiB) het algoritme gebruikt. Dit maakt het moeilijker om de hash te berekenen met gespecialiseerde hardware.
7. We hashen het wachtwoord `12345678` en gebruiken deze voor alle gebruikers in de seed.
8. We slaan de gehashte versie van het wachtwoord op in de kolom `password_hash`.
9. We voegen een e-mailadres en rollen toe aan elke gebruiker. Drizzle zal automatisch de JSON-string genereren voor de `roles` kolom.

Test de seed uit:

```bash
pnpm db:seed
```

> **Oplossing voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les6-opl TODO:
> pnpm install
> pnpm db:migrate
> pnpm db:seed
> pnpm start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.

## Extra's voor de examenopdracht

- Gebruik [Passport.js](https://www.passportjs.org/) voor authenticatie en integreer met bv. aanmelden via Facebook, Google...
- Gebruik van een externe authenticatieprovider (bv. [Auth0](https://auth0.com/), [Userfront](https://userfront.com/)...)
- Schrijf een custom validator voor Joi om de sterkte van een wachtwoord te controleren, gebruik bv. [zxcvbn](https://www.npmjs.com/package/zxcvbn)
  - Dit is een vrij kleine extra, dus zorg ervoor dat je nog een andere extra toevoegt.
