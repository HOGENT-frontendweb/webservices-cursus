# Authenticatie en autorisatie

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les7 bd9ccc9
> pnpm install
> docker compose up -d
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

Als voorbeeld van hashing breiden we de gebruikers in onze seed uit met een aantal gebruikers met een gehashte wachtwoord. Installeer hiervoor eerst `argon2`:

```bash
pnpm install argon2
```

Sta via `pnpm approve-builds` toe om `argon2` te builden.

Breid vervolgens de `seed.ts` uit om `12345678` te hashen als wachtwoord voor elke gebruiker:

```ts
// src/drizzle/seed.ts
// ...
import * as argon2 from 'argon2'; // 👈 2

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
  await db.insert(schema.users).values([
    {
      id: 1,
      name: 'Thomas Aelbrecht',
      email: 'thomas.aelbrecht@hogent.be', // 👈 9
      passwordHash: await hashPassword('12345678'), // 👈 8
      roles: ['admin', 'user'], // 👈 9
    },
    {
      id: 2,
      name: 'Pieter Van Der Helst',
      email: 'pieter.vanderhelst@hogent.be', // 👈 9
      passwordHash: await hashPassword('12345678'), // 👈 8
      roles: ['user'], // 👈 9
    },
    {
      id: 3,
      name: 'Karine Samyn',
      email: 'karine.samyn@hogent.be', // 👈 9
      passwordHash: await hashPassword('12345678'), // 👈 8
      roles: ['user'], // 👈 9
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

Voer de seed uit:

```bash
pnpm db:seed
```

### Opbouw argon2 hash

Bekijk de `users` tabel in je databank om te zien hoe de gehashte wachtwoorden eruit zien. Je ziet dat elke gebruiker hetzelfde wachtwoord heeft, maar de hash is verschillend door het gebruik van een salt. De string die `argon2` genereert ziet er als volgt uit:

<!-- cspell: disable -->

<span style="text-wrap: wrap; word-wrap: break-word;">
  $<span style="color: #fb015b;">argon2id</span>$<span style="color: #00d26a;">v=19</span>$<span style="color: #d63aff;">m=65536,t=2,p=4</span>$<span style="color: #00b9f1;">YYOem9akI1o5UkMkl54yxQ</span>$<span style="color: #ffb700;">BcVhh8Hlh/xfCJxQH4JzO84OeNvoyyYWfKUqrOfM+Js</span>
</span>

<!-- cspell: enable -->

De argon2 hash bestaat uit 5 delen, gescheiden door `$`:

- <span style="color: #fb015b;">algoritme</span>: `argon2id` variant
- <span style="color: #00d26a;">versie</span>: versie 19
- <span style="color: #d63aff;">parameters</span>: `m` (memory cost in KiB), `t` (time cost), `p` (parallelism)
- <span style="color: #00b9f1;">salt</span>: willekeurige bytes in base64 encoding
- <span style="color: #ffb700;">hash</span>: de eigenlijke gehashte waarde in base64 encoding

> **Waarom wordt die informatie in de hash opgeslagen?**
>
> De parameters die gebruikt zijn om de hash te genereren, worden samen met de hash opgeslagen. Dit maakt het mogelijk om later het wachtwoord te verifiëren zonder dat je deze parameters apart moet opslaan.
>
> Dit geeft ook de mogelijkheid om in de toekomst de parameters aan te passen (bv. hogere `timeCost` of `memoryCost`) zonder dat je de bestaande hashes onbruikbaar maakt.

## Publieke user data

We willen niet dat gevoelige informatie zoals `passwordHash` en `roles` naar de client gestuurd worden. Daarom passen we onze DTO aan zodat die enkel de publieke informatie van een gebruiker bevat.

### PublicUserResponseDto

We passen onze `PublicUserResponseDto` aan zodat die enkel de publieke velden van een gebruiker bevat:

```ts
// src/user/user.dto.ts
import { Expose } from 'class-transformer'; // 👈 1

export class PublicUserResponseDto {
  @Expose() // 👈 2
  id: number;

  @Expose() // 👈 2
  name: string;

  @Expose() // 👈 2
  email: string;
}
```

1. We importeren de `Expose` decorator van `class-transformer`. Deze decorator markeert welke velden wel naar de client gestuurd mogen worden.
2. We markeren de velden `id`, `name` en `email` als publiek met de `@Expose()` decorator.

### plainToInstance gebruiken

In de `UserService` gebruiken we `plainToInstance` om een gebruiker object om te vormen naar een `PublicUserResponseDto`:

```ts
// src/user/user.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { PublicUserResponseDto } from './user.dto';
import { plainToInstance } from 'class-transformer'; // 👈 1
import { DatabaseProvider, InjectDrizzle } from '../drizzle/drizzle.provider';
import { users } from '../drizzle/schema';
import { eq } from 'drizzle-orm';

@Injectable()
export class UserService {
  constructor(
    @InjectDrizzle()
    private readonly db: DatabaseProvider,
  ) {}

  async getById(id: number): Promise<PublicUserResponseDto> {
    const user = await this.db.query.users.findFirst({
      where: eq(users.id, id),
    });
    if (!user) {
      throw new NotFoundException('No user with this id exists');
    }

    // 👇 2
    return plainToInstance(PublicUserResponseDto, user, {
      excludeExtraneousValues: true, // 👈 3
    });
  }

