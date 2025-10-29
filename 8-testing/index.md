# Testing (WIP)

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les5 3acce6c
> pnpm install
> pnpm start:dev

 ```
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
- `JEST` is de Test Runner, de engine die de tests uitvoert. Het zoekt alle .spec.ts en .test.ts bestanden op, voert de `describe`,... uit, rapporteert de resultaten en beheert de test lifecycle.
- `@nestjs/testing` is het NestJS Testing framework die de testing utilities bevat. Het is de brug tussen Jest en NestJS en maakt dependency injection in testen mogelijk
- `TestingModule`, werkt bijna hetzelfde als een gewone NestJS-module (@Module), maar wordt volledig in een testcontext opgezet. Zo kun je controllers, providers en services isoleren en testen zonder dat je je hele applicatie hoeft op te starten.
- `INestApplication` is een draaiende app instantie voor de testen, de HTTP server voor supertest.

## Configuratie

NestJS projecten hebben standaard al Jest configuratie. Controleer je `package.json` en je zult zien dat er al een Jest configuratie is opgenomen.

Voor onze integratietesten krijgen een aantal omgevingsvariabelen een andere waarde dan in development. Maak een `.env.test` bestand aan in de root van je project. We gaan gebruik maken van een test database.

```ini
# General configuration
NODE_ENV=testing
HOST=localhost
PORT=9000

# Logging configuration
LOG_DISABLED=false

# Database configuration
DATABASE_URL=mysql://<username>:<password>@localhost:3306/budgettest
```

`LOG_DISABLED`: het is performanter om de logging in een test omgeving uit te schakelen. Voeg deze variabele ook toe in de `.env` file en plaats deze op true

We wensen tijdens het runnen van de testen gebruik te maken van `.env.test`. Jest kent de optie `--env-file` niet (NestJS CLI). Je kan dit oplossen door gebruik te maken van `env-cmd` package.

Installeer:

```bash
pnpm add -D env-cmd
```

Pas de test scripts aan in `package.json`:

```json
{
  "scripts": {
   "test": "env-cmd -f .env.test jest --runInBand",
    "test:watch": "pnpm test --watch",
    "test:cov": "pnpm test --coverage",
    "test:debug": "node --inspect-brk -r tsconfig-paths/register -r ts-node/register --env-file .env.test node_modules/.bin/jest --runInBand",
    "test:e2e": "env-cmd -f .env.test jest --config ./test/jest-e2e.json",
  }
}
```

`--runInBand`: JEST voert de testsuites in parallel uit. Daar we met een database zullen werken en deze consistent dient te blijven dienen we de testsuites 1 na 1 uit te voeren.

## Logging in test omgeving

Om de logging te disablen in testomgeving hebben we reeds de omgevingsvariabele `LOG_DISABLED` toegevoegd.

We dienen ook de config hiervoor aan te passen

```typescript
// src/config/configuration.ts
 export default () => ({
  env: process.env.NODE_ENV,
  port: parseInt(process.env.PORT || '9000'),
  logging: {
    disabled: process.env.LOG_DISABLED === 'true',
  },// 👈
  ...
  });
```

Pas ook `app.module.ts` aan

```typescript
// src/app.module.ts
import { ConfigModule, ConfigService } from '@nestjs/config';
...
export class AppModule {
  constructor(private configService: ConfigService) { }// 👈 1

