# Testing (WIP)

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les8 3acce6c
> pnpm install
> pnpm start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.

## Leerdoelen

- Je krijgt inzicht in de verschillende soorten testen en hun plaats in de testpiramide
- Je kunt integratietesten schrijven voor NestJS controllers en endpoints
- Je begrijpt hoe je een testomgeving opzet met Jest en de NestJS testing utilities
- Je leert werken met testdata en database cleanup in een testomgeving

## Soorten testen

We onderscheiden 3 soorten testen:

- **Unit testen**:
  - testen van een unit (een functie, een klasse, een component...) zonder externe dependencies
  - FIRST: Fast, Isolated, Repeatable, Self validating, Timely
  - Testen van logica, conditionele statements en loops - test elk pad in de code
- **Integratietesten**:
  - testen van een applicatie met zijn externe dependencies
- **e2e testen**:
  - testen van een applicatie vanuit het perspectief van de gebruiker
  - UI testen - hier dus niet van toepassing

![Testpiramide](./images/test_piramide.png)

Hoe hoger je in de piramide gaat, hoe trager de testen zijn en hoe meer ze kosten. Daarom zie je typisch heel veel testen onderaan de piramide, en veel minder bovenaan.

## Test Driven Development (TDD)

Binnen Test Driven Development (TDD) ga je als volgt te werk:

1. Schrijf een test
2. Doe de test falen
3. Pas de code aan
4. Doe de test slagen
5. Refactor: verbeter de code zonder de functionaliteit te wijzigen

Probeer om dit principe zoveel mogelijk toe te passen in je eigen project, het is een goeie gewoonte om TDD te werken.

## Tools

Om testen te kunnen maken heb je nood aan een test library en een test runner. Binnen JavaScript zijn er verschillende mogelijkheden:

