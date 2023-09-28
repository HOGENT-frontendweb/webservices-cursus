# Testing

<!-- TODO: startpunt aanpassen -->

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-Web/webservices-budget/
> cd webservices-budget
> git checkout -b les5 TODO:
> yarn install
> yarn start
> ```

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

## Tools

Om testen te kunnen maken heb je nood aan een test library en een test runner. Binnen JavaScript zijn er verschillende mogelijkheden:

- [Jest](https://jestjs.io/)
- [Mocha](https://mochajs.org/)
- [Jasmine](https://jasmine.github.io/)
- [Vitest]([https://](https://vitest.dev/))

## Integratietesten

In deze cursus focussen we ons op integratietesten. We schrijven hier integratietesten om te testen of de verschillende onderdelen van onze applicatie goed samenwerken (bv. validatie, authenticatie...). We gebruiken hiervoor [Jest](https://jestjs.io/), een populaire test library voor JavaScript. Jest is een te groot framework om volledig in detail te behandelen, dus we beperken ons tot wat wij specifiek nodig hebben. Zoals elke developer, moet jij in staat zijn om zelfstandig een nieuwe functionaliteit op te zoeken en te leren gebruiken.

> 💡 Tip: voel je vrij om een andere library te gebruiken in je eigen project.

Om integratietesten uit te voeren, heb je een draaiende server nodig. Dat is niet zo handig want dan moet je steeds twee commando's uitvoeren: 1) server starten en 2) testen uitvoeren. Wij gaan ervoor zorgen dat we met één commando de testen kunnen uitvoeren zonder onze server expliciet te hoeven starten.

We installeren eerst de nodige dependencies:

```bash
yarn add --dev jest
yarn add --dev supertest
```

- [**jest**](https://jestjs.io/): de test library en test runner
- [**supertest**](https://www.npmjs.com/package/supertest): een library om HTTP requests te maken naar een server en de response te testen
  - wij gaan dit enkel gebruiken om HTTP requests te kunnen sturen zonder een echte server te moeten opzetten
  - we gebruiken de in Jest ingebouwde functionaliteiten om de response te testen

### Configuratie

Eerst en vooral moeten we onze server configureerbaar maken in test modus. Maak een bestand `config/test.js` aan en kopieer de inhoud van `config/development.js` hiernaar. Pas de naam van de databank aan naar `budget_test` (via het property `database.name`) en schakel de logging uit (zet `log.disabled` op `true`). Normaal zou de andere databankconfiguratie identiek moeten zijn aan de development-omgeving (die is nl. ook bedoeld om lokaal te draaien).

Maak vervolgens een `.env.test` aan in de root map, met volgende inhoud:

```ini
NODE_ENV=test
```

Later gebruiken we dit bestand om ervoor te zorgen dat het juiste configuratiebestand wordt ingeladen.

We laten Jest een leeg configuratiebestand aanmaken:

```bash
yarn jest --init
```

Antwoord op de vragen als volgt:

- Would you like to use Jest when running "test" script in "package.json"?: yes
- Would you like to use Typescript for the configuration file?: no
- Choose the test environment that will be used for testing: node
- Do you want Jest to add coverage reports?: yes
- Which provider should be used to instrument code for coverage?: v8
- Automatically clear mock calls, instances, contexts and results before every test?: no

Dit commando maakt een bestand `jest.config.js` aan. Je vindt de nodige informatie over deze configuratie op <https://jestjs.io/docs/configuration>.

Jest zoekt standaard naar testen met volgende reguliere expressies: `**/__tests__/**/*.[jt]s?(x)` en `**/?(*.)+(spec|test).[tj]s?(x)`. Het zoekt dus naar bestanden die zich in een map `__tests__` bevinden, of bestanden die eindigen op `.spec.js`, `.test.js`, `.spec.ts` of `.test.ts`.

Je kan ervoor opteren om unit testen te maken voor bv. de servicelaag. In dat geval maak je een map `__tests__` aan in de `src/service` map en plaats je daar je unit testen in. We plaatsen onze testen in een map `__tests__` in de root map van onze applicatie, want het zijn integratietesten voor de hele applicatie.

We moeten wel nog het automatisch gegenereerde `test` script aanpassen zodat ons `.env.test` bestand wordt ingeladen. Pas het `test` script in `package.json` aan als volgt:

```json
{
  "scripts": {
    "start": "env-cmd nodemon",
    "test": "env-cmd -f .env.test jest"
  },
}
```

## Refactoring

We gaan onze code wat refactoren zodat we onze testen kunnen schrijven. We gaan ervoor zorgen dat:

1. de installatie van onze middlewares afgezonderd is in een aparte functie;
2. onze server gestart kan worden zonder dat de server effectief luistert naar requests;

### Installatie middlewares afzonderen

Maak een nieuw bestand `src/core/installMiddlewares.js`. Maak en exporteer een functie `installMiddlewares` die alle huidige middlewares (buiten de routers) installeert in een Koa applicatie. Deze Koa applicatie wordt meegegeven als parameter. Kopieer ook de nodige imports en configuratievariabelen.

```js
const koaCors = require('@koa/cors');
const config = require('config');
const bodyParser = require('koa-bodyparser');
const koaHelmet = require('koa-helmet');
const koaQs = require('koa-qs');
const { koaSwagger } = require('koa2-swagger-ui');
const emoji = require('node-emoji');
const swaggerJsdoc = require('swagger-jsdoc');