  configure(consumer: MiddlewareConsumer) {// 👈 2
    const isLoggingDisabled = this.configService.get<boolean>('logging.disabled', false);// 👈 3

    if (!isLoggingDisabled) {
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
import { Test, TestingModule } from '@nestjs/testing';// 👈 1
import { INestApplication } from '@nestjs/common';// 👈 1
import * as request from 'supertest';// 👈 1
import { AppModule } from '../src/app.module';// 👈 1

describe('Health', () => {// 👈 2
  let app: INestApplication;// 👈 3

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();// 👈 4

    app = moduleFixture.createNestApplication();// 👈 5
    await app.init();// 👈 6
  });

  afterAll(async () => {
    await app.close();
  });// 👈 7

});
```

1. We importeren de NestJS testing utilities en supertest voor HTTP requests.

- `Test`: een statische klasse die factory methoden biedt om `TestingModule` instanties te maken. Het is de startpunt voor alle NestJS testing.
- `TestingModule`: creëert een geïsoleerde instantie van de NestJS applicatie speciaal voor testing.
- `INestApplication`: een interface uit NestJS die het hoofdapplicatie-object representeert.
- `supertest`: stelt je in staat om HTTP requests te maken naar je API (GET, POST, PUT, DELETE, etc.), responses te valideren (status codes, body content, headers). Dit alles te doen zonder een echte server op te starten.

2. Groepeer de testen voor de health in een test suite met naam "Health".
3. Definieer de variabele `app` die een instantie van onze app zal bevatten
4. Gebruik `Test.createTestingModule()` om een complete NestJS applicatie op te zetten in test modus. Importeer AppModule. `compile()`compileert en retourneert een gebruiksklare TestingModule
5. `moduleFixture.createNestApplication()` creëert een `INestApplication` instantie uit de `TestingModule`.
6. `app.init()` initialiseert de applicatie, inclusief alle modules, controllers en services.
7. Nadat alle testen gerund hebben, sluiten we de applicatie netjes af met `app.close()`.

#### De test zelf

Nu is het tijd om een eerste echte integratietest te schrijven!

```typescript
// test/health.e2e-spec.ts
describe('Health', () => {
  // ...

   describe('GET /api/health/ping', () => {
    const url = '/health/ping';

    it('should return pong', async () => {// 👈 1
      const response = await request(app.getHttpServer()).get(url);// 👈 2

      expect(response.statusCode).toBe(200);// 👈 3
      expect(response.body).toEqual({ pong: true });// 👈 3
    });
  });
```

1. We maken een nieuwe test aan voor de `GET /api/health/ping` endpoint.
2. We sturen een GET request naar `/api/health/ping` met `supertest`.
3. We verwachten statuscode 200 en controleren de response.

Voer de test uit met `pnpm test:e2e --watch` en controleer of de test slaagt.

### Refactoring

De setup zal in elke TestSuite opnieuw moeten gebeuren, daarom maken we een helper functie om de App te initialiseren. In de `/test/helpers`folder maak je een bestand `create-app.ts`. Dit bevat de code uit `beforeAll`

```typescript
// test/helpers/create-app.ts
import {
  INestApplication,
} from '@nestjs/common';
import { TestingModule, Test } from '@nestjs/testing';
import { AppModule } from '../../src/app.module';


export async function createTestApp(): Promise<INestApplication> {
  const moduleFixture: TestingModule = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  const app = moduleFixture.createNestApplication();
  await app.init();
  return app;
}
```

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

Om de andere endpoints te testen hebben we testdata nodig. Hiervoor maken we gebruik van een testdatabase. Voeg onderstaand script toe aan package.json en run het script om de tabellen aan te maken.

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

## GET /api/places/:id

Maak een nieuwe file `test/places.e2e-spec.ts` aan.

### de test setup

```typescript
import { INestApplication } from '@nestjs/common';
import {
  DatabaseProvider,
  DrizzleAsyncProvider,
} from '../src/drizzle/drizzle.provider';// 👈 1
import { createTestApp } from './helpers/create-app';
import { seedPlaces, clearPlaces } from './seeds/places';

describe('Places', () => {
  let app: INestApplication;
  let drizzle: DatabaseProvider;// 👈 1

  const url = '/places';

  beforeAll(async () => {
    app = await createTestApp();
    drizzle = app.get(DrizzleAsyncProvider);// 👈 2

    await seedPlaces(drizzle);// 👈 3

  });

  afterAll(async () => {
    await clearPlaces(drizzle);// 👈 4
    await app.close();
  });

});
```

De setup is analoog aan de Health test, maar nu dienen we ook de database te seeden.

1. Maak een variabele aan van het type `DatabaseProvider`
2. Localiseer een instantie van `DrizzleAsyncProvider`.
3. Seed de tabel `places`
4. Ruim deze data op na de testen.

### GET /api/places/

```typescript
 describe('GET /api/places', () => {
    it('should 200 and return all places', async () => {
      const response = await request(app.getHttpServer())
        .get(url);

      expect(response.statusCode).toBe(200);

      expect(response.body.items.length).toBe(3);

      expect(response.body.items).toEqual(
        expect.arrayContaining([
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
        ]),
      );
    });
  });
```

### Oefening 1 - GET /api/places/:id

Schrijf een test voor het endpoint `GET /api/places/:id`:

1. Maak een nieuwe test suite aan voor het endpoint `GET /api/places/:id`.
2. Voer de test uit:
   1. Check of de statuscode gelijk is aan 200.
   2. Check of de geretourneerde plaats zoals verwacht is.

- Oplossing +

  ```typescript
  describe('GET /api/places/:id', () => {
      it('should 200 and return the requested place', async () => {
        const response = await request(app.getHttpServer())
          .get(`${url}/1`);

        expect(response.statusCode).toBe(200);

        expect(response.body).toMatchObject({
          id: 1,
          name: 'Loon',
          rating: 5,
        });
      });

    });
  ```

D.i. de positieve test case (happy path). Wat zijn de mogelijke alternatieve scenario's?

- Negatieve test cases (error scenarios)
- Edge cases (grenssituaties)
- Validatie tests

Schrijf ook hiervoor testen.

- Oplossing +

  ```typescript
  describe('GET /api/places/:id', () => {
    it('should 404 when requesting not existing place', async () => {
      const response = await request(app.getHttpServer())
        .get(`${url}/5`);

      expect(response.statusCode).toBe(404);

      expect(response.body.message).toEqual('No place with this id exists');
    });

    it('should 400 with invalid place id', async () => {
      const response = await request(app.getHttpServer())
        .get(`${url}/invalid`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe(
        'Validation failed (numeric string is expected)',
      );
    });
    });
  ```

### POST /api/places

Maak een nieuwe test suite aan voor het endpoint `POST /api/places`. Welke testcases hebben we hier?

```typescript
  describe('POST /api/places', () => {
    it('should 201 and return the created place', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({ name: 'New place' });

      expect(response.statusCode).toBe(201);

      expect(response.body.id).toBeTruthy();

      expect(response.body.name).toBe('New place');

      expect(response.body.rating).toBeNull();
    });

    it("should 200 and return the created place with it's rating", async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'Lovely place',
          rating: 5,
        });

      expect(response.statusCode).toBe(201);

      expect(response.body).toEqual(
        expect.objectContaining({
          id: expect.any(Number),
          name: 'Lovely place',
          rating: 5,
        }),
      );
    });

    it('should 409 for duplicate place name', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({ name: 'Lovely place' });

      expect(response.statusCode).toBe(409);
      expect(response.body).toMatchObject({
        message: 'A place with this name already exists',
      });
    });

