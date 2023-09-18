# Validatie en foutafhandeling

> "The first step of any project is to grossly underestimate its complexity and difficulty." - Nicoll Hunt

## budget app startpunt

```bash
~> git clone git@github.com:HOGENT-Web/webservices-budget.git (of git pull als het niet de eerste keer is)
~> cd webservices-budget
~/webservices-budget$> git checkout -b les9 c1eb3b0
~/webservices-budget$> yarn install
```

## Invoervalidatie

- maak geen aannames over de gegevens die je ontvangt
- enkel validatie in de frontend is onvoldoende (is makkelijk te omzeilen)
- ooit zal iemand een verzoek sturen dat iets zal breken
- invoervalidatie is gericht op het verifiëren van de ontvangen gegevens. bv. in de `POST /api/transactions` moet het bedrag van de transactie een geldig getal zijn (geen string, object...) én is het verplicht op te geven
- indien aan de validatie niet voldaan is, retourneer je een status code 400 (= bad request) en geef je details over de fout. Zonder bijkomende informatie is de HTTP 400 nutteloos.
- bij validatiefouten stop je onmiddellijk de verdere verwerking en retourneer je een passende foutboodschap voor de client
- stuur het response zo snel mogelijk terug naar de client (= fail-fast principe)
- de oorzaak van de validatiefout moet goed worden uitgelegd en begrepen door de client
- technische aspecten mag je om veiligheidsredenen niet retourneren
- we gebruiken hiervoor een [fluent validation API](https://en.wikipedia.org/wiki/Fluent_interface) genaamd [Joi](https://joi.dev/)

```bash
~/webservices-budget$ yarn add joi
```

### Invoervalidatie in Koa

- er zijn wel wat packages die invoervalidatie in Koa ondersteunen (zie [https://github.com/koajs/koa/wiki#parameter-validation](https://github.com/koajs/koa/wiki#parameter-validation))
- maar deze zijn vaak verouderd, niet onderhouden, niet geschikt voor de laatste versie van Koa of te beperkt in hun functionaliteit
- dus we gaan zelf een invoervalidatie middleware schrijven

## Joi

- we gebruiken [Joi](https://joi.dev/api/) om de invoer te valideren
- invoervalidatie in Joi bestaat uit 2 stappen

1. definieer het validatieschema a.d.h.v. [de ingebouwde functies](https://joi.dev/api/) in Joi
2. valideer de data tegen het schema a.d.h.v. [`Joi.validate(...)`](https://joi.dev/api/?v=17.7.0#anyvalidatevalue-options)

### Joi: definitie schema

- Joi ondersteunt alle soorten primitieven (strings, numbers...), evenals reguliere expressies
- het kan tot elke diepte worden genest
- je kan complexe structuren met zelfs selecties en verwijzingen toevoegen
- het is onmogelijk om alle functies te overlopen, we leren de API door hem te gebruiken (zoals elke developer altijd zou moeten doen)
- alle mogelijkheden vind je in de [documentatie](https://joi.dev/api)

### GET /api/transactions/:id - definitie schema

We gaan onze invoervalidatie definiëren voor de API call om één transactie op te halen
`rest/_transactions.js`

```js
const Joi = require('joi'); // 👈 1
// ...
const getTransactionById = async (ctx) => {
  // ...
};
// 👈 2
getAllTransactions.validationScheme = {
  params: Joi.object({
    id: Joi.number().integer().positive(),
  }), // 👈 3
};
```

1. we importeren Joi
2. vervolgens definiëren we een property `validationScheme` op onze functie `getTransactionById`. Herinner je: functies zijn zoals objecten, ze kunnen properties hebben
3. dit request kan enkel URL parameters bevatten. We schrijven de validatie hiervoor in een property `params`

- `Joi.object({})` genereert een schema dat kan valideren of iets een object is met de opgegeven keys
- `id`: de naam van de parameter
- `Joi.number()`: het moet een geheel getal zijn, een id kan nooit 1,5 of 12,345 zijn bijvoorbeeld
- `positive()`: en het moet positief zijn
- `required()`: we kunnen expliciet aangeven dat iets verplicht is of `optional()`: optioneel. Maar we laten beide functies hier achterwege. Straks stellen we in dat alles standaard `required` is, dat bespaart wat werk. In een API is typisch meer `required` dan `optional`.

### GET api/transactions/:id - validatie middleware

Vervolgens definiëren we een helper die een gegeven validatie-schema zal afchecken tegen de binnengekomen URL parameters, URL parameters en body (in de Koa Context)

`rest/_validation.js`

```js
const Joi = require('joi'); // 👈 1

const JOI_OPTIONS = {
  abortEarly: true,
  allowUnknown: false,
  context: true,
  convert: true,
  presence: 'required',
}; // 👈 8

// 👈 2
const validate = (schema) => {
  if (!schema) {
    schema = {
      query: {},
      body: {},
      params: {},
    };
  } // 👈 3

  // 👈 4
  return (ctx, next) => {
    const errors = {}; // 👈 5
    if (!Joi.isSchema(schema.params)) {
      schema.params = Joi.object(schema.params || {});
    } // 👈 6
    const { error: paramsError, value: paramsValue } = schema.params.validate(
      ctx.params,
      JOI_OPTIONS // 👈 8
    ); // 👈 7

    if (paramsError) {
      errors.params = cleanupJoiError(paramsError);
    } else {
      ctx.params = paramsValue;
    } // 👈 9

    if (Object.keys(errors).length) {
      ctx.throw(400, 'Validation failed, check details for more information', {
        code: 'VALIDATION_FAILED',
        details: errors,
      });
    } // 👈 10

    return next(); // 👈 4
  };
};
module.exports = validate; // 👈 2
```

1. Importeer Joi
2. Maak de `validate` functie aan en exporteer
3. Indien er geen schema werd opgegeven, creëren we een leeg object voor alle mogelijke parameters
4. Deze functie retourneert Koa middleware. We doen `return next()` aangezien het geen zin heeft om nog verder te doen na de validatie. Bij een fout zullen we een 400 terugsturen met een duidelijke foutmelding en doen we verder niks. Zonder fout kunnen we gewoon verder, we hebben niks meer te doen hier.
5. We definiëren een object waarin onze validatiefouten per type komen. Een eerste type is bv. de `params` parameters.
6. Indien we een schema kregen voor de params parameters, dan controleren we eerst of het effectief een instantie van een Joi schema is (bv. door `Joi.object()`) gemaakt. Zo niet, dan creëren we dit zelf, met een leeg schema indien er niets opgegeven werd. Dit is nodig aangezien de `validate` functie enkel beschikbaar is op een Joi schema.
7. We voeren de validatie uit m.b.v. de [`validate`](https://joi.dev/api/?v=17.4.2#anyvalidatevalue-options) functie. Als de invoer geldig is, is `error` undefined en bevat value de gevalideerde en genormaliseerde waarde. Als de invoer ongeldig is, wordt aan de error een [ValidationError](https://joi.dev/api/?v=17.4.2#errors) object toegewezen dat meer informatie geeft.
8. We geven ook enkele opties `JOI_OPTIONS` mee aan deze functie. We bewaren deze opties globaal aangezien we nog de query parameters en body moeten valideren
   - `abortEarly`: wanneer true (default), stopt de validatie bij de eerste fout, anders worden alle gevonden fouten geretourneerd
   - `allowUnknown`: indien true, staat het object toe onbekende sleutels te bevatten die worden genegeerd (default: false)
   - `context`: biedt een externe gegevensset die in referenties kan worden gebruikt. Hebben we nodig voor `Joi.ref`.
   - `convert`: indien true (default), wordt geprobeerd waarden naar de vereiste typen te casten. Bv. een string naar een getal
   - `presence`: stelt de standaard aanwezigheidsvereisten in. Ondersteunde modi: 'optional' (default), 'required' en 'forbidden'
9. Indien fouten: formatteer en bewaar de fouten (zie verder). Indien geen fouten: stel de params context-waarde gelijk aan de `value`
10. Indien we fouten hadden, throwt de context een status code 400 (bad request) en worden de details van de fouten vermeld

### GET api/transactions/:id - errors formatteren

`rest/_validation.js`

```js
const cleanupJoiError = (
  error // 👈 1
) =>
  error.details.reduce((resultObj, { message, path, type }) => {
    // 👈 2 en 3
    const joinedPath = path.join('.') || 'value'; // 👈 3
    // 👈 4
    if (!resultObj[joinedPath]) {
      resultObj[joinedPath] = [];
    }
    resultObj[joinedPath].push({
      type,
      message,
    });

    return resultObj; // 👈 5
  }, {});
```

1. `error`: dit is een [ValidationError](https://joi.dev/api/?v=17.9.1#errors). Deze bevat een `details` property met een array van alle fouten
2. Per fout `{ message, path, type }` krijgen we volgende informatie:
   - `message`: beschrijving van de fout
   - `path`: geordende array waarbij elk element de accessor is van de waarde waar de fout is opgetreden
   - `type`: type van de fout
3. `joinedPath` voegt de paden samen d.m.v. een punt, of indien er geen paden zijn wordt de value genomen
4. en construeert een object met het gecombineerde pad als key en een array met alle fouten als value
5. Uiteindelijk retourneren we dit object

### GET api/transactions/:id - middleware toevoegen

`rest/_transaction.js`

```js
const validate = require('./_validation'); // 👈 1

// ...
//router.get('/;id', getTransactionById);// 👈 2
router.get(
  '/;id',
  validate(getTransactionById.validationScheme),
  getTransactionById
); // 👈 2
// ...
```

1. We importeren onze nieuwe middleware
2. De validatie dient te gebeuren alvorens de functie `getTransactionById` wordt uitgevoerd. Dus we voegen de middleware vòòr deze functie toe. I.g.v. een fout zal een HTTP status 400 geretourneerd worden.

Merk op: Nu kan je ook de conversie met `Number(...)` verwijderen uit `getTransactionById` (Joi doet dit voor ons)

### POST api/transactions - definitie schema

Ook voor de `POST /api/transactions` definiëren we een schema voor invoervalidatie.

`rest/_transactions.js`

```js
const createTransaction = async (ctx) => {
  // ...
};
// 👈 1
createTransaction.validationScheme = {
  body: {
    amount: Joi.number().invalid(0),
    date: Joi.date().iso().less('now'),
    placeId: Joi.number().integer().positive(),
    user: Joi.string(),
  }, // 👈 2
};
```

1. Voeg het schema voor invoervalidatie toe
2. Hier valideren we enkel de `body` van het HTTP request. Er zijn verder geen parameters voor dit HTTP request

- `amount`: moet een getal zijn, maar mag niet 0 zijn
- `date`: moet in ISO formaat staan en moet voor vandaag liggen
- `placeId`: moet een positief geheel getal zijn
- `user`: moet een string zijn. Als je reeds authenticatie in je API hebt, is de user uiteraard niet nodig!

### POST api/transactions - validatie

We dienen nu ook de `body` property te valideren, op een analoge manier als de `params`. Voeg deze code toe onder de validatie van het `params` property (net voor de check of er errors zijn)

`rest/_validation.js`

```js
if (!Joi.isSchema(schema.body)) {
  schema.body = Joi.object(schema.body || {});
}

const { error: bodyError, value: bodyValue } = schema.body.validate(
  ctx.request.body,
  JOI_OPTIONS
);

if (bodyError) {
  errors.body = cleanupJoiError(bodyError);
} else {
  ctx.request.body = bodyValue;
}
```

OEFENING : zorg dat de validatie wordt uitgevoerd als het POST-request wordt uitgevoerd

## Request logging

We voegen een extra middleware toe die elk binnenkomend request zal loggen. Dit helpt enorm bij het debuggen. We voegen dit toe voor het toevoegen van de `bodyParser` middleware

`src/core/installMiddleware.js`

```js
const emoji = require('node-emoji'); // 👈 2
// ...
// 👈 1
app.use(async (ctx, next) => {
  if (ctx.url === '/api/health/ping') return next(); // 👈 7

  getLogger().info(`${emoji.get('fast_forward')} ${ctx.method} ${ctx.url}`); // 👈 3

  const getStatusEmoji = () => {
    if (ctx.status >= 500) return emoji.get('skull');
    if (ctx.status >= 400) return emoji.get('x');
    if (ctx.status >= 300) return emoji.get('rocket');
    if (ctx.status >= 200) return emoji.get('white_check_mark');
    return emoji.get('rewind');
  }; // 👈 4
  try {
    await next(); // 👈 5

    getLogger().info(
      `${getStatusEmoji()} ${ctx.method} ${ctx.status} (${ctx.response.get(
        'X-Response-Time'
      )}) ${ctx.url}`
    ); // 👈 5
  } catch (error) {
    getLogger().error(
      `${emoji.get('x')} ${ctx.method} ${ctx.status} ${ctx.url}`,
      {
        error,
      }
    );

    throw error;
  } // 👈 6
});

app.use(bodyParser());
// ...
```

1. Voeg deze middleware toe net voor de de installatie van de bodyParser middleware.
2. We installeren een nieuw package: `yarn add node-emoji`. Daarmee kunnen we leuke emoji's tonen in de console.
3. We loggen alvast wanneer het request binnen komt. In Koa kan een request soms "uitsterven" door foutieve async/await, errors die "opgegeten" worden... Dan is het altijd handig om te weten of het request effectief binnen kwam of niet.
4. We definiëren een inline functie om de juiste emoji te krijgen afhankelijk van de HTTP status code van het response
5. We wachten de request afhandeling af en loggen het resultaat
6. We voegen een try/catch toe om eventuele fouten tijdens de request afhandeling op te vangen. Indien er een error was, dan loggen we die ook. Gooi zeker de error opnieuw: deze middleware handelt hem niet af. **Doe altijd maar één ding in een middleware**
7. I.g.v. een ping request wachten we de request afhandeling niet af.

## Error handling

### Error handling: ServiceError

We definiëren een klasse die een error uit de service-laag voorstelt. Het is een bad practice om in de service-laag een HTTP status code in een error te schrijven. Daarmee forceer je de applicatie richting HTTP (en dus REST)

`core/serviceError.js`

```js
const NOT_FOUND = 'NOT_FOUND'; // 👈 2
const VALIDATION_FAILED = 'VALIDATION_FAILED'; // 👈 2

// 👈 1
class ServiceError extends Error {
  // 👈 3
  constructor(code, message, details = {}) {
    super(message);
    this.code = code;
    this.details = details;
    this.name = 'ServiceError';
  }

  static notFound(message, details) {
    return new ServiceError(NOT_FOUND, message, details);
  } // 👈 5

  static validationFailed(message, details) {
    return new ServiceError(VALIDATION_FAILED, message, details);
  } // 👈 5

  get isNotFound() {
    return this.code === NOT_FOUND;
  } // 👈 4

  get isValidationFailed() {
    return this.code === VALIDATION_FAILED;
  } // 👈 4
}

module.exports = ServiceError;
```

1. Definieer de klasse ServiceError
2. Definieer een aantal constante strings die alle mogelijke errors voorstellen
3. Definieer een constructor die een foutcode, bericht en eventuele details meekrijgt
4. Daarnaast voorzien we enkele getters om te kijken welk type fout opgetreden is
5. En enkele static methods om een specifieke fout te throwen

### Error handling: middleware

We voegen een extra middleware toe om fouten af te handelen. Voeg dit als laatste toe in `installMiddleware.js`

`src/core/installMiddleware.js`

```js
// ...
// 👈 1
app.use(async (ctx, next) => {
  try {
    await next(); // 👈 2
  } catch (error) {
    getLogger().error('Error occured while handling a request', { error }); // 👈 3
    let statusCode = error.status || 500; // 👈 4
    let errorBody = {
      code: error.code || 'INTERNAL_SERVER_ERROR',
      message: error.message,
      details: error.details || {},
      stack: NODE_ENV !== 'production' ? error.stack : undefined,
    }; // 👈 4

    if (error instanceof ServiceError) {
      if (error.isNotFound) {
        statusCode = 404;
      }

      if (error.isValidationFailed) {
        statusCode = 400;
      }

      }
    } // 👈 5

    ctx.status = statusCode; // 👈 6
    ctx.body = errorBody; // 👈 6
  }
});

// 👈 7
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
```

1. Voeg een stukje middleware toe
2. Definiëren een try/catch en laat het request gewoon doorgaan. We willen enkel een mogelijke error opvangen.
3. Log alvast de error die opgetreden is. Een standaard JavaScript error wordt niet goed geprint op de console, door er een object van te maken gebeurt dit wel goed.
4. Vervolgens maken we reeds onze response body op. Voorlopig nemen we de status uit de Koa context of standaard 500
5. Vervolgens updaten we de status als de opgetreden error een `ServiceError` is en we kennen de error
6. Als laatste stellen we de `status` en `body` van het response in
7. Het enige geval waarbij we geen mooi error response hebben is een 404 van de Koa router. Dit vangen we op deze manier op

tip: kijk eens wat een mooi response we krijgen als we verkeerde invoer geven 🤩

### ServiceError gebruiken

Nu moeten we enkel nog onze eigen `ServiceError` gebruiken in se service-laag. We dienen alle errors op te vangen en om te vormen naar een `ServiceError`.

Als we een record toevoegen aan de database dan kan er van alles foutlopen:

- niet voldaan aan unique constraint
- niet voldaan aan de referentiële integriteit

  Hiervoor maken we eerst een aparte functie `handleDBError`, daar dit binnen de verschillende modules kan gebruikt worden

`src/service/_handleDbError.js`

```js
const ServiceError = require('../core/serviceError'); // 👈 2

// 👈 1
const handleDBError = (error) => {
  const { code = '', sqlMessage } = error; // 👈 3

  // 👈 4
  if (code === 'ER_DUP_ENTRY') {
    switch (true) {
      case sqlMessage.includes('idx_place_name_unique'):
        throw ServiceError.validationFailed(
          'A place with this name already exists'
        );
      case sqlMessage.includes('idx_user_email_unique'):
        throw ServiceError.validationFailed(
          'There is already a user with this email address'
        );
      default:
        throw ServiceError.validationFailed('This item already exists');
    }
  }

  if (code.startsWith('ER_NO_REFERENCED_ROW')) {
    switch (true) {
      case sqlMessage.includes('fk_transaction_user'):
        throw ServiceError.notFound('This user does not exist');
      case sqlMessage.includes('fk_transaction_place'):
        throw ServiceError.notFound('This place does not exist');
    }
  }

  // Rethrow error because we don't know what happened
  throw error;
};

module.exports = handleDBError; // 👈 1
```

1. Creëer een functie die gegeven een database error een `ServiceError` throwt en exporteer
2. Importeer `ServiceError`
3. Destructor de fout
4. Afhankelijk van de sqlMessage, bepaald door de unique index of de gedefinieerde relaties, throwen we de juiste `ServiceError`

Pas dan de servicelaag aan, zodat deze nu gebruik maakt van onze eigen `ServiceError` voor het afhandelen van fouten.

`src/service/transaction.js`

```js
const ServiceError = require('../core/serviceError'); // 👈 1
const handleDBError = require('./_handleDBError'); // 👈 1

//...
const getById = async (id, userId) => {
  const transaction = await transactionRepository.findById(id);

  if (!transaction || transaction.user.id !== userId) {
    //       throw new Error(`There is no transaction with id ${id}`); // 👈 2
    throw ServiceError.notFound(`No transaction with id ${id} exists`, { id }); // 👈 2
  }

  return transaction;
};

const create = async ({ amount, date, placeId, userId }) => {
  const existingPlace = await placeService.getById(placeId);

  if (!existingPlace) {
    throw ServiceError.notFound(`There is no place with id ${id}.`, { id }); // 👈 3
  }

  const id = await transactionRepository
    .create({
      amount,
      date,
      userId,
      placeId,
    })
    .catch(handleDBError); // 👈 4
  return getById(id, userId);
};
//...
```

1. Importeer `ServiceError` en `handleDBError`.
2. Vervang elke `Error` door de juiste `ServiceError` zoals bij de `getById`. Bekijk het response wanneer je een onbestaande transactie opvraagt.
3. Throw een ServiceError NotFound als de plaats niet bestaat in de `create` method.
4. Als de create van een transactie mislukt, rethrowen we een `ServiceError`.

## Oefening 1

- check uit op commit 820b9fa van onze voorbeeldapplicatie <!--TODO--> en bekijk de invoervalidatie voor `deleteTransaction`. Hier wordt gebruik gemaakt van een URL parameter. De validate-functie is hiervoor aangepast
- Ook voor de overige endpoints werd een validatieschema toegevoegd.
- Integratietesten werden toegevoegd om te checken op invoervalidatie

## Oefening 2

Werk aan je eigen project

- Maak gebruik van invoervalidatie voor alle endpoints en voeg de `validate()` functie toe
- Voeg de Request logging middleware toe
- Voeg foutafhandeling toe

TIP: als extra kan je een ander validatie framework gebruiken

## koa helmet

De module ["koa-helmet"](https://www.npmjs.com/package/koa-helmet) is een middleware voor Koa. `koa-helmet` is een wrapper voor [`helmet voor express`](https://github.com/helmetjs/helmet) om met koa te werken. Het stelt verschillende HTTP response headers in om de beveiliging van webapplicaties die met Koa zijn gebouwd te verbeteren.

Enkele van de beveiligingsheaders die door "koa-helmet" zijn geïmplementeerd, zijn onder meer:

- Content Security Policy (CSP): Het helpt Cross-Site Scripting (XSS)-aanvallen te voorkomen. [Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- X-Content-Type-Options: Het voorkomt aanvallen van content-sniffing attacks door de browser te dwingen zich aan het aangegeven content-types te houden. [Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options)
- Strict-Transport-Security: Het dwingt het gebruik van veilige HTTPS-verbindingen af ​​door de browser te instrueren om alleen via HTTPS toegang te krijgen tot de website. [Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)
- X-Frame-opties: Het voorkomt clickjacking-aanvallen door te beperken waar uw site in een iframe kan worden ingesloten.[Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options)

Meer info op [https://github.com/helmetjs/helmet](https://github.com/helmetjs/helmet)

Samenvattend vereenvoudigt "koa-helmet" het proces van het instellen en beheren van beveiligingsheaders in Koa-applicaties, waardoor de algehele beveiligingspositie wordt verbeterd en bescherming wordt geboden tegen veelvoorkomende webkwetsbaarheden. Het helpt het risico op verschillende beveiligingsproblemen te minimaliseren en beschermt de gebruikers en de applicatie tegen mogelijke aanvallen.

### koa helmet installeren

```bash
> yarn add koa-helmet
```

Pas `installMiddleware.js`. Installeer koa-helmet in de middleware pipeline.
`./core/installMiddleware.js`

```js
const koaHelmet = require('koa-helmet');
//..
// Add the body parser
app.use(bodyParser());

// Add some security headers
app.use(koaHelmet());

// Add CORS
//..
```