const { getLogger } = require('./logging');
const ServiceError = require('./serviceError');
const swaggerOptions = require('../swagger.config');

const NODE_ENV = config.get('env');
const EXPOSE_STACK = config.get('exposeStack');
const CORS_ORIGINS = config.get('cors.origins');
const CORS_MAX_AGE = config.get('cors.maxAge');
const isDevelopment = NODE_ENV === 'development';

/**
 * Install all required middlewares in the given app.
 *
 * @param {koa.Application} app - The Koa application.
 */
module.exports = function installMiddleware(app) {
  // Log when requests come in and go out
  app.use(async (ctx, next) => {
    getLogger().info(`${emoji.get('fast_forward')} ${ctx.method} ${ctx.url}`);

    const getStatusEmoji = () => {
      if (ctx.status >= 500) return emoji.get('skull');
      if (ctx.status >= 400) return emoji.get('x');
      if (ctx.status >= 300) return emoji.get('rocket');
      if (ctx.status >= 200) return emoji.get('white_check_mark');
      return emoji.get('rewind');
    };

    try {
      await next();

      getLogger().info(
        `${getStatusEmoji()} ${ctx.method} ${ctx.status} (${ctx.response.get('X-Response-Time')}) ${ctx.url}`,
      );
    } catch (error) {
      getLogger().error(`${emoji.get('x')} ${ctx.method} ${ctx.status} ${ctx.url}`, {
        error,
      });

      // Rethrow the error for further handling by Koa
      throw error;
    }
  });

  // Add the body parser
  app.use(bodyParser());

  // Add some security headers
  app.use(koaHelmet({
    // Not needed in development (destroys Swagger UI)
    contentSecurityPolicy: isDevelopment ? false : undefined,
  }));

  // Add CORS
  app.use(koaCors({
    origin: (ctx) => {
      if (CORS_ORIGINS.indexOf(ctx.request.header.origin) !== -1) {
        return ctx.request.header.origin;
      }
      // Not a valid domain at this point, let's return the first valid as we should return a string
      return CORS_ORIGINS[0];
    },
    allowHeaders: [
      'Accept',
      'Content-Type',
      'Authorization',
    ],
    maxAge: CORS_MAX_AGE,
  }));

  // Add a handler for known errors
  app.use(async (ctx, next) => {
    try {
      await next();
    } catch (error) {
      getLogger().error('Error occured while handling a request', {
        error,
      });

      let statusCode = error.status || 500;
      let errorBody = {
        code: error.code || 'INTERNAL_SERVER_ERROR',
        message: error.message,
        details: error.details || {},
        stack: EXPOSE_STACK ? error.stack : undefined,
      };

      if (error instanceof ServiceError) {
        if (error.isNotFound) {
          statusCode = 404;
        }

        if (error.isValidationFailed) {
          statusCode = 400;
        }

        if (error.isUnauthorized) {
          statusCode = 401;
        }

        if (error.isForbidden) {
          statusCode = 403;
        }
      }

      ctx.status = statusCode;
      ctx.body = errorBody;
    }
  });

  // Handle 404 not found with uniform response
  app.use(async (ctx, next) => {
    await next();

    if (ctx.status === 404) {
      ctx.status = 404;
      ctx.body = {
        code: 'NOT_FOUND',
        message: `Unknown resource: ${ctx.url}`,
      };
    }
  });
};
```

Importeer deze functie in `src/index.js` en gebruik ze om de middlewares te installeren:

```js
// imports
// ...
const installMiddlewares = require('./core/installMiddlewares'); // 👈

// ...
// configuratievariabelen

// ...
// logger initialiseren

installMiddlewares(app); // 👈