  // ... andere functies
}
```

1. We importeren `plainToInstance` van `class-transformer`.
2. We gebruiken `plainToInstance` om het gebruiker object om te vormen naar een `PublicUserResponseDto`.
   - Pas ook het returntype van de functie aan naar `Promise<PublicUserResponseDto>`.
3. De optie `excludeExtraneousValues: true` zorgt ervoor dat enkel de velden met `@Expose()` worden meegenomen in het resultaat. Alle andere velden (zoals `passwordHash` en `roles`) worden **niet** meegestuurd naar de client.

> **Waarom is dit belangrijk?**
>
> Door `plainToInstance` te gebruiken met `excludeExtraneousValues: true`, zorgen we ervoor dat gevoelige informatie zoals wachtwoorden en rollen **nooit** naar de client gestuurd worden. Dit is een belangrijke beveiligingsmaatregel.
>
> Zonder deze transformatie zou de volledige gebruiker (inclusief `passwordHash` en `roles`) naar de client gestuurd worden, wat een groot veiligheidsrisico is!

Pas alle functies in de `UserService` aan zodat ze `plainToInstance` gebruiken om enkel publieke user data terug te geven:

```ts
// src/user/user.service.ts
export class UserService {
  // ... constructor

  async getAll(): Promise<UserListResponseDto> {
    const usersList = await this.db.query.users.findMany();
    const items = usersList.map((user) =>
      plainToInstance(PublicUserResponseDto, user, {
        excludeExtraneousValues: true,
      }),
    );
    return { items };
  }

  async updateById(
    id: number,
    changes: UpdateUserRequestDto,
  ): Promise<PublicUserResponseDto> {
    const [result] = await this.db
      .update(users)
      .set(changes)
      .where(eq(users.id, id));

    if (result.affectedRows === 0) {
      throw new NotFoundException('No user with this id exists');
    }

    return this.getById(id);
  }
}
```

Voorlopig negeer je de fout in de `create` functie uit de `UserService`. We zullen gebruikers later aanmaken via een `register` functie in de `AuthService`. Pas ook de `UserController` en `UserListResponseDto` aan waar nodig.

## Configuratie voor authenticatie

We voegen de instellingen voor authenticatie, nl. het hashen van het password en het aanmaken, verifiëren van een JWT token toe aan ons configuratiebestand:

```ts
// src/config/configuration.ts
export default () => ({
  // ... andere configuratie
  auth: {
    hashLength: parseInt(process.env.AUTH_HASH_LENGTH || '32'), // 👈 1
    timeCost: parseInt(process.env.AUTH_HASH_TIME_COST || '6'), // 👈 2
    memoryCost: parseInt(process.env.AUTH_HASH_MEMORY_COST || '65536'), // 👈 3
    jwt: {
      expirationInterval:
        Number(process.env.AUTH_JWT_EXPIRATION_INTERVAL) || 3600, // 👈 4
      secret: process.env.AUTH_JWT_SECRET || '', // 👈 5
      audience: process.env.AUTH_JWT_AUDIENCE || 'budget.hogent.be', // 👈 6
      issuer: process.env.AUTH_JWT_ISSUER || 'budget.hogent.be', // 👈 7
    },
  },
});

// ...

export interface JwtConfig {
  expirationInterval: number;
  secret: string;
  audience: string;
  issuer: string;
}

export interface AuthConfig {
  hashLength: number;
  timeCost: number;
  memoryCost: number;
  jwt: JwtConfig;
}

export interface ServerConfig {
  // ...
  auth: AuthConfig;
}
```

1. `hashLength`: onze hash moet 32 bytes groot zijn (256 bits)
2. `timeCost`: we laten het hashing algoritme 6 iteraties uitvoeren
3. `memoryCost`: elke thread van het algoritme mag 65536 KiB (64 MiB) gebruiken
4. `expirationInterval`: onze JWT's zullen verlopen na 3600 seconden (1 uur)
5. `secret`: het geheim waarmee de JWT ondertekend wordt
6. `audience`: welke servers de token mogen accepteren
7. `issuer`: welke server(s) de token uitgeven

De laatste twee opties (`timeCost` en `memoryCost`) bepalen de duur van de hashing: hoe groter deze getallen, hoe langer het duurt. Langer is altijd beter, maar je applicatie moet natuurlijk nog bruikbaar blijven.

> ⚠️ **Belangrijk**: We geven het JWT secret op via een environment variable en zetten dit **nooit** in de code.

Voeg de volgende environment variable toe aan je `.env` bestand:

```env
AUTH_JWT_SECRET=eensuperveiligsecretvoorindevelopment
```

Je kan eventueel aanvullen met andere environment variables zoals we in de configuratie hierboven gedefinieerd hebben.

## Oefening - README eigen project

Vul de README van je eigen project aan met de nodige documentatie over de environment variables voor authenticatie.

## Rollen definiëren

We definiëren alle rollen in onze applicatie in een enum. Zo is het eenvoudig om ze te wijzigen indien nodig:

```ts
// src/auth/roles.ts
export enum Role {
  USER = 'user',
  ADMIN = 'admin',
}
```

Importeer de `Role` enum in de seed en gebruik deze om rollen toe te wijzen aan gebruikers:

```ts
// src/drizzle/seed.ts
// ...
import { Role } from '../auth/roles'; // 👈
// ...