    it('should 400 when missing name', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({ rating: 3 });

      expect(response.statusCode).toBe(400);

      expect(response.body.details.body).toHaveProperty('name');
    });

    it('should 400 when rating lower than one', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'The wrong place',
          rating: 0,
        });

      expect(response.statusCode).toBe(400);

      expect(response.body.details.body).toHaveProperty('rating');
    });

    it('should 400 when rating higher than five', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'The wrong place',
          rating: 6,
        });

      expect(response.statusCode).toBe(400);

      expect(response.body.details.body).toHaveProperty('rating');
    });

    it('should 400 when rating is a decimal', async () => {
      const response = await request(app.getHttpServer())
        .post(url)
        .send({
          name: 'The wrong place',
          rating: 3.5,
        });

      expect(response.statusCode).toBe(400);

      expect(response.body.details.body).toHaveProperty('rating');
    });
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
          });

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
          });

        expect(response.statusCode).toBe(409);
        expect(response.body.message).toEqual(
          'A place with this name already exists',
        );
      });

      it('should 400 when missing name', async () => {
        const response = await request(app.getHttpServer())
          .put(`${url}/1`)
          .send({ rating: 3 });

        expect(response.statusCode).toBe(400);

        expect(response.body.details.body).toHaveProperty('name');
      });

      it('should 400 when rating lower than one', async () => {
        const response = await request(app.getHttpServer())
          .put(`${url}/1`)
          .send({
            name: 'The wrong place',
            rating: 0,
          });

        expect(response.statusCode).toBe(400);
        expect(response.body.details.body).toHaveProperty('rating');
      });

      it('should 400 when rating higher than five', async () => {
        const response = await request(app.getHttpServer())
          .put(`${url}/1`)
          .send({
            name: 'The wrong place',
            rating: 6,
          });

        expect(response.statusCode).toBe(400);

        expect(response.body.details.body).toHaveProperty('rating');
      });

      it('should 400 when rating is a decimal', async () => {
        const response = await request(app.getHttpServer())
          .put(`${url}/1`)
          .send({
            name: 'The wrong place',
            rating: 3.5,
          });

        expect(response.statusCode).toBe(400);

        expect(response.body.details.body).toHaveProperty('rating');
      });
    });
  ```

### Oefening 3 - DELETE /api/places/:id

Schrijf de testen voor het endpoint `DELETE /api/places/:id`:

1. Maak een nieuwe test suite aan voor het endpoint `DELETE /api/places/:id`.
4. Voer de testen uit:
   1. Check of de statuscode gelijk is aan 204.
   2. Check of de plaats daadwerkelijk verwijderd is uit de database.

- Oplossing +

  ```typescript
  describe('DELETE /api/places/:id', () => {
    it('should 204 and return nothing', async () => {
      const response = await request(app.getHttpServer())
        .delete(`${url}/3`);

      expect(response.statusCode).toBe(204);
      expect(response.body).toEqual({});
    });

    it('should 400 with invalid place id', async () => {
      const response = await request(app.getHttpServer())
        .delete(`${url}/invalid`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe(
        'Validation failed (numeric string is expected)',
      );
    });

    it('should 404 with not existing place', async () => {
      const response = await request(app.getHttpServer())
        .delete(`${url}/3`);

      expect(response.statusCode).toBe(404);
      expect(response.body.message).toBe('No place with this id exists');
    });
  });
  ```

### Oefening 4 - Coverage

Vraag de coverage op van je testen met `pnpm test:cov`. Bekijk de gegenereerde HTML pagina in het bestand `test/coverage/lcov-report/index.html`. Wat merk je op?

- Oplossing +

  Je ziet dat we al een goede coverage hebben op de API endpoints. NestJS toont coverage voor controllers, services en andere modules.

  In de service laag hebben we misschien nog geen 100% omdat we bijvoorbeeld nog niet alle edge cases testen (zoals error handling voor ongeldige input).

### Oefening 5 - Testen voor de andere endpoints

Maak de testen aan voor alle endpoints in je applicatie. Denk na over:

- Positieve test cases (happy path)
- Negatieve test cases (error scenarios)
- Edge cases (grenssituaties)
- Validatie tests

## Oefening 6 - README

Vervolledig je `README.md` met de nodige informatie over het testen van je applicatie.

> **Oplossing voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les5-opl 88651f0
> yarn install
> yarn prisma migrate dev
> yarn start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.

## Extra's voor de examenopdracht

- Gebruik een andere test library (bv. [Mocha](https://mochajs.org/), [Jasmine](https://jasmine.github.io/), [Vitest](<http://localhost:3000/[https://](https://vitest.dev/)>)...)
- Voeg unit testen toe voor de services