// ...
```

Start de server en controleer of alles nog werkt.

### Server starten zonder luisteren

We hernoemen `src/index.js` naar `src/createServer.js`.

<!-- TODO: aanvullen als code hoofdstuk 4 toegevoegd is -->

```js
```

Vervolgens maken we een nieuwe `src/index.js`:

```js
const createServer = require('./createServer'); // 👈 3

async function main() { // 👈 1
  // 👇 4
  try {
    const server = await createServer(); // 👈 5
    await server.start(); // 👈 5

    // 👇 6
    async function onClose() {
      await server.stop(); // 👈 6
      process.exit(0); // 👈 8
    }

    process.on('SIGTERM', onClose); // 👈 7
    process.on('SIGQUIT', onClose); // 👈 7
  } catch (error) {
    console.error(error); // 👈 4
    process.exit(-1); // 👈 4
  }
}
main(); // 👈 2
```

1. We maken een `main` functie aan die we async maken zodat we `await` kunnen gebruiken.
2. We roepen deze functie aan zodat de server effectief wordt gestart.
3. We importeren de `createServer` functie die we eerder hebben aangemaakt.
4. We maken een `try/catch` blok aan om eventuele fouten op te vangen. Als er een fout optreedt, loggen we deze en stoppen we de applicatie met een exit code `-1`.
5. We maken een server aan en starten deze meteen.
6. We maken een functie `onClose` aan die we gebruiken om de server te stoppen en de applicatie af te sluiten. Als we deze functie niet zouden gebruiken, dan wordt bv. de databankconnectie niet mooi afgesloten en gaat Jest nooit stoppen met uitvoeren van de testen.
7. We registreren deze functie als handler voor de `SIGTERM` en `SIGQUIT` events. Deze events worden getriggerd als de applicatie wordt gestopt (bv. door Jest).
8. Het is belangrijk om de applicatie zelf ook expliciet te stoppen met een exit code `0`. Dit wordt niet meer automatisch gedaan als je een handler registreert voor `SIGTERM` en `SIGQUIT`.

## Integratietesten schrijven

Jest voorziet een aantal globale functies die je kan gebruiken in je testen. De belangrijkste zijn:

- `describe`: definieert een test suite (= groeperen van testen)
- `test` of `it`: definieert een test
- `beforeAll`: definieert een functie die wordt uitgevoerd voor alle testen
- `afterAll`: definieert een functie die wordt uitgevoerd na alle testen
- `beforeEach`: definieert een functie die wordt uitgevoerd voor elke test
- `afterEach`: definieert een functie die wordt uitgevoerd na elke test

### GET /api/transactions

#### De opzet

Maak een nieuwe map `__tests__` aan in de root map van je applicatie. Maak hierin een bestand `transactions.spec.js` aan. Voor we effectief kunnen testen, moeten we ervoor zorgen dat de server klaar is voor gebruik.

```js
const supertest = require('supertest'); // 👈 1
const createServer = require('../../src/createServer'); // 👈 1
const { getKnex } = require('../../src/data'); // 👈

// 👇 2
describe('Transactions', () => {
  // 👇 3
  let server;
  let request;
  let knex;

  // 👇 4
  beforeAll(async () => {
    server = await createServer(); // 👈 5
    request = supertest(server.getApp().callback()); // 👈 6
    knex = getKnex(); // 👈 7
  });

  // 👇 8
  afterAll(async () => {
    await server.stop();
  });

  const url = '/api/transactions'; // 👈 9
});
```

1. Importeer `supertest` en `createServer` zodat we een server kunnen starten zonder dat deze luistert naar requests.
2. We groeperen onze testen voor de transacties in een test suite met naam "Transactions". `describe` definieert een test suite. De functie verwacht een naam en een functie als argument. De functie bevat de testen die we willen uitvoeren.
3. Definieer een aantal variabelen voor later.
4. We gebruiken de functie `beforeAll` om een aantal dingen uit te voeren voor alle testen uitgevoerd worden.
5. We maken een server.
6. We maken een supertest instantie waarmee we HTTP requests kunnen sturen naar de server.
7. We importeren onze Knex instantie zodat we de databank kunnen manipuleren.
8. Na alle testen stoppen we de server.
   - Je kan dit eens weglaten en dan zal je zien dat Jest de uitvoering nooit stopt. Dit komt omdat de connectie met de databank niet wordt afgesloten en Jest dus blijft wachten tot deze connectie wordt afgesloten.
9. We definiëren een constante `url` die we gebruiken om de URL van de API te definiëren. Dit is een goede gewoonte omdat je zo maar op één plaats de URL moet aanpassen als deze zou wijzigen.

#### De test zelf

<!-- TODO: hier verder gaan (slide 87) -->