async function seedUsers() {
  console.log('👥 Seeding users...');

  await db.insert(schema.users).values([
    {
      id: 1,
      name: 'Thomas Aelbrecht',
      email: 'thomas.aelbrecht@hogent.be',
      passwordHash: await hashPassword('12345678'),
      roles: [Role.ADMIN, Role.USER], // 👈
    },
    {
      id: 2,
      name: 'Pieter Van Der Helst',
      email: 'pieter.vanderhelst@hogent.be',
      passwordHash: await hashPassword('12345678'),
      roles: [Role.USER], // 👈
    },
    {
      id: 3,
      name: 'Karine Samyn',
      email: 'karine.samyn@hogent.be',
      passwordHash: await hashPassword('12345678'),
      roles: [Role.USER], // 👈
    },
  ]);

  console.log('✅ Users seeded successfully\n');
}
```

## Authentication module en service

We maken een `AuthModule` en een `AuthService` die alle authenticatie-logica bevat:

```bash
nest generate module auth
nest generate service auth --no-spec
```

Controlleer of de `AuthService` in de `AuthModule` is geregistreerd en de `AuthModule` geïmporteerd wordt in de `AppModule`.

### Service opzetten

De `AuthService` bevat functies voor:

- Wachtwoorden hashen en verifiëren
- JWT's aanmaken en verifiëren
- Gebruikers aanmelden (login)
- Gebruikers registreren (register)

Als eerste installeren we `@nestjs/jwt` zodat we JWT's kunnen ondertekenen en verifiëren:

```bash
pnpm install @nestjs/jwt
```

Neem de documentatie over [JWT tokens](https://docs.nestjs.com/security/authentication#jwt-token) door.

Vervolgens beginnen we met de basis van de service en de nodige imports:

```ts
// src/auth/auth.service.ts
import { Injectable } from '@nestjs/common';
import {
  type DatabaseProvider,
  InjectDrizzle,
} from '../drizzle/drizzle.provider'; // 👈 1
import { JwtService } from '@nestjs/jwt'; // 👈 2
import { ConfigService } from '@nestjs/config'; // 👈 3
import { ServerConfig } from '../config/configuration'; // 👈 3

@Injectable()
export class AuthService {
  constructor(
    @InjectDrizzle()
    private readonly db: DatabaseProvider, // 👈 1
    private readonly jwtService: JwtService, // 👈 2
    private readonly configService: ConfigService<ServerConfig>, // 👈 3
  ) {}

  // Functies komen hier...
}
```

1. We injecteren de database provider om gebruikers op te halen uit de database.
2. We injecteren de `JwtService` om JWT's te ondertekenen en verifiëren.
3. We injecteren de `ConfigService` om onze configuratie op te halen.

Importeer de `DrizzleModule` en de `JwtModule`, en exporteer de `AuthService` in de `AuthModule`:

```ts
import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { DrizzleModule } from '../drizzle/drizzle.module';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { ServerConfig, AuthConfig } from '../config/configuration';

@Module({
  imports: [
    // 👇 1
    JwtModule.registerAsync({
      inject: [ConfigService], // 👈 2
      global: true, // 👈 3
      useFactory: (configService: ConfigService<ServerConfig>) => {
        const authConfig = configService.get<AuthConfig>('auth')!; // 👈 4

        // 👇 5
        return {
          secret: authConfig.jwt.secret,
          signOptions: {
            expiresIn: `${authConfig.jwt.expirationInterval}s`,
            audience: authConfig.jwt.audience,
            issuer: authConfig.jwt.issuer,
          },
        };
      },
    }),
    DrizzleModule,
  ],
  providers: [AuthService],
  exports: [AuthService],
})
export class AuthModule {}
```

1. We importeren de `JwtModule` en configureren deze asynchroon met onze `AuthConfig`.
2. We injecteren de `ConfigService` om de configuratie op te halen.
3. We maken de module ook global zodat we deze niet in andere modules moeten importeren.
4. We halen onze authenticatie configuratie op.
5. We geven de nodige opties mee aan de `JwtModule`, opgehaald uit onze configuratie:
   - `secret`: het geheim waarmee de JWT ondertekend wordt
   - `signOptions`: opties voor het ondertekenen van de JWT, zoals vervaldatum, audience en issuer

### Wachtwoord hashen

We voegen een functie toe om wachtwoorden te hashen met argon2:

```ts
import * as argon2 from 'argon2'; // 👈 1
import { AuthConfig, ServerConfig } from '../config/configuration'; // 👈 2

// src/auth/auth.service.ts
export class AuthService {
  // ... constructor

  async hashPassword(password: string): Promise<string> {
    const authConfig = this.configService.get<AuthConfig>('auth')!; // 👈 2
    // 👇 3
    return argon2.hash(password, {
      type: argon2.argon2id,
      hashLength: authConfig.hashLength,
      timeCost: authConfig.timeCost,
      memoryCost: authConfig.memoryCost,
    });
  }
}
```

1. We importeren de `argon2` bibliotheek.
2. We vragen de `auth` configuratie op.
3. We gebruiken het `argon2id` algoritme, een combinatie van `argon2i` en `argon2d`, en is momenteel de aanbevolen variant. Daarnaast gebruiken we onze gedefinieerde configuratie.

### Wachtwoord verifiëren

We voegen een functie toe om wachtwoorden te verifiëren:

```ts
// src/auth/auth.service.ts
export class AuthService {
  // ... andere functies

  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return await argon2.verify(hash, password);
  }
}
```

De opties die gebruikt zijn bij het hashen zitten in de hash zelf, dus deze moeten niet meegegeven worden.

### JWT ondertekenen

We voegen een type toe voor de gebruikers in onze databank. We hergebruiken hiervoor types die Drizzle automatisch genereert:

```ts
// src/types/user.ts
import { users } from '../drizzle/schema';

export type User = typeof users.$inferInsert;
```

We voegen een private functie toe om een JWT te ondertekenen voor een gebruiker:

```ts
// src/auth/auth.service.ts
// ...
import { User } from '../types/user';

export class AuthService {
  // ... andere functies

  private signJwt(user: User): string {
    return this.jwtService.sign({
      sub: user.id,
      email: user.email,
      roles: user.roles,
    });
  }
}
```

1. We stoppen het gebruikers id, email en rollen in de JWT payload.
   - Hiervoor gebruiken we de `sub` claim voor het gebruikers id. Dit is een standaard claim in JWT's.
   - De overige velden zijn custom claims, die mag je zelf kiezen.
   - Let wel op: enkel controle op een rol doen in de frontend is niet voldoende. De backend moet altijd controleren of de gebruiker de actie mag uitvoeren.
2. De nodige opties mee om de JWT te ondertekenen dienen we niet mee te geven, want reeds doorgegeven bij de registratie van de `JwtModule`.

### JWT verifiëren

Definieer een type voor de payload van de JWT:

```ts
// src/types/auth.ts