- [Jest](https://jestjs.io/)
- [Mocha](https://mochajs.org/)
- [Jasmine](https://jasmine.github.io/)
- [Vitest](https://vitest.dev/)
- ...

## NestJS Testing

NestJS heeft ingebouwde testing utilities die samenwerken met `Jest`. NestJS onderscheidt twee hoofdtypen van testen:

- **Unit tests**: Testen van individuele services, controllers of modules in isolatie
- **Integration tests (e2e)**: Testen van de hele applicatie met alle dependencies

Als je `nest new project` gebruikt, krijg je automatisch een mapje `test` met een voorbeeld van een e2e-test (`app.e2e-spec.ts`). Ook krijgt elke gegenereerde service en controller een bijhorend `.spec.ts` bestand voor unit tests. NestJS gebruikt `Jest`. Maar je kan dit aanpassen indien gewenst.

## Integratietesten

In deze cursus focussen we ons op integratietesten. We schrijven hier integratietesten om te testen of de verschillende onderdelen van onze applicatie goed samenwerken (bv. validatie, authenticatie...). We gebruiken hiervoor [Jest](https://jestjs.io/), een populaire test library voor JavaScript en is een uitgebreid framework, dus we beperken ons tot wat wij specifiek nodig hebben.

NestJS heeft ingebouwde testing utilities die het testen vergemakkelijken. Voor integratietesten maken we gebruik van

- [**jest**](https://jestjs.io/): de test library en test runner (standaard in NestJS)
- [**supertest**](https://www.npmjs.com/package/supertest): een library om HTTP requests te maken naar een server en de response te testen
- [**@nestjs/testing**](https://docs.nestjs.com/fundamentals/testing): NestJS testing utilities voor het maken van TestingModules. Het biedt een `TestingModule` om onze applicatie te testen zonder deze op een echte poort te laten draaien.

### De hierarchie

![Hierarchie](./images/testhierarchy.png)

- **Jest** is de Test Runner - dit is de motor die je tests uitvoert. Jest zoekt automatisch alle `.spec.ts` en `.test.ts` bestanden in je project, voert functies zoals `describe()` en `it()` uit, toont de testresultaten in je terminal en beheert wanneer tests starten en stoppen.

- **@nestjs/testing** is het NestJS Testing framework met handige hulpmiddelen voor het testen van NestJS applicaties. Het vormt de brug tussen Jest (de test runner) en NestJS (je framework), en zorgt ervoor dat dependency injection ook in je tests werkt.

- **TestingModule** is vergelijkbaar met een gewone NestJS module (met `@Module()` decorator), maar dan speciaal gemaakt voor testen. Het laat je controllers, services en providers isoleren en testen zonder dat je je volledige applicatie moet opstarten. Je krijgt een 'mini-versie' van je app om mee te werken.

- **INestApplication** is een werkende applicatie-instantie die je in je tests gebruikt. Het is de HTTP server waarmee `supertest` communiceert om requests te versturen en responses te controleren.

## Configuratie

NestJS projecten hebben standaard al Jest configuratie. Controleer je `package.json` en je zult zien dat er al een Jest configuratie is opgenomen.

Voor onze integratietesten krijgen een aantal omgevingsvariabelen een andere waarde dan in development. Maak een `.env.test` bestand aan in de root van je project.

```ini
# General configuration
NODE_ENV=testing
PORT=3000

# CORS configuration
CORS_ORIGINS=["http://localhost:5173"]
CORS_MAX_AGE=10800

# Database configuration
DATABASE_URL=mysql://devusr:devpwd@localhost:3306/budgettest # 👈 1

# Auth configuration
AUTH_JWT_SECRET=eenveeltemoeilijksecretdatniemandooitzalradenandersisdesitegehacked
AUTH_JWT_AUDIENCE=budget.hogent.be
AUTH_JWT_ISSUER=budget.hogent.be
AUTH_HASH_LENGTH=32
AUTH_HASH_TIME_COST=6
AUTH_HASH_MEMORY_COST=65536
AUTH_MAX_DELAY=2000

# Logging configuration
LOG_DISABLED=true # 👈 2
```

1. We gebruiken een test database in bvb de docker container.
2. `LOG_DISABLED`: het is performanter om de logging in een test omgeving uit te schakelen. Voeg deze variabele ook toe in de `.env` file en plaats deze op true. Zie verder voor meer info.

We wensen tijdens het runnen van de testen gebruik te maken van `.env.test`. Jest kent de optie `--env-file` niet (NestJS CLI). Je kan dit oplossen door gebruik te maken van `env-cmd` package. Installeer deze als dev dependency.

```bash
pnpm add -D env-cmd
```

Pas de test scripts aan in `package.json` zodat ze gebruik maken van `env-cmd` om de `.env.test` file te laden:

```json
{
  "scripts": {
    "test": "env-cmd -f .env.test jest --runInBand",
    "test:watch": "pnpm test --watch",
    "test:cov": "pnpm test --coverage",
    "test:debug": "node --inspect-brk -r tsconfig-paths/register -r ts-node/register --env-file .env.test node_modules/.bin/jest --runInBand",
    "test:e2e": "env-cmd -f .env.test jest --config ./test/jest-e2e.json",
    "test:e2e:cov": "env-cmd -f .env.test jest --config ./test/jest-e2e.json --runInBand --coverage",
  }
}
```

- `test`: draait unit testen. Maakt gebruik van de Jest config in package.json. Zoekt naar `*.spec.ts` bestanden (`"testRegex": ".*\\.spec\\.ts$"`) in de `src` folder (`"rootDir": "src"`).
- `test:e2e`: draait e2e testen. Maakt gebruik van een aparte Jest config (`./test/jest-e2e.json`) en zoekt naar de bestanden  `*.e2e-spec.ts` bestanden (`"testRegex": ".*\\.e2e-spec\\.ts$"`) in de `test` folder (`"rootDir": "."`).
- `--runInBand`: JEST voert de testsuites in parallel uit. Daar we met een database zullen werken en deze consistent dient te blijven dienen we de testsuites 1 na 1 uit te voeren.

## Logging in test omgeving

Om de logging te disablen in testomgeving hebben we reeds de omgevingsvariabele `LOG_DISABLED` toegevoegd.

We dienen ook de config hiervoor aan te passen

```typescript
// src/config/configuration.ts
export default () => ({
  env: process.env.NODE_ENV,
  port: parseInt(process.env.PORT || '9000'),
  log: {
    levels: process.env.LOG_LEVELS
      ? (JSON.parse(process.env.LOG_LEVELS) as LogLevel[])
      : ['log', 'error', 'warn'],
    disabled: process.env.LOG_DISABLED === 'true',// 👈
  },
  ...
});
//...
export interface LogConfig {
  levels: LogLevel[];
  disabled: boolean;// 👈
}
//...
```

Pas ook `app.module.ts` aan

```typescript
// src/app.module.ts
import { ConfigModule, ConfigService } from '@nestjs/config';
...
export class AppModule {
  constructor(private configService: ConfigService) { }// 👈 1

  configure(consumer: MiddlewareConsumer) {// 👈 2
    const isLogDisabled = this.configService.get<boolean>('log.disabled', false);// 👈 3

    if (!isLogDisabled) {
      consumer.apply(LoggerMiddleware).forRoutes('*path');
    }// 👈 4
  }
}
```

1. Injecteer de `ConfigService`.
2. De `configure` methode is een NestJS lifecycle hook die automatisch wordt aangeroepen tijdens `module` initialisatie. `MiddlewareConsumer` laat je middleware registreren voor specifieke routes.
3. Haal de waarde voor de omgevingsvariabele `log.disabled` op.
4. Als logging niet is uitgeschakeld, registreer de LoggerMiddleware en pas toe op alle routes (wildcard pattern).

## Integratietesten schrijven

Jest voorziet een aantal globale functies die je kunt gebruiken in je testen. De belangrijkste zijn:

- `describe`: definieert een test suite (= groeperen van testen)
- `test` of `it`: definieert een test
- `beforeAll`: definieert een functie die wordt uitgevoerd voor alle testen
- `afterAll`: definieert een functie die wordt uitgevoerd na alle testen
- `beforeEach`: definieert een functie die wordt uitgevoerd voor elke test
- `afterEach`: definieert een functie die wordt uitgevoerd na elke test

### GET api/health

In de map `test`, maak je een bestand `health.e2e-spec.ts` aan.
Alvorens we dit endpoint kunnen testen dienen we een instantie van de applicatie op te starten in de TestRunner.

#### De setup van een test

 Voordat alle testen runnen (`beforeAll`), moeten we een instantie van de applicatie starten.

```typescript
// test/health.e2e-spec.ts
import { Test, TestingModule } from '@nestjs/testing'; // 👈 1
import { INestApplication } from '@nestjs/common'; // 👈 1
import { AppModule } from '../src/app.module'; // 👈 1
import request from 'supertest'; // 👈 1

describe('Health', () => {
  // 👈 2
  let app: INestApplication; // 👈 3

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile(); // 👈 4

    app = moduleFixture.createNestApplication(); // 👈 5
    app.setGlobalPrefix('api'); // 👈 6
    await app.init(); // 👈 7
  });

  afterAll(async () => {
    await app.close();
  }); // 👈 8
});

```

1. We importeren de NestJS testing utilities en supertest voor HTTP requests.

    **Test**: Dit is de startpunt voor het maken van testomgevingen in NestJS. Het is een klasse met één belangrijke methode: `createTestingModule()`. Deze methode laat je een testversie van je applicatie opbouwen door aan te geven welke modules, controllers en services je wilt laden.

    **TestingModule**: Dit is het resultaat van `Test.createTestingModule().compile()`. Het is vergelijkbaar met een echte NestJS module, maar dan speciaal voor testen. Het bevat alle services en controllers die je wilt testen, en je kan er instanties van ophalen met de `.get()` methode. Het is een geïsoleerde instantie van de NestJS applicatie speciaal voor testing.

    **INestApplication**: Dit is een volledig werkende NestJS applicatie die je kan gebruiken in je tests. Het heeft een HTTP server die supertest kan gebruiken om requests naar te sturen. In plaats van je applicatie op bijvoorbeeld poort 3000 te laten draaien, maakt INestApplication een tijdelijke server die alleen bestaat tijdens het testen.

    [**supertest**](https://github.com/forwardemail/supertest): Dit is een tool die HTTP requests kan simuleren naar je applicatie. Het werkt samen met INestApplication om GET, POST, PUT, DELETE requests te versturen en de responses te controleren (status codes, body inhoud, headers). Het voordeel is dat je geen echte server hoeft op te starten - supertest communiceert rechtstreeks met de INestApplication instantie.

2. Groepeer de testen voor de health in een test suite met naam "Health".
3. Definieer de variabele `app` die een instantie van onze app zal bevatten
4. Gebruik `Test.createTestingModule()` om een complete NestJS applicatie op te zetten in test modus. Importeer AppModule. `compile()`compileert en retourneert een gebruiksklare TestingModule
5. `moduleFixture.createNestApplication()` creëert een `INestApplication` instantie uit de `TestingModule`.
6. Stel een globale prefix 'api' in voor alle routes in de testapplicatie.
7. `app.init()` initialiseert de applicatie, inclusief alle modules, controllers en services.
8. Nadat alle testen gerund hebben, sluiten we de applicatie netjes af met `app.close()`.

#### De test zelf

Nu is het tijd om een eerste echte integratietest te schrijven!

```typescript
// test/health.e2e-spec.ts
describe('Health', () => {
  // ...

   describe('GET /api/health/ping', () => {
    const url = '/api/health/ping';

    it('should return pong', async () => {// 👈 1
      const response = await request(app.getHttpServer()).get(url);// 👈 2

      expect(response.statusCode).toBe(200);// 👈 3
      expect(response.body).toEqual({ pong: true });// 👈 3
    });
  });
})
```

1. Definieer een test met `it()`. De test beschrijft wat we verwachten van de endpoint.
2. Gebruik `supertest` om een GET request naar `/api/health/ping` te sturen. We maken gebruik van de [async/await syntax](https://www.npmjs.com/package/supertest).
3. We verwachten status code 200 en de response body 'pong'.

Voer de test uit met `pnpm test:e2e --watch` en controleer of de test slaagt.

### Refactoring

De setup zal in elke TestSuite opnieuw moeten gebeuren, daarom maken we een helper functie om de App te initialiseren. In de `/test/helpers`folder maak je een bestand `create-app.ts`. Dit bevat de code uit `beforeAll`

```typescript
// test/helpers/create-app.ts
import {
  INestApplication,
  ValidationPipe,
  BadRequestException,
} from '@nestjs/common';
import { TestingModule, Test } from '@nestjs/testing';
import { ValidationError } from 'class-validator';
import { AppModule } from '../../src/app.module';
import { DrizzleQueryErrorFilter } from '../../src/drizzle/drizzle-query-error.filter';
import { HttpExceptionFilter } from '../../src/lib/http-exception.filter';
import { ConfigService } from '@nestjs/config';
import { ServerConfig, LogConfig } from '../../src/config/configuration';
import CustomLogger from '../../src/core/customLogger';

export async function createTestApp(): Promise<INestApplication> {
  const moduleFixture: TestingModule = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  const app = moduleFixture.createNestApplication();
  app.setGlobalPrefix('api');
  app.useGlobalFilters(new DrizzleQueryErrorFilter());
  app.useGlobalFilters(new HttpExceptionFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      forbidUnknownValues: true,
      exceptionFactory: (errors: ValidationError[] = []) => {
        const formattedErrors = errors.reduce(
          (acc, err) => {
            acc[err.property] = Object.values(err.constraints || {});
            return acc;
          },
          {} as Record<string, string[]>,
        );

        return new BadRequestException({
          details: { body: formattedErrors },
        });
      },
    }),
  );
  await app.init();
  return app;
}
```

We voegen ook alle filters, pipes, configuratie toe die we nodig hebben om de app te initialiseren in test.

Pas de code in `health.e2e-spec.ts` aan.

```typescript
// test/health.e2e-spec.ts
import { createTestApp } from './helpers/create-app';
...
  beforeAll(async () => {
    app = await createTestApp();
  });
  ...
```

## Testdata

Om de andere endpoints te testen hebben we testdata nodig. Hiervoor maken we gebruik van een testdatabase.

### test database

Maak een MySQL database aan in je docker-compose file `docker-compose.test.yml`:

```yaml
services:
  db-test:
    image: mysql:8.0
    ports:
      - '3310:3306'
    volumes:
      - db_data_test:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: budget
      MYSQL_USER: devusr
      MYSQL_PASSWORD: devpwd
    healthcheck:
      test: ['CMD', 'mysqladmin', 'ping', '-h', 'localhost', '--silent']
      timeout: 30s
      interval: 30s
      retries: 5
      start_period: 30s

volumes:
  db_data_test:
```

Run de docker container:

```bash
docker-compose -f docker-compose.test.yml up -d
```

### database migraties

Voeg onderstaand script toe aan package.json en run het script om de tabellen aan te maken.

```json
    "db:migrate:test": "env-cmd -f .env.test drizzle-kit migrate",
```

### seeding

We starten met het testen van de places endpoints. Hiervoor dienen we testdata aan de database toe te voegen.

Maak een folder `/test/seeds` aan en het bestand `places.ts`. Voor het runnen van een test wordt de database geseed met de data, na de test wordt de data terug verwijderd.

```typescript
// /test/seeds/places.ts
import { DatabaseProvider } from '../../src/drizzle/drizzle.provider';
import { places } from '../../src/drizzle/schema';

export const PLACES_SEED = [
  {
    id: 1,
    name: 'Loon',
    rating: 5,
  },
  {
    id: 2,
    name: 'Benzine',
    rating: 2,
  },
  {
    id: 3,
    name: 'Irish pub',
    rating: 4,
  },
];

export async function seedPlaces(drizzle: DatabaseProvider) {
  await drizzle.insert(places).values(PLACES_SEED);
}

export async function clearPlaces(drizzle: DatabaseProvider) {
  await drizzle.delete(places);
}
```

## GET /api/places

Maak een nieuwe file `test/places.e2e-spec.ts` aan.

### de test setup

```typescript
import { INestApplication } from '@nestjs/common';
import {
  DatabaseProvider,
  DrizzleAsyncProvider,
} from '../src/drizzle/drizzle.provider'; // 👈 1
import { createTestApp } from './helpers/create-app';
import { seedPlaces, clearPlaces } from './seeds/places';

describe('Places', () => {
  let app: INestApplication;
  let drizzle: DatabaseProvider; // 👈 1

  const url = '/api/places';

  beforeAll(async () => {
    app = await createTestApp();
    drizzle = app.get(DrizzleAsyncProvider); // 👈 2

    await seedPlaces(drizzle); // 👈 3
  });

  afterAll(async () => {
    await clearPlaces(drizzle); // 👈 4
    await app.close();
  });
});
```

De setup is analoog aan de Health test, maar nu dienen we ook de database te seeden.

1. Maak een variabele aan van het type `DatabaseProvider`
2. Localiseer een instantie van `DrizzleAsyncProvider`.
3. Seed de tabel `places`
4. Ruim deze data op na de testen.

Opmerking: In een echte testomgeving zou je best voor elke test de database terug naar een gekende staat brengen. Dit kan door na elke test de data op te ruimen (`afterEach`) en voor elke test opnieuw te seeden (`beforeEach`). Voor de eenvoud doen we dit hier niet. Je kan ook voor elke test de specifieke data aanmaken die je nodig hebt.

### GET /api/places/

```typescript
 describe('GET /api/places', () => {
    it('should 200 and return all places', async () => {
        const response = await request(app.getHttpServer())
        .get(url);

      expect(response.statusCode).toBe(200);
      expect(response.body.items).toEqual(expect.arrayContaining(PLACES_SEED));
    });
  });
```

Met `expect.arrayContaining` controleren we of de array `response.body.items` minstens de objecten bevat die we verwachten. De objecten moeten niet in dezelfde volgorde staan, maar ze moeten wel allemaal aanwezig zijn

Run de test en controleer of deze slaagt.`pnpm test:e2e -- places.e2e-spec`.
De test faalt omdat authenticatie vereist is voor dit endpoint.
Maak het endpoint public (@Public-decorator) en run de test opnieuw.

## authenticatie in e2e testen

Om endpoints te testen die authenticatie vereisen, dienen we testgebruikers aan te maken en ons aan te melden om een JWT token te verkrijgen. Dit token voegen we vervolgens toe aan de Authorization header van onze requests.

### Seeding users

We dienen ook testgebruikers aan te maken in de database. Maak een bestand `test/seeds/users.ts` aan:

```typescript
// test/seeds/users.ts
import { INestApplication } from '@nestjs/common';
import { AuthService } from '../../src/auth/auth.service';
import { DatabaseProvider } from '../../src/drizzle/drizzle.provider';
import { users } from '../../src/drizzle/schema';
import { Role } from '../../src/auth/roles';

export async function seedUsers(
  app: INestApplication,
  drizzle: DatabaseProvider,
) {
  const authService = app.get(AuthService);
  const passwordHash = await authService.hashPassword('12345678');

  await drizzle.insert(users).values([
    {
      id: 1,
      name: 'Test User',
      email: 'test.user@hogent.be',
      passwordHash,
      roles: [Role.USER],
    },
    {
      id: 2,
      name: 'Admin User',
      email: 'admin.user@hogent.be',
      passwordHash,
      roles: [Role.ADMIN, Role.USER],
    },
  ]);
}

export async function clearUsers(drizzle: DatabaseProvider) {
  await drizzle.delete(users);
}

```

### Login helper

Vervolgens definiëren we een helper-functie om de admin en een gewone gebruiker aan te melden en een token te verkrijgen. Maak een bestand `test/helper/login.ts`:

```ts
// test/helpers/login.ts
import { INestApplication } from '@nestjs/common';
import { AuthService } from '../../src/auth/auth.service';

export const login = async (app: INestApplication): Promise<string> => {
  const authService = app.get(AuthService);// 👈 1
  const token = await authService.login({
    email: 'test.user@hogent.be',
    password: '12345678',
  });// 👈 2

  if (!token) {
    throw new Error('No token received');
  }// 👈 3

  return token;// 👈 4
};

export const loginAdmin = async (app: INestApplication): Promise<string> => {
  const authService = app.get(AuthService);
  const token = await authService.login({
    email: 'admin.user@hogent.be',
    password: '12345678',
  });

  if (!token) {
    throw new Error('No token received');
  }

  return token;
};// 👈 5
```

De methode `login` meldt een gewone gebruiker aan

1. Vraag een instantie van AuthService op
2. De functie `login` kunnen we gebruiken om aan te melden voor elke test. Retourneer het token
3. Als het geen succesvol request was, dan gooien we een error. De error zal onze test(s) laten falen, in de meeste gevallen is dit een hele test suite.
4. We retourneren het token
5. We doen hetzelfde voor de admin

### Gebruik van het token in requests

We kunnen nu in onze tests het token gebruiken om geauthenticeerde requests te maken. Pas `places.e2e-spec.ts` aan:

```typescript
import { INestApplication } from '@nestjs/common';
import {
  DatabaseProvider,
  DrizzleAsyncProvider,
} from '../src/drizzle/drizzle.provider';
import request from 'supertest';
import { createTestApp } from './helpers/create-app';
import { seedPlaces, clearPlaces, PLACES_SEED } from './seeds/places';
import { clearUsers, seedUsers } from './seeds/users'; // 👈 1
import { login, loginAdmin } from './helpers/login'; // 👈 2


describe('Places', () => {
  let app: INestApplication;
  let drizzle: DatabaseProvider;
  let userAuthToken: string; // 👈 2
  let adminToken: string; // 👈 2

  const url = '/api/places';

  beforeAll(async () => {
    app = await createTestApp();
    drizzle = app.get(DrizzleAsyncProvider);

    await seedPlaces(drizzle);
    await seedUsers(app, drizzle); // 👈 1

    userAuthToken = await login(app);// 👈 2
    adminToken = await loginAdmin(app);// 👈 2
  });

  describe('GET /api/places', () => {
    it('should 200 and return all places', async() => {
      const response= await request(app.getHttpServer())
        .get(url)
        .auth(userAuthToken, { type: 'bearer' });
      expect(response.statusCode).toBe(200);
      expect(response.body.items).toEqual(expect.arrayContaining(PLACES_SEED));
    });
  });

   afterAll(async () => {
    await clearPlaces(drizzle);
    await clearUsers(drizzle);// 👈 1
    await app.close();
  });
});
```

1. Seed en clear ook de users tabel
2. Definieer variabelen om de tokens op te slaan. Meld de gebruiker en admin aan en sla de tokens op.
3. Gebruik `.auth(token, { type: 'bearer' })` om het token toe te voegen aan de Authorization header van het request.

### Test unauthorized

We voegen een functie toe die de nagaat of voor een bepaalde URL de juiste statuscode geretourneerd wordt als de gebruiker niet is aangemeld of een ongeldig token wordt verstuurd. Aangezien deze testen voor elk van de endpoints dienen te gebeuren maken we hiervoor een aparte functie aan in `test/helpers/testAuthHeader.ts`:

```ts
// test/helpers/testAuthHeader.ts
import type supertest from 'supertest';

// 👇 1
export default function testAuthHeader(
  requestFactory: () => supertest.Test,
): void {
  // 👇 2
  it('should respond with 401 when not authenticated', async () => {
    const response = await requestFactory();

    expect(response.statusCode).toBe(401);
    expect(response.body.message).toBe('You need to be signed in');
  });

  // 👇 3
  it('should respond with 401 with a malformed token', async () => {
    const response = await requestFactory().set(
      'Authorization',
      'Bearer INVALID TOKEN',
    );

    expect(response.statusCode).toBe(401);
    expect(response.body.message).toBe('Invalid authentication token');
  });
}
```

1. De functie heeft één parameter, nl. een `requestFactory`. Deze factory functie moet het request voor een bepaalde HTTP methode en URL creëren. Op die manier kunnen we onze testen voor eender welk request gebruiken, het is de taak van de factory om het juiste request te maken.
2. De eerste test controleert het retourneren van een statuscode 401 als de gebruiker niet is aangemeld en hierdoor niet gemachtigd is om het endpoint te bevragen.
3. De tweede test controleert het retourneren van een statuscode 401 als een ongeldig token wordt meegestuurd en de gebruiker hierdoor niet gemachtigd is om het endpoint te bevragen.

Voeg deze testen nu ook toe voor het uittesten van de api/places endpoint in `places.e2e-spec.ts`:

```typescript
import testAuthHeader from './helpers/testAuthHeader'; // 👈 1
//...
  describe('GET /api/places', () => {
    it('should 200 and return all places', () => {
      return request(app.getHttpServer())
        .get(url)
        .auth(userAuthToken, { type: 'bearer' })
        .expect(200)
        .expect({ items: PLACES_SEED });
    });

    testAuthHeader(() => request(app.getHttpServer()).get(url));
  });
  //...
```

### Oefening 1 - GET /api/places/:id

Schrijf een test voor het endpoint `GET /api/places/:id`:

1. Daar bij het ophalen van een plaats ook de transacties worden opgehaald, dien je eerst de seed en clear functies voor transacties toe te voegen in `test/seeds/transactions.ts` en deze ook te gebruiken in `places.e2e-spec.ts`.
2. Maak een nieuwe test suite aan voor het endpoint `GET /api/places/:id`.
3. Voer de test uit:
   1. Check of de statuscode gelijk is aan 200.
   2. Check of de geretourneerde plaats zoals verwacht is.

- Oplossing +

  ```typescript
  // test/seeds/transactions.ts
  import { DatabaseProvider } from '../../src/drizzle/drizzle.provider';
  import { transactions } from '../../src/drizzle/schema';

  export const TRANSACTIONS_SEED = [
    {
      id: 1,
      userId: 1,
      placeId: 1,
      amount: 3500,
      date: new Date(2021, 4, 25, 19, 40),
    },
    {
      id: 2,
      userId: 2,
      placeId: 1,
      amount: -220,
      date: new Date(2021, 4, 8, 20, 0),
    },
    {
      id: 3,
      userId: 1,
      placeId: 1,
      amount: -74,
      date: new Date(2021, 4, 21, 14, 30),
    },
  ];

  export async function seedTransactions(drizzle: DatabaseProvider) {
    await drizzle.insert(transactions).values(TRANSACTIONS_SEED);
  }

  export async function clearTransactions(drizzle: DatabaseProvider) {
    await drizzle.delete(transactions);
  }
  ```

  ```typescript
  // test/places.e2e-spec.ts
  import {
    seedTransactions,
    clearTransactions,
  } from './seeds/transactions'; // 👈

    beforeAll(async () => {
    app = await createTestApp();
    drizzle = app.get(DrizzleAsyncProvider);

    await seedPlaces(drizzle);
    await seedUsers(app, drizzle);
    await seedTransactions(drizzle);// 👈

    userAuthToken = await login(app);
    adminToken = await loginAdmin(app);
  });
  //...

  describe('GET /api/places/:id', () => {
    it('should 200 and return the requested place', async () => {
        const response = await request(app.getHttpServer())
          .get(`${url}/1`)
          .auth(userAuthToken, { type: 'bearer' });
        expect(response.statusCode).toBe(200);
        expect(response.body).toMatchObject(PLACES_SEED[0]);
        expect(response.body).toHaveProperty('transactions');
      });
  });

  afterAll(async () => {
    await clearTransactions(drizzle);// 👈
    await clearPlaces(drizzle);
    await clearUsers(drizzle);
    await app.close();
  });
  ```

4. Schrijf ook de testen voor de alternatieve scenario's

  Wat zijn de mogelijke alternatieve scenario's?

    - Negatieve test cases (error scenarios)
    - Edge cases (grenssituaties)
    - Validatie tests

  Schrijf ook hiervoor testen.

- Oplossing +

  ```typescript
  describe('GET /api/places/:id', () => {
       it('should 404 when requesting not existing place', async () => {
      const response = await request(app.getHttpServer())
        .get(`${url}/5`)
        .auth(userAuthToken, { type: 'bearer' });

      expect(response.statusCode).toBe(404);
      expect(response.body.message).toBe('No place with this id exists');
    });

    it('should 400 with invalid place id', async () => {
      const response = await request(app.getHttpServer())
        .get(`${url}/invalid`)
        .auth(userAuthToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe(
        'Validation failed (numeric string is expected)',
      );
    });

    testAuthHeader(() => request(app.getHttpServer()).get(url));
  });

  describe('POST /api/places', () => {
    it("should 200 and return the created place with it's rating", async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'Lovely place',
          rating: 5,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(201);
      expect(response.body).toEqual(
        expect.objectContaining({
          id: expect.any(Number),
          name: 'Lovely place',
          rating: 5,
          transactions: [],
        }),
      );
    });

    it('should 409 for duplicate place name', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({ name: 'Lovely place', rating: 5 })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(409);
      expect(response.body).toMatchObject({
        message: 'A place with this name already exists',
      });
    });

    it('should 400 when missing name', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({ rating: 3 })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('name');
    });

    it('should 400 when rating lower than one', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'The wrong place',
          rating: 0,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('rating');
    });

    it('should 400 when rating higher than five', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'The wrong place',
          rating: 6,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('rating');
    });

    it('should 400 when rating is a decimal', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'The wrong place',
          rating: 3.5,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('rating');
    });
  });
  ```

5. Voeg ook de authenticatie testen toe met `testAuthHeader`.

- Oplossing +

  ```typescript
  describe('GET /api/places/:id', () => {
   testAuthHeader(() => request(app.getHttpServer()).get(`${url}/1`));
  });
  ```

### POST /api/places

Maak een nieuwe test suite aan voor het endpoint `POST /api/places`. Welke testcases hebben we hier?

```typescript
  describe('POST /api/places', () => {
    it("should 200 and return the created place with it's rating", async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'Lovely place',
          rating: 5,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(201);
      expect(response.body).toEqual(
        expect.objectContaining({
          id: expect.any(Number),
          name: 'Lovely place',
          rating: 5,
          transactions: [],
        }),
      );
    });

    it('should 409 for duplicate place name', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({ name: 'Lovely place', rating: 5 })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(409);
      expect(response.body).toMatchObject({
        message: 'A place with this name already exists',
      });
    });

    it('should 400 when missing name', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({ rating: 3 })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('name');
    });

    it('should 400 when rating lower than one', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'The wrong place',
          rating: 0,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('rating');
    });

    it('should 400 when rating higher than five', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'The wrong place',
          rating: 6,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('rating');
    });

    it('should 400 when rating is a decimal', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'The wrong place',
          rating: 3.5,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('rating');
    });

    testAuthHeader(() =>
      request(app.getHttpServer()).post(url).send({ name: 'New place' }),
    );
  });
  ```

### Oefening 2 - PUT /api/places/:id

Schrijf een test voor het endpoint `PUT /api/places/:id`:

1. Maak een nieuwe test suite aan voor het endpoint `PUT /api/places/:id`.
2. Voer de test uit:
   1. Check of de statuscode gelijk is aan 200.
   2. Check of de geretourneerde plaats zoals verwacht is.
3. Schrijf ook de testen voor de alternatieve scenario's

- Oplossing +

  ```typescript
  describe('PUT /api/places/:id', () => {
    it('should 200 and return the updated place', async () => {
      const response = await request(app.getHttpServer())
        .put(`${url}/1`)
        .send({
          name: 'Changed name',
          rating: 1,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(200);
      expect(response.body).toEqual(
        expect.objectContaining({
          id: 1,
          name: 'Changed name',
          rating: 1,
        }),
      );
    });

    it('should 409 for duplicate place name', async () => {
      const response = await request(app.getHttpServer())
        .put(`${url}/2`)
        .send({
          name: 'Changed name',
          rating: 1,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(409);
      expect(response.body.message).toEqual(
        'A place with this name already exists',
      );
    });

    it('should 400 when missing name', async () => {
      const response = await request(app.getHttpServer())
        .put(`${url}/1`)
        .send({ rating: 3 })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('name');
    });

    it('should 400 when rating lower than one', async () => {
      const response = await request(app.getHttpServer())
        .put(`${url}/1`)
        .send({
          name: 'The wrong place',
          rating: 0,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('rating');
    });

    it('should 400 when rating higher than five', async () => {
      const response = await request(app.getHttpServer())
        .put(`${url}/1`)
        .send({
          name: 'The wrong place',
          rating: 6,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('rating');
    });

    it('should 400 when rating is a decimal', async () => {
      const response = await request(app.getHttpServer())
        .put(`${url}/1`)
        .send({
          name: 'The wrong place',
          rating: 3.5,
        })
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.details.body).toHaveProperty('rating');
    });

    testAuthHeader(() =>
      request(app.getHttpServer()).put(`${url}/1`).send({
        name: 'Changed name',
        rating: 1,
      }),
    );
  });
  ```

### Oefening 3 - DELETE /api/places/:id

Schrijf de testen voor het endpoint `DELETE /api/places/:id`:

1. Maak een nieuwe test suite aan voor het endpoint `DELETE /api/places/:id`.
2. Voer de testen uit:
   1. Check of de statuscode gelijk is aan 204.
   2. Check of de plaats daadwerkelijk verwijderd is uit de database.

- Oplossing +

  ```typescript
  describe('DELETE /api/places/:id', () => {
    it('should 204 and return nothing', async () => {
      const response = await request(app.getHttpServer())
        .delete(`${url}/3`)
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(204);
      expect(response.body).toEqual({});
    });

    it('should 400 with invalid place id', async () => {
      const response = await request(app.getHttpServer())
        .delete(`${url}/invalid`)
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe(
        'Validation failed (numeric string is expected)',
      );
    });

    it('should 404 with not existing place', async () => {
      const response = await request(app.getHttpServer())
        .delete(`${url}/5`)
        .auth(adminToken, { type: 'bearer' });

      expect(response.statusCode).toBe(404);
      expect(response.body.message).toBe('No place with this id exists');
    });
    testAuthHeader(() =>
      request(app.getHttpServer()).delete(`${url}/1`),
    );
  });
  ```

### Oefening 4 - Coverage

Vraag de coverage op van je testen met `pnpm test:e2e:cov`. Bekijk de gegenereerde HTML pagina in het bestand `test/coverage/lcov-report/index.html`. Wat merk je op?

- Oplossing +

  Je ziet dat we al een goede coverage hebben op de API endpoints. NestJS toont coverage voor controllers, services en andere modules.

  In de service laag hebben we misschien nog geen 100% omdat we bijvoorbeeld nog niet alle edge cases testen (zoals error handling voor ongeldige input).

### Oefening 5 - Testen voor de andere endpoints

Maak de testen aan voor alle endpoints in je applicatie. Denk na over:

- Positieve test cases (happy path)
- Negatieve test cases (error scenarios)
- Edge cases (grenssituaties)
- Validatie tests

### Automatiseer het opzetten van de test database

We wensen dat bij het starten van de testen automatisch een test database wordt opgezet in een Docker container. Hiervoor maken we gebruik van [Testcontainers](https://www.testcontainers.org/).

```bash
pnpm add -D testcontainers @testcontainers/mysql
```

We voegen een Jest globale setup functie toe die één keer draait vóór alle tests beginnen. Het zet een complete test database omgeving op. Maak een bestand `test/jest.global-setup.ts` aan:

```typescript
import {
  MySqlContainer,
  type StartedMySqlContainer,
} from '@testcontainers/mysql';
import { drizzle } from 'drizzle-orm/mysql2';
import { migrate } from 'drizzle-orm/mysql2/migrator';
import mysql from 'mysql2/promise';
import * as path from 'path';

declare global {
  var mySQLContainer: StartedMySqlContainer;
}// 👈 1

module.exports = async () => {
  const container = await new MySqlContainer('mysql:8.0').start();// 👈 2
  process.env.DATABASE_URL = container.getConnectionUri();// 👈 3
  globalThis.mySQLContainer = container;// 👈 4

  const connection = await mysql.createConnection(process.env.DATABASE_URL);
  const db = drizzle(connection);// 👈 5

  console.log('⏳ Running migrations...');
  await migrate(db, {
    migrationsFolder: path.resolve(__dirname, '../migrations'),
  });// 👈 6
  console.log('✅ Migrations completed!');

  await connection.end();// 👈 7
};
```

1. Vertelt TypeScript dat er een globale variabele mySQLContainer bestaat
2. Start een nieuwe MySQL Docker container met Testcontainers
3. Zet de omgevingsvariabele DATABASE_URL naar de connectiestring van de container in deze testomgeving (.env.test)
4. Sla de container instantie op in de globale variabele zodat we deze later kunnen stoppen
5. Maak een verbinding met de database in de container
6. Voer de database migraties uit om de tabellen aan te maken
7. Sluit de database verbinding

En de teardown file `test/jest.global-teardown.ts`:

```typescript
module.exports = async () => {
  await globalThis.mySQLContainer.stop();
};
```

Dit stopt en verwijdert de Testcontainers MySQL Docker container na het uitvoeren van de tests.

Pas `jest.config.ts` aan om de globale setup en teardown bestanden te gebruiken:

```typescript
{
  "moduleFileExtensions": ["js", "json", "ts"],
  "rootDir": ".",
  "testEnvironment": "node",
  "globalSetup": "./jest.global-setup.ts",// 👈
  "globalTeardown": "./jest.global-teardown.ts",// 👈
  "testRegex": ".e2e-spec.ts$",
  "transform": {
    "^.+\\.(t|j)s$": "ts-jest"
  }
}
```

## Oefening 6 - README

Vervolledig je `README.md` met de nodige informatie over het testen van je applicatie.

> **Oplossing voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les8-opl TODO
> pnpm install
> pnpm start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.

## Extra's voor de examenopdracht

- Gebruik een andere test library (bv. [Mocha](https://mochajs.org/), [Jasmine](https://jasmine.github.io/), [Vitest](<http://localhost:3000/[https://](https://vitest.dev/)>)...)
- Voeg unit testen toe voor de services