export interface JwtPayload {
  sub: number;
  email: string;
  roles: string[];
}
```

We voegen een functie toe om een JWT te verifiëren:

```ts
// src/auth/auth.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';

export class AuthService {
  // ... andere functies

  async verifyJwt(token: string): Promise<JwtPayload> {
    const payload = await this.jwtService.verifyAsync<JwtPayload>(token);

    if (!payload) {
      throw new UnauthorizedException('Invalid authentication token');
    }

    return payload;
  }
}
```

Deze functie verifieert de JWT en geeft de payload terug. De nodige configuratie-opties zodat gecontroleerd wordt of deze JWT wel bedoeld is voor onze server, werden reeds meegegeven bij de registratie van de `JwtModule. Je kan nl. een JWT maken voor een andere server met een andere audience of issuer (eventueel hetzelfde secret).

Als de JWT ongeldig is, wordt een `UnauthorizedException` gegooid.

## Aanmelden

Aanmelden op onze API zal gebeuren via een `POST /api/sessions` endpoint. Daarvoor definiëren we eerst de nodige DTO's:

```ts
// src/session/session.dto.ts
import { IsEmail, IsString } from 'class-validator';

export class LoginRequestDto {
  @IsString()
  @IsEmail()
  email: string;

  @IsString()
  password: string;
}

export class LoginResponseDto {
  token: string;
}
```

We geven een e-mailadres en wachtwoord mee in de `LoginRequestDto` en krijgen een JWT token terug in de `LoginResponseDto`.

We voegen een `login` functie toe aan de `AuthService` die een gebruiker probeert aan te melden:

```ts
// src/auth/auth.service.ts
import { LoginRequestDto } from '../session/session.dto';
import { users } from '../drizzle/schema';
import { eq } from 'drizzle-orm';

export class AuthService {
  // ... andere functies

  async login({ email, password }: LoginRequestDto): Promise<string> {
    // 👇 1
    const user = await this.db.query.users.findFirst({
      where: eq(users.email, email),
    });

    // 👇 2
    if (!user) {
      throw new UnauthorizedException(
        'The given email and password do not match',
      );
    }

    // 👇 3
    const passwordValid = await this.verifyPassword(
      password,
      user.passwordHash,
    );

    // 👇 4
    if (!passwordValid) {
      throw new UnauthorizedException(
        'The given email and password do not match',
      );
    }

    return this.signJwt(user); // 👈 5
  }
}
```

1. We zoeken de gebruiker op basis van het e-mailadres.
2. Als de gebruiker niet bestaat, gooien we een `UnauthorizedException`. We willen niet laten blijken dat we de gebruiker kennen, dus we zeggen dat het e-mailadres en wachtwoord niet matchen.
3. Als de gebruiker bestaat, verifiëren we het wachtwoord.
4. Als het wachtwoord niet klopt, gooien we opnieuw een `UnauthorizedException` met dezelfde foutmelding.
5. Als alles klopt, ondertekenen we een JWT en geven deze terug.

Vervolgens maken we een controller voor de login route:

```bash
nest generate module session
nest generate controller session --no-spec
```

Controleer of de `SessionController` in de `SessionModule` is geregistreerd en de `SessionModule` geïmporteerd wordt in de `AppModule`.

Daarin definiëren we de `POST /api/sessions` route:

```ts
// src/sessions/sessions.controller.ts
import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from '../auth/auth.service';
import { LoginRequestDto, LoginResponseDto } from './session.dto';

@Controller('sessions') // 👈 1
export class SessionController {
  constructor(private authService: AuthService) {}

  @Post() // 👈 2
  async signIn(@Body() loginDto: LoginRequestDto): Promise<LoginResponseDto> {
    const token = await this.authService.login(loginDto); // 👈 3
    return { token }; // 👈 4
  }
}
```

1. De controller luistert naar requests op `/sessions`.
2. De route luistert naar POST requests op `/sessions`.
3. We roepen de `login` functie van de `AuthService` aan.
4. We geven de JWT token terug in een object.

> **Waarom definiëren we een API call `POST /api/sessions` i.p.v. `POST /api/users/login`?**
>
> Een API call moet altijd RESTful zijn. Dit betekent dat je geen werkwoorden of acties in je URL's steekt (dus ook geen `login`). Je werkt met resources en je voert acties uit op die resources. In dit geval is de resource een sessie en de actie is aanmelden. Daarom is `POST /api/sessions` correct en `POST /api/users/login` niet.

Importeer de `AuthModule` in de `SessionModule` zodat we de `AuthService` kunnen gebruiken.

## Registreren

Registreren van een nieuwe gebruiker zal gebeuren via een `POST /api/users` endpoint. We definiëren eerst de nodige DTO:

```ts
// src/user/user.dto.ts
import { IsString, IsEmail, MinLength, MaxLength } from 'class-validator';

export class RegisterUserRequestDto {
  @IsString()
  @MinLength(2)
  @MaxLength(255)
  name: string;

  @IsString()
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  @MaxLength(128)
  password: string;
}
```

Verwijder de bestaande `CreateUserRequestDto` uit de `user.dto.ts`, deze wordt niet meer gebruikt. Pas `UpdateUserRequestDto` aan naar:

```ts
// src/user/user.dto.ts

export class UpdateUserRequestDto {
  @IsString()
  @MinLength(2)
  @MaxLength(255)
  name: string;

  @IsString()
  @IsEmail()
  email: string;
}
```

Eventueel kan je opteren om het wachtwoord optioneel mee te geven in `UpdateUserRequestDto`. Als het wachtwoord meegegeven wordt, zal het ook aangepast worden in de databank. We doen dit niet in deze cursus.

We voegen ook een `register` functie toe aan de `AuthService`:

```ts
// src/auth/auth.service.ts
// ...
import { Role } from './roles';
import { RegisterUserRequestDto } from '../user/user.dto';

export class AuthService {
  // ... andere functies

  async register({
    name,
    email,
    password,
  }: RegisterUserRequestDto): Promise<string> {
    // 👇 1
    const passwordHash = await this.hashPassword(password);

    // 👇 2
    const [newUser] = await this.db
      .insert(users)
      .values({
        name,
        email,
        passwordHash: passwordHash,
        roles: [Role.USER], // 👈 3
      })
      .$returningId();

    // 👇 4
    const user = await this.db.query.users.findFirst({
      where: eq(users.id, newUser.id),
    });

    // 👇 5
    return this.signJwt(user!);
  }
}
```

1. We hashen het wachtwoord voordat we de gebruiker aanmaken.
2. We maken een nieuwe gebruiker aan in de database.
3. Standaard krijgt elke nieuwe gebruiker de `USER` rol.
4. We halen de volledige gebruiker op uit de database.
5. We ondertekenen een JWT en geven deze terug.
   - We weten dat de `user` bestaat omdat we deze net aangemaakt hebben, dus we gebruiken de non-null assertion operator `!`.

En we refactoren de `POST /api/users` route in de `UserController`:

```ts
// src/user/user.controller.ts
import {
  // ...
  RegisterUserRequestDto, // 👈 2
} from './user.dto';
import { LoginResponseDto } from '../session/session.dto';
import { AuthService } from '../auth/auth.service'; // 👈 1

@Controller('users')
export class UserController {
  constructor(
    // ... andere services
    private readonly authService: AuthService, // 👈 1
  ) {}

  @Post() // 👇 1
  async registerUser(
    @Body() registerDto: RegisterUserRequestDto,
  ): Promise<LoginResponseDto> {
    const token = await this.authService.register(registerDto); // 👈 2
    return { token }; // 👈 3
  }

  // ... andere routes
}
```

1. We injecteren de `AuthService`.
2. We hernoemen een `POST /api/users` route handler naar `registerUser`, we gebruiken ook het juist DTO.
3. We roepen de `register` functie van de `AuthService` aan.
4. We geven de JWT token terug in een object.

> ⚠️ **Belangrijk**: We gebruiken niet `POST /api/users/register` omdat dit geen RESTful route is. Je mag nl. geen werkwoorden of acties in je URL's steken.

Verwijder de oude `create` functie uit de`UserService`, deze wordt niet meer gebruikt.

Importeer de `AuthModule` in de `UserModule` zodat we de `AuthService` kunnen gebruiken.

## Endpoints testen

Test het `POST /api/sessions` endpoint via Postman of een gelijkaardige tool. Je zou een JWT token moeten ontvangen bij een succesvolle aanmelding. Gebruik hiervoor volgende JSON body:

```json
{
  "email": "thomas.aelbrecht@hogent.be",
  "password": "12345678"
}
```

Test ook het `POST /api/users` endpoint om een nieuwe gebruiker te registreren. Je zou ook hier een JWT token moeten ontvangen bij een succesvolle registratie. Gebruik hiervoor volgende JSON body:

```json
{
  "name": "Nieuwe Gebruiker",
  "email": "nieuwe.gebruiker@hogent.be",
  "password": "12345678"
}
```

Probeer nadien aan te melden met de nieuw geregistreerde gebruiker via het `POST /api/sessions` endpoint.

## Decorators

We gebruiken custom decorators om metadata toe te voegen aan routes. We voegen twee decorators toe, `@Public()` en `@Roles()`, die we later gebruiken in onze guards. Zonder guards hebben deze decorators geen effect.

### @Public()

Als eerste definiëren we een `@Public()` decorator die een route als publiek markeert (dus geen authenticatie vereist):

```ts
// src/auth/decorators/public.decorator.ts
import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
```

Voeg de `@Public()` decorator toe aan login en register routes, bijvoorbeeld:

```ts
// src/sessions/sessions.controller.ts
import { Public } from '../auth/decorators/public.decorator'; // 👈 1

@Controller('sessions')
export class SessionController {
  // ... constructor

  @Public() // 👈 2
  @Post()
  async signIn(@Body() loginDto: LoginRequestDto): Promise<LoginResponseDto> {
    // ...
  }
}
```

### @Roles()

De `@Roles()` decorator markeert welke rollen vereist zijn voor een route:

```ts
// src/auth/decorators/roles.decorator.ts
import { SetMetadata } from '@nestjs/common';

export const ROLES_KEY = 'roles';
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
```

Voeg de `@Roles()` decorator toe aan de route om alle gebruikers op te halen:

```ts
// src/user/user.controller.ts
import { Roles } from '../auth/decorators/roles.decorator'; // 👈 1
import { Role } from '../auth/roles';

@Controller('users')
export class UserController {
  // ... constructor

  @Get() // 👇 1
  @Roles(Role.ADMIN) // 👈 2
  async getAllUsers(): Promise<UserResponseDto[]> {
    // ...
  }
}
```

## Guards voor authenticatie en autorisatie

Als laatste stap implementeren het afdwingen van authenticatie en autorisatie op onze routes. Zo kunnen we bepalen welke routes publiek zijn, welke routes enkel voor aangemelde gebruikers zijn en welke routes enkel voor gebruikers met bepaalde rollen.

Lees eerst de documentatie over [Guards](https://docs.nestjs.com/guards) (t.e.m. "Authorization guard").

In NestJS gebruiken we **guards** om authenticatie en autorisatie af te dwingen. Guards zijn klassen die bepalen of een request mag doorgaan of niet. Ze geven simpelweg `true` of `false` terug, of gooien een foutmelding.

### AuthGuard

De eerste guard die we maken is de `AuthGuard` en controleert of de gebruiker is aangemeld:

```ts
// src/auth/guards/auth.guard.ts
import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Request } from 'express';
import { AuthService } from '../auth.service';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private authService: AuthService,
    private reflector: Reflector, // 👈 1
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    // 👇 2
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) {
      return true;
    }

    // 👇 3
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);
    if (!token) {
      throw new UnauthorizedException('You need to be signed in');
    }

    try {
      // 👇 4
      const payload = await this.authService.verifyJwt(token);

      // 👇 5
      request.user = {
        id: payload.sub,
        roles: payload.roles,
        email: payload.email,
      };
    } catch (err) {
      // 👇 6
      if (err.name === 'TokenExpiredError') {
        throw new UnauthorizedException('Token has expired');
      } else {
        throw new UnauthorizedException('Invalid authentication token');
      }
    }
    return true; // 👈 7
  }

  // 👇 3
  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
```

1. We injecteren de `Reflector` om metadata van decorators te kunnen lezen.
   - Zie <https://docs.nestjs.com/fundamentals/execution-context#executioncontext-class>
   - `context.getHandler()` geeft de methode van de controller terug.
   - `context.getClass()` geeft de controller klasse terug.
2. We controleren of de route publiek is (via de `@Public()` decorator). Als dat zo is, laten we het request door.
3. We halen de JWT uit de `Authorization` header en controleren of deze bestaat. Als er geen token is, gooien we een `UnauthorizedException`.
   - We gebruiken hiervoor de helper functie `extractTokenFromHeader`. Deze haalt de token uit de header en controleert of de prefix `Bearer` is.
4. We verifiëren de JWT en krijgen de payload terug.
5. We slaan de gebruikersinformatie op in `request.user` zodat we deze later kunnen gebruiken.
6. Als er een fout optreedt bij het verifiëren van de JWT, gooien we een gepaste foutmelding.
7. Als alles goed is, laten we het request door.

In deze guard krijgen we een aantal linting fouten. Voorlopig schakelen we deze regels uit. Voeg volgende toe aan het `rules` object in het `eslint.config.mjs` bestand:

```text
'@typescript-eslint/no-unsafe-argument': 'off',
'@typescript-eslint/no-unsafe-assignment': 'off',
'@typescript-eslint/no-unsafe-call': 'off',
'@typescript-eslint/no-unsafe-member-access': 'off',
'@typescript-eslint/no-unsafe-return': 'off',
```

### RolesGuard

De `RolesGuard` controleert of de gebruiker de juiste rollen heeft:

```ts
// src/auth/guards/roles.guard.ts
import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    // 👇 1
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

    // 👇 2
    if (!requiredRoles) {
      return true;
    }

    const request = context.switchToHttp().getRequest();

    // 👇 3
    if (!request.user) {
      throw new UnauthorizedException('You need to be signed in');
    }

    const { roles } = request.user;

    // 👇 4
    const hasRole = requiredRoles.some((role) => roles?.includes(role));

    // 👇 5
    if (!hasRole) {
      throw new ForbiddenException('You do not have access to this resource');
    }

    return true; // 👈 6
  }
}
```

1. We halen de vereiste rollen op uit de metadata van de route (via de `@Roles()` decorator).
2. Als er geen rollen vereist zijn, laten we het request door.
3. We controleren of de gebruiker is aangemeld.
4. We controleren of de gebruiker één van de vereiste rollen heeft.
5. Als de gebruiker niet de juiste rol heeft, gooien we een `ForbiddenException`.
6. Op het einde geven we `true` terug om het request door te laten.

### Guards globaal registreren

We registreren de guards globaal in de `AppModule` zodat ze automatisch op alle routes worden toegepast:

```ts
// src/app.module.ts
import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { AuthGuard } from './auth/guards/auth.guard';
import { RolesGuard } from './auth/guards/roles.guard';

@Module({
  // ... imports
  providers: [
    {
      provide: APP_GUARD,
      useClass: AuthGuard, // 👈
    },
    {
      provide: APP_GUARD,
      useClass: RolesGuard, // 👈
    },
    // ... andere providers
  ],
})
export class AppModule {}
```

We registreren de `AuthGuard` en de `RolesGuard` globaal. Hierdoor worden deze guard automatisch op alle routes toegepast. Heb je meer controle nodig over welke guards op welke routes toegepast worden, dan kan je ze ook per controller of per route registreren via de `@UseGuards()` decorator.

## Gebruikersspecifieke toegangscontrole

Naast algemene authenticatie en autorisatie, willen we ook controleren of een gebruiker toegang heeft tot zijn eigen gegevens.

### CheckUserAccessGuard

We maken hiervoor een speciale guard:

```ts
// src/auth/guards/userAccess.guard.ts
import {
  Injectable,
  CanActivate,
  ExecutionContext,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { Role } from '../roles';

@Injectable()
export class CheckUserAccessGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();

    // 👇 1
    if (!request.user) {
      throw new UnauthorizedException('You need to be signed in');
    }

    const { id: userId, roles } = request.user;
    const id = request.params.id;

    // 👇 2
    if (id !== 'me' && id !== String(userId) && !roles.includes(Role.ADMIN)) {
      throw new NotFoundException('No user with this id exists');
    }

    return true;
  }
}
```

1. We controleren of de gebruiker is aangemeld.
2. We controleren of de gebruiker toegang heeft tot de gevraagde gebruiker:
   - Als het id `'me'` is, heeft de gebruiker altijd toegang.
   - Als het id overeenkomt met het id van de aangemelde gebruiker, heeft de gebruiker toegang.
   - Als de gebruiker een admin is, heeft hij altijd toegang.
   - Anders gooien we een `NotFoundException` om niet prijs te geven dat de gebruiker bestaat.

### @CurrentUser()

Om de huidige gebruiker eenvoudig op te halen in onze route handlers, maken we een `@CurrentUser()` decorator. Deze decorator haalt de gebruiker op uit het request object dat we in de `AuthGuard` gezet hebben.

```ts
// src/auth/decorators/currentUser.decorator.ts
import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const CurrentUser = createParamDecorator(
  (_: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
```

We voegen ook nog een type toe voor de gebruikerssessie:

```ts
// src/types/auth.ts
export interface Session {
  id: number;
  email: string;
  roles: string[];
}
```

### ParseUserIdPipe

We maken ook een pipe die het `id` parameter kan parsen naar een `number` of `'me'`:

```ts
// src/auth/pipes/parseUserId.pipe.ts
import type { PipeTransform } from '@nestjs/common';
import { Injectable, BadRequestException } from '@nestjs/common';

@Injectable()
export class ParseUserIdPipe implements PipeTransform {
  transform(value: string) {
    if (value === 'me') {
      return 'me';
    }

    const parsedId = Number(value);
    if (isNaN(parsedId)) {
      throw new BadRequestException('User ID must be a number or "me"');
    }

    return parsedId;
  }
}
```

### Implementatie in UserController

Deze guard gebruiken we op routes waar we gebruikersspecifieke data ophalen. Als de gebruiker `'me'` als id opgeeft, gebruiken we de id van de aangemelde gebruiker. Anders gebruiken we het opgegeven id.

```ts
// src/user/user.controller.ts
// ...
import {
  // ...
  UseGuards,
} from '@nestjs/common';
import { CheckUserAccessGuard } from '../auth/guards/userAccess.guard';
import { type Session } from '../types/auth';

@Controller('users')
export class UserController {
  @Get(':id')
  @UseGuards(CheckUserAccessGuard) // 👈
  async getUserById(
    @Param('id', ParseUserIdPipe) id: 'me' | number, // 👈
    @CurrentUser() user: Session, // 👈
  ): Promise<PublicUserResponseDto> {
    const userId = id === 'me' ? user.id : id; // 👈
    return await this.userService.getById(userId);
  }

  @Put(':id')
  @UseGuards(CheckUserAccessGuard) // 👈
  async updateUserById(
    @Param('id', ParseUserIdPipe) id: 'me' | number, // 👈
    @CurrentUser() user: Session, // 👈
    @Body() dto: UpdateUserRequestDto,
  ): Promise<PublicUserResponseDto> {
    return await this.userService.updateById(
      id === 'me' ? user.id : id, // 👈
      dto,
    );
  }

  @Delete(':id')
  @UseGuards(CheckUserAccessGuard) // 👈
  async deleteUserById(
    @Param('id', ParseUserIdPipe) id: 'me' | number, // 👈
    @CurrentUser() user: Session, // 👈
  ): Promise<void> {
    return await this.userService.deleteById(
      id === 'me' ? user.id : id, // 👈
    );
  }

  @Get('/:id/favoriteplaces')
  @UseGuards(CheckUserAccessGuard) // 👈
  async getFavoritePlaces(
    @Param('id', ParseUserIdPipe) id: number | 'me', // 👈
    @CurrentUser() user: Session, // 👈
  ): Promise<PlaceResponseDto[]> {
    return this.placeService.getFavoritePlacesByUserId(
      id === 'me' ? user.id : id, // 👈
    );
  }
}
```

### Endpoints testen

#### Gewone gebruiker

Meld je aan met een gebruiker via `POST /api/sessions` en met onderstaande body:

```json
{
  "email": "karine.samyn@hogent.be",
  "password": "12345678"
}
```

Kopieer de JWT token uit het response.

Voer een `GET /api/users/me` request uit en kies in Postman bij het tabblad `Authorization` voor `Bearer Token`. Plak de JWT token in het veld. Je zou de gegevens van de aangemelde gebruiker moeten ontvangen.

Je kan ook `GET /api/users/3` uitvoeren om deze gebruiker op te vragen. Bij een ander user id krijg je een 404.

> :bulb: **Tip:** bekijk de inhoud van de JWT op <https://jwt.io/> door de token in te plakken. Zo kan je zien welke gegevens er in de token zitten.

#### Admin gebruiker

Meld je nu aan met een admin gebruiker via `POST /api/sessions` en met onderstaande body:

```json
{
  "email": "thomas.aelbrecht@hogent.be",
  "password": "12345678"
}
```

Kopieer de JWT token uit het response.

Voer een `GET /api/users/1` request uit (met de token van de admin). Je krijgt de eigen user te zien. Probeer daarna een `GET /api/users/3`, je zou nu ook deze gebruiker moeten kunnen opvragen.

## Timing attack beveiliging

Om zogenaamde [timing attacks](https://en.wikipedia.org/wiki/Timing_attack) te voorkomen, kunnen we een willekeurige vertraging toevoegen aan onze authenticatie. Deze vertraging maakt het moeilijker voor een aanvaller om aan de hand van de responstijd te achterhalen of een wachtwoord correct is of niet.

In NestJS kunnen we dit implementeren met een interceptor:

```ts
// src/auth/interceptors/authDelay.interceptor.ts
import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { delay } from 'rxjs/operators';

@Injectable()
export class AuthDelayInterceptor implements NestInterceptor {
  constructor(private configService: ConfigService) {}

  intercept(_: ExecutionContext, next: CallHandler) {
    const maxDelay = this.configService.get<number>('auth.maxDelay')!;
    const randomDelay = Math.round(Math.random() * maxDelay);
    return next.handle().pipe(delay(randomDelay));
  }
}
```

Je kan deze interceptor toevoegen aan de login en register routes, bijvoorbeeld:

```ts
// src/sessions/sessions.controller.ts
// ...
import {
  // ...
  UseInterceptors,
} from '@nestjs/common';
import { AuthDelayInterceptor } from '../auth/interceptors/authDelay.interceptor';

@UseInterceptors(AuthDelayInterceptor)
@Post()
@Public()
async signIn(@Body() loginDto: LoginRequestDto): Promise<LoginResponseDto> {
  // ...
}
```

Vergeet niet om een getal `auth.maxDelay` toe te voegen aan je configuratie!

Test dit uit via Postman. je zou moeten merken dat beide requests willekeurig langer duren.

## Opmerking over real-world projecten

In de praktijk wil je liever externe services gebruiken voor authenticatie en autorisatie. Dit geeft minder problemen met o.a. veiligheid, GDPR... Authenticatie en autorisatie is ook altijd hetzelfde!

Voorbeelden zijn [better-auth](https://www.better-auth.com/), [Auth0](https://auth0.com/), [Userfront](https://userfront.com/), [SuperTokens (open source)](https://supertokens.com/), [Amazon Cognito](https://aws.amazon.com/cognito/)...

Bij Web Services zie je hoe je manueel authenticatie en autorisatie kan implementeren. In andere olods zal je zien hoe je hiervoor externe services kan gebruiken.

## Oefeningen

### Oefening 1 - Places beveiligen

Pas `POST /api/places`, `PUT /api/places/:id` en `DELETE /api/places/:id` zijn enkel toegankelijk voor admins. Doe de nodige aanpassingen in de `PlacesController`.

### Oefening 2 - Transacties beveiligen

!> Dit is een zeer belangrijke oefening! Heel wat applicaties voegen simpel authenticatie en autorisatie op routeniveau toe, maar vergeten vaak autorisatie op entiteitsniveau. In ons project mag bv. niet elke gebruiker elke transactie zien. Denk hierover in je eigen project ook goed na!

Pas de routes en service van transactions aan:

1. `GET /api/transactions` retourneert enkel de transacties van de aangemelde gebruiker.
   - Een admin mag wel alle transacties ophalen.
   - **Tip**: Pas de service aan zodat je het `userId` en de `roles` kan meegeven als parameter.
   - Controleer of de user niet meer informatie bevat dan het id, de naam en het e-mailadres.
2. `GET /api/transactions/:id` retourneert de transactie met opgegeven id, maar dit mag enkel indien de transactie behoort tot de aangemelde gebruiker.
   - Een admin mag wel alle transacties ophalen.
   - **Tip**: Pas de service aan zodat je het `userId` en de `roles` kan meegeven als parameter.
   - Controleer of de user niet meer informatie bevat dan het id, de naam en het e-mailadres.
3. `POST /api/transactions`: de `userId` van de te creëren transactie is de id van de aangemelde gebruiker. Verwijder dit veld uit de request DTO en gebruik de `@CurrentUser()` decorator om het id van de gebruiker op te halen en door te geven aan de service.
4. `PUT /api/transactions/:id`: controleer of de transactie behoort tot de aangemelde gebruiker voordat je deze aanpast.
5. `DELETE /api/transactions/:id`: verwijder enkel transacties van de aangemelde gebruiker.

Optioneel: Pas de CUD-operaties aan zodat de admin deze operaties op alle transacties mag uitvoeren.

## Helmet

[Helmet](https://github.com/helmetjs/helmet) is een middleware die verschillende HTTP response headers instelt om de beveiliging van je webapplicatie te verbeteren. NestJS heeft ingebouwde ondersteuning voor Helmet omdat het onder de motorkap Express gebruikt.

Enkele van de beveiligingsheaders die door Helmet worden ingesteld:

- **Content Security Policy (CSP)**: helpt Cross-Site Scripting (XSS) aanvallen te voorkomen. [Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- **X-Content-Type-Options**: voorkomt content-sniffing attacks door de browser te dwingen zich aan het aangegeven Content-Type te houden. [Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options)
- **Strict-Transport-Security**: dwingt het gebruik van veilige HTTPS-verbindingen af. [Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)
- **X-Frame-Options**: voorkomt [clickjacking](https://developer.mozilla.org/en-US/docs/Web/Security/Types_of_attacks#click-jacking)-aanvallen door te beperken waar jouw site in een `iframe` kan worden ingesloten. [Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options)

Lees [Helmet in NestJS](https://docs.nestjs.com/security/helmet)

### Installatie

Installeer Helmet:

```bash
pnpm install helmet
```

### Configuratie

Activeer Helmet in je `main.ts`:

```typescript
// src/main.ts
//..
import helmet from 'helmet';

async function bootstrap() {
  //..
  app.use(helmet()); // 👈 Voeg Helmet toe
  //..
}
bootstrap();
```

Met deze configuratie worden automatisch verschillende beveiligingsheaders aan alle responses toegevoegd, wat de algehele beveiliging van je applicatie verbetert.

### Oefening - Je eigen project

Voeg Helmet toe aan je eigen project volgens bovenstaande stappen.

## Oplossing voorbeeldapplicatie

> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les7-opl 7bf0724
> pnpm install
> docker compose up -d
> pnpm db:migrate
> pnpm db:seed
> pnpm start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.

## Extra's voor de examenopdracht

- Gebruik [Passport.js](https://www.passportjs.org/) voor authenticatie en integreer met bv. aanmelden via Facebook, Google...
  - NestJS heeft uitstekende ondersteuning voor Passport.js, zie de [NestJS documentatie](https://docs.nestjs.com/security/authentication#implementing-passport-strategies).
- Gebruik van een externe authenticatieprovider (bv. [better-auth](https://www.better-auth.com/), [Auth0](https://auth0.com/), [Userfront](https://userfront.com/)...)
- Schrijf een custom validator om de sterkte van een wachtwoord te controleren, gebruik bv. [zxcvbn](https://www.npmjs.com/package/zxcvbn)
  - Dit is een vrij kleine extra, dus zorg ervoor dat je nog een andere extra toevoegt.
