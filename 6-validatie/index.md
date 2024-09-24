# Validatie en foutafhandeling

<!-- TODO: startpunt en oplossing toevoegen -->

Heel wat REST API's die je online vindt, gaan er vanuit dat de invoer altijd correct is, geven totaal verkeerde foutmeldingen terug, of geven helemaal geen foutmeldingen. Dit is een bad practise! Een goede API geeft duidelijke foutmeldingen terug en valideert de invoer. Invoervalidatie is belangrijk voor de integriteit van de data en de veiligheid van de applicatie. Degelijke foutboodschappen helpen de gebruikers van de API om fouten te begrijpen en te corrigeren, indien mogelijk.

In dit hoofdstuk voegen we o.a. invoervalidatie, request logging en foutafhandeling toe aan onze Koa applicatie. Dit maakt onze applicatie robuuster en veiliger.

## Invoervalidatie

Een belangrijk principe bij het ontwikkelen van een API is het valideren van de invoer. Dit is belangrijk om de integriteit van de data te garanderen. Het is ook belangrijk om de gebruiker van de API te beschermen tegen zichzelf. Als de gebruiker een fout maakt, dan moet de API dit opvangen en een duidelijke foutmelding terugsturen.

Je mag geen aannames maken over de invoer die je ontvangt. **Je moet er vanuit gaan dat de invoer altijd fout kan zijn.** Enkel validatie in de front-end is onvoldoende, dit is eenvoudig te omzeilen. Ooit zal iemand een verzoek sturen dat iets zal breken.

Welke soorten invoer kan een HTTP request bevatten?

- Antwoord +

  - **URL parameters:** je kan bijvoorbeeld het id van een transactie meegeven in de URL, bv. `/api/transactions/1`.
  - **Query parameters:** je kan bijvoorbeeld een zoekopdracht meegeven in de URL, bv. `/api/places?name=loon`.
  - **Body:** als je een nieuwe transactie maakt, dan geef je de nodige gegevens mee in de body van het request.
  - **Headers:** in het volgende hoofdstuk gaan we zien hoe we een token meegeven in de headers van een request, zo kunnen we de gebruiker authenticeren.

  In ons voorbeeldproject voegen we invoervalidatie toe voor de URL parameters, query parameters en de body van het request.

Invoervalidatie is gericht op het verifiëren van de ontvangen gegevens. Bijvoorbeeld in de `POST /api/transactions` moet het bedrag van de transactie een geldig getal zijn (geen string, object...) én is het verplicht op te geven. Indien aan de validatie niet voldaan is, retourneer je een status code 400 (= bad request) en geef je details over de fout. Zonder bijkomende informatie is de HTTP 400 nutteloos. Bij validatiefouten stop je onmiddellijk de verdere verwerking van het request en retourneer je een passende foutboodschap voor de client. Stuur het response zo snel mogelijk terug naar de client (= **fail-fast principe**). De oorzaak van de validatiefout moet goed worden uitgelegd en begrepen door de client. Technische aspecten mag je om veiligheidsredenen niet retourneren.

?> In geen geval is het goed om een HTTP 500 terug te geven bij fouten die de client kan vermijden. De HTTP 500 dient enkel voor serverfouten die de client niet kan vermijden. Een HTTP 400 is een clientfout en moet dus ook door de client worden opgelost.

We gebruiken voor invoervalidatie een [fluent validation API](https://en.wikipedia.org/wiki/Fluent_interface) genaamd [Joi](https://joi.dev/), installeer dit:

```bash
yarn add joi
```

### Invoervalidatie in Koa

Er zijn wel wat packages die invoervalidatie in Koa ondersteunen (zie [https://github.com/koajs/koa/wiki#parameter-validation](https://github.com/koajs/koa/wiki#parameter-validation)), maar deze zijn vaak verouderd, niet onderhouden, niet geschikt voor de laatste versie van Koa of te beperkt in hun functionaliteit.

Dus we gaan zelf een invoervalidatie middleware schrijven. Soms bestaat er dus toch geen goed package en moet je het toch zelf doen! 😏

## Joi

We gebruiken [Joi](https://joi.dev/api/) om de invoer te valideren. Invoervalidatie in Joi bestaat uit 2 stappen:

1. Definieer het validatieschema a.d.h.v. [de ingebouwde functies](https://joi.dev/api/) in Joi.
2. Valideer de data tegen het schema a.d.h.v. [`Joi.validate(...)`](https://joi.dev/api/#anyvalidatevalue-options).

Joi ondersteunt alle soorten primitieven (strings, numbers...), evenals reguliere expressies. Het kan tot elke diepte worden genest. Je kan complexe structuren met zelfs selecties en verwijzingen toevoegen. Het is onmogelijk om alle functies te overlopen, we leren de API door hem te gebruiken (zoals elke developer altijd zou moeten doen).

Alle mogelijkheden vind je in de [documentatie](https://joi.dev/api)!

### GET /api/transactions/:id

Als eerste voorbeeld voegen we invoervalidatie toe voor de URL parameters van de GET `/api/transactions/:id`.

#### Definitie schema

Als eerste definiëren we de invoervalidatie voor de API call om één transactie op te halen. Voeg volgende code toe in `src/rest/transactions.ts`:

```ts
// src/rest/transactions.ts
// ... (imports)
import Joi from 'joi'; // 👈 1

// ...

const getTransactionById = async (
  ctx: KoaContext<GetTransactionByIdResponse, IdParams>,
) => {
  // ...
};

// 👇 2
getTransactionById.validationScheme = {
  // 👇 3
  params: {
    id: Joi.number().integer().positive(),
  },
};
```

1. We importeren Joi.
2. Vervolgens definiëren we een property `validationScheme` op onze functie `getTransactionById`. Herinner je: functies zijn zoals objecten, ze kunnen properties hebben.
3. Dit request kan enkel URL parameters bevatten. We schrijven de validatie hiervoor in een property `params`.
   - Params moet sowieso een object zijn, dus we gebruiken `{}`.
   - `id`: de naam van de parameter.
   - `Joi.number()`: het moet een geheel getal zijn, een id kan bv. nooit 1,5 of 12,345 zijn.
   - `positive()`: en het moet positief zijn.
   - `required()`: we kunnen expliciet aangeven dat iets verplicht is of optioneel via `optional()`. Maar we laten beide functies hier achterwege. Straks stellen we in dat alles standaard `required` is, dat bespaart wat werk. In een API is typisch meer `required` dan `optional`.

#### Validatie middleware

Vervolgens definiëren we een helper die een gegeven validatieschema zal checken tegen de binnengekomen URL parameters, URL query parameters en body (in de Koa Context).

Maak een nieuw bestand `validation.ts` in de map `src/core` en voeg volgende code toe:

```ts
// src/core/validation.ts
import type { Schema, SchemaLike } from 'joi'; // 👈 10
import Joi from 'joi'; // 👈 1
import type { KoaContext } from '../types'; // 👈 4
import type { Next } from 'koa'; // 👈 4

// 👇 8
const JOI_OPTIONS: Joi.ValidationOptions = {
  abortEarly: true, // stop when first error occured
  allowUnknown: false, // disallow unknown fields
  convert: true, // convert values to their types (number, Date, ...)
  presence: 'required', // default require all fields
};

// 👇 10
type RequestValidationSchemeInput = Partial<
  Record<'params' | 'body' | 'query', SchemaLike>
>;
type RequestValidationScheme = Record<'params' | 'body' | 'query', Schema>;

// 👇 2
const validate = (scheme: RequestValidationSchemeInput | null) => {
  // 👇 3
  const parsedSchema: RequestValidationScheme = {
    body: Joi.object(scheme?.body || {}),
    params: Joi.object(scheme?.params || {}),
    query: Joi.object(scheme?.query || {}),
  };

  // 👇 4
  return (ctx: KoaContext, next: Next) => {
    const errors = new Map(); // 👈 5

    // 👇 6 en 7
    const { error: paramsErrors, value: paramsValue } =
      parsedSchema.params.validate(ctx.params, JOI_OPTIONS);

    // 👇 8
    if (paramsErrors) {
      errors.set('params', cleanupJoiError(paramsErrors));
    } else {
      ctx.params = paramsValue;
    }

    // 👇 9
    if (errors.size > 0) {
      ctx.throw(400, 'Validation failed, check details for more information', {
        code: 'VALIDATION_FAILED',
        details: Object.fromEntries(errors),
      });
    }

    return next(); // 👈 4
  };
};

export default validate; // 👈 2
```

1. We importeren Joi.
2. Maak de `validate` functie aan en exporteer.
3. We definiëren een object `parsedSchema` waarin we de validatieschema's voor de body, params en query parameters opslaan.
   - We controleren of de schema's bestaan, indien niet, dan maken we een leeg object aan.
   - We gebruiken een optionele chaining operator `?.` om te controleren of een property bestaat. Indien deze niet bestaat, wordt `undefined` geretourneerd en zal de `||` operator het lege object `{}` gebruiken.
   - Dus als de developer geen schema opgeeft, dan dwingen we af dat er niets meegegeven wordt. Je denkt misschien dat het overbodig is om hard te valideren dat er niets meegegeven wordt, maar het is een belangrijk principe in het kader van bv. veiligheid.
4. Deze functie retourneert een Koa middleware. We doen `return next()` aangezien het geen zin heeft om nog verder te doen na de validatie. Bij een fout zullen we een 400 terugsturen met een duidelijke foutmelding en doen we verder niks. Zonder fout kunnen we gewoon verder, we hebben niks meer te doen hier.
5. We definiëren een `Map` waarin onze validatiefouten per type komen. In een `Map` kan je een key/value paar opslaan. In dit geval is de key de naam van de parameter (body, params, query) en de value een object met de fouten. Een eerste type is bv. de `params` (= URL parameters).
6. We valideren de binnenkomende URL parameters tegen het meegegeven schema. We krijgen een `error` en een `value` terug.
   - `error`: een `ValidationError` object met alle fouten.
   - `value`: de genormaliseerde waarde, m.a.w. de waarde die voldoet aan het schema. Als je bijvoorbeeld een getal verwacht in de URL parameters, dan zal Joi dit voor jou omzetten naar een getal want de URL is zelf een string (en dus ook de URL parameters).
7. We geven ook enkele opties mee aan deze functie (zie `JOI_OPTIONS`). We bewaren deze opties globaal aangezien we nog de query parameters en body moeten valideren
   - `abortEarly`: wanneer true (default), stopt de validatie bij de eerste fout, anders worden alle gevonden fouten geretourneerd
   - `allowUnknown`: indien true, staat het object toe onbekende sleutels te bevatten die worden genegeerd (default: false)
   - `convert`: indien true (default), wordt geprobeerd waarden naar de vereiste typen te casten, zoals bv. een string naar een getal.
   - `presence`: stelt de standaard aanwezigheidsvereisten in. Ondersteunde modi: 'optional' (default), 'required' en 'forbidden'.
8. Indien fouten: formatteer en bewaar de fouten (zie verder). Indien geen fouten: stel de params context-waarde gelijk aan de `value`, zo hebben we de genormaliseerde waarden.
9. Indien we fouten hadden, gooit de context een status code 400 (= bad request) en worden de details van de fouten vermeld.
   - Merk op: we gaan nog steeds een HTTP 500 (= internal server error) krijgen als er een fout optreedt in de validatie middleware zelf. Dit komt omdat Koa niet weet hoe deze fout afgehandeld moet worden. We zullen dit verderop oplossen.
10. We definieren een type `RequestValidationSchemeInput` en `RequestValidationScheme` om de validatieschema's te definiëren.
    - `RequestValidationSchemeInput`: een object met optionele properties `params`, `body` en `query` die een `SchemaLike` object bevatten. `SchemaLike` is een type dat een schema kan zijn, Joi is in staat om van diverse types een schema te maken (bv. string, number, object...).
    - `RequestValidationScheme`: een object met properties `params`, `body` en `query` die een `Schema` object bevatten.

#### Errors formatteren

De Joi validatie geeft een `ValidationError` terug. Deze bevat een `details` property met een array van alle fouten. We willen deze fouten formatteren zodat we mooi per type parameter de fouten kunnen groeperen. Voeg volgende code toe in: `src/core/validation.ts`

```ts
// src/core/validation.ts
// ... (imports, JOI_OPTIONS en types)

const cleanupJoiError = (error: Joi.ValidationError) => {
  const errorDetails = error.details.reduce(
    (resultObj, { message, path, type }) => {
      const joinedPath = path.join('.') || 'value';
      if (!resultObj.has(joinedPath)) {
        resultObj.set(joinedPath, []);
      }

      resultObj.get(joinedPath).push({
        type,
        message,
      });

      return resultObj;
    },
    new Map(),
  );

  return Object.fromEntries(errorDetails);
};

// ... (validate functie)
```

1. `error`: dit is een [ValidationError](https://joi.dev/api/#validationerror). Deze bevat een `details` property met een array van alle fouten.
2. Per fout `{ message, path, type }` krijgen we volgende informatie:
   - `message`: beschrijving van de fout
   - `path`: geordende array waarbij elk element de accessor is van de waarde waar de fout is opgetreden
   - `type`: type van de fout
3. `joinedPath` voegt de paden samen d.m.v. een punt, of indien er geen paden zijn wordt "value" genomen.
4. Construeer een object met het gecombineerde pad als key en een array met alle fouten als value.
   - Voor een pad `['a', 'b', 'c']`, wordt dit dus `{ 'a.b.c': [{ type: ..., message: ... }] }`.
5. Uiteindelijk retourneren we dit object.

#### Middleware toevoegen

Nu moeten we enkel nog onze nieuwe middleware toevoegen in de router. Voeg volgende code toe in `src/rest/transaction.ts`:

```ts
// src/rest/transactions.ts

import validate from '../core/validation'; // 👈 1

// ...

router.get(
  '/:id',
  validate(getTransactionById.validationScheme), // 👈 2
  getTransactionById,
);

// ...
```

1. We importeren onze nieuwe middleware.
2. De validatie dient te gebeuren alvorens de functie `getTransactionById` wordt uitgevoerd. Dus we voegen de middleware vóór deze functie toe. In het geval van een fout zal een HTTP status 400 geretourneerd worden en wordt `getTransactionById` niet meer uitgevoerd.
   - Merk op: Nu kan je ook de conversie met `Number(...)` verwijderen uit `getTransactionById` (Joi doet de conversie voor ons).

### POST api/transactions

Als volgende voorbeeld voegen we invoervalidatie toe voor de request body van de POST `/api/transactions`.

#### Definitie schema

Ook voor de `POST /api/transactions` definiëren we een schema voor invoervalidatie. Voeg dit toe aan `src/rest/transactions.ts`:

```ts
// src/rest/transactions.ts

const createTransaction = async (
  ctx: KoaContext<CreateTransactionResponse, void, CreateTransactionRequest>,
) => {
  // ...
};

// 👇 1
createTransaction.validationScheme = {
  // 👇 2
  body: {
    amount: Joi.number().invalid(0),
    date: Joi.date().iso().less('now'),
    placeId: Joi.number().integer().positive(),
    userId: Joi.number().integer().positive(),
  },
};
```

1. Voeg het schema voor invoervalidatie toe.
2. Hier valideren we enkel de `body` van het HTTP request. Er zijn verder geen parameters voor dit HTTP request
   - `amount`: moet een getal zijn, maar mag niet 0 zijn.
   - `date`: moet in ISO formaat staan en moet voor vandaag liggen.
   - `placeId` en `userId`: moeten een positief geheel getal zijn.

#### Validatie

We dienen nu ook de `body` property te valideren, op een analoge manier als de `params`. Voeg deze code toe onder de validatie van het `params` property (net voor de check of er errors zijn) in `src/core/validation.ts`:

```ts
// src/core/validation.ts
// ... (params validatie)
const { error: bodyErrors, value: bodyValue } = parsedSchema.body.validate(
  ctx.request.body,
  JOI_OPTIONS,
);

if (bodyErrors) {
  errors.set('body', cleanupJoiError(bodyErrors));
} else {
  ctx.request.body = bodyValue;
}
```

### Oefening 1 - Validatie toepassen

Zorg ervoor dat de validatie wordt uitgevoerd als het POST-request wordt uitgevoerd. Je kan hiervoor de code van de GET-request als voorbeeld gebruiken.

- Oplossing +

  ```ts
  // src/rest/transactions.ts
  router.post(
    '/',
    validate(createTransaction.validationScheme), // 👈
    createTransaction,
  );
  ```

### Validatie voor requests zonder invoer

Ook requests die geen invoer verwachten moeten de invoer valideren, nl. controleren of er effectief niks is meegegeven. Een gebruiker kan nl. meegeven wat hij wil en mogelijks wordt dit toch verwerkt (door bv. een programmeerfout). Dit kan leiden tot onverwachte resultaten of fouten.

In onze validation middleware kan je simpelweg `null` meegeven als parameters als je helemaal geen invoer verwacht. Als je één van de parameters (`body`, `query` of `params`) niet verwacht, dan laat je die leeg en vul je enkel de parameters in die je wel verwacht.

Voeg volgende code toe in `src/rest/transactions.ts`:

```ts
// src/rest/transactions.ts

// ...
getAllTransactions.validationScheme = null;

// ...
router.get(
  '/',
  validate(getAllTransactions.validationScheme),
  getAllTransactions,
);
```

Controleer of je een foutmelding krijgt als je toch invoer meegeeft bij het request.

## Request logging

<!-- TODO: vanaf hier verder nalezen -->

We voegen een extra middleware toe die elk binnenkomend request zal loggen. Dit helpt enorm bij het debuggen. We installeren eerst een package om leuke emoji's te tonen in de console.

```bash
yarn add node-emoji@1.11.0
```

We voegen vervolgens onze middleware toe voor het toevoegen van de `bodyParser` middleware in `src/core/installMiddleware.js`:

```js
const emoji = require('node-emoji'); // 👈 1
const { getLogger } = require('./logging'); // 👈 1
// ...

// 👇 1
app.use(async (ctx, next) => {
  getLogger().info(`${emoji.get('fast_forward')} ${ctx.method} ${ctx.url}`); // 👈 3

  // 👇 4
  const getStatusEmoji = () => {
    if (ctx.status >= 500) return emoji.get('skull');
    if (ctx.status >= 400) return emoji.get('x');
    if (ctx.status >= 300) return emoji.get('rocket');
    if (ctx.status >= 200) return emoji.get('white_check_mark');
    return emoji.get('rewind');
  };

  // 👇 6
  try {
    await next(); // 👈 5

    getLogger().info(
      `${getStatusEmoji()} ${ctx.method} ${ctx.status} ${ctx.url}`,
    ); // 👈 5
  } catch (error) {
    getLogger().error(
      `${emoji.get('x')} ${ctx.method} ${ctx.status} ${ctx.url}`,
      {
        error,
      },
    );

    throw error;
  }
});

app.use(bodyParser());
// ...
```

1. Voeg deze middleware toe net voor de de installatie van de bodyParser middleware.
2. Importeer `node-emoji` en de getter van onze logger.
3. We loggen alvast wanneer het request binnen komt. In Koa kan een request soms "uitsterven" door foutieve async/await, errors die "opgegeten" worden... Dan is het altijd handig om te weten of het request effectief binnen kwam of niet.
4. We definiëren een inline functie om de juiste emoji te krijgen afhankelijk van de HTTP status code van het response.
5. We wachten de request afhandeling af en loggen het resultaat.
6. We voegen een try/catch toe om eventuele fouten tijdens de request afhandeling op te vangen. Indien er een error was, dan loggen we die ook. Gooi zeker de error opnieuw: deze middleware handelt hem niet af.
   - Herinner je: **doe altijd maar één ding in een middleware!**

## Error handling

### ServiceError

We definiëren een klasse (de enige in deze cursus) die een error uit de servicelaag voorstelt. Het is een bad practice om in de servicelaag een HTTP status code in een error te schrijven. Daarmee forceer je de applicatie richting HTTP (en dus REST), terwijl ook perfect GraphQL, gRPC of tRPC kan draaien bovenop de servicelaag.

We definiëren deze klasse in `src/core/serviceError.js`:

```js
const NOT_FOUND = 'NOT_FOUND'; // 👈 2
const VALIDATION_FAILED = 'VALIDATION_FAILED'; // 👈 2

// 👇 1
class ServiceError extends Error {
  // 👇 3
  constructor(code, message, details = {}) {
    super(message);
    this.code = code;
    this.details = details;
    this.name = 'ServiceError';
  }

  // 👇 5
  static notFound(message, details) {
    return new ServiceError(NOT_FOUND, message, details);
  }

  // 👇 5
  static validationFailed(message, details) {
    return new ServiceError(VALIDATION_FAILED, message, details);
  }

  // 👇 4
  get isNotFound() {
    return this.code === NOT_FOUND;
  }

  // 👇 4
  get isValidationFailed() {
    return this.code === VALIDATION_FAILED;
  }
}

module.exports = ServiceError;
```

1. Definieer de klasse ServiceError.
2. Definieer een aantal constante strings die alle mogelijke errors voorstellen.
   - Je zou ook specifieke errors kunnen definiëren, bv. `PLACE_NOT_FOUND` of `TRANSACTION_NOT_FOUND`. In dit geval laat je deze constanten weg en gebruik je gewoon de constructor met de string als parameter.
3. Definieer een constructor die een foutcode, bericht en eventuele details meekrijgt.
4. Daarnaast voorzien we enkele getters om te kijken welk type fout opgetreden is.
5. En enkele statische methodes om een specifieke fout te gooien.

### Middleware

We voegen een extra middleware toe om fouten af te handelen. Voeg dit als laatste middleware toe in `src/core/installMiddleware.js`:

```js
// imports
const ServiceError = require('./serviceError'); // 👈 1

// config
const NODE_ENV = config.get('env'); // 👈 2

// ...

// 👇 3
app.use(async (ctx, next) => {
  try {
    await next(); // 👈 4
  } catch (error) {
    getLogger().error('Error occured while handling a request', { error }); // 👈 5
    let statusCode = error.status || 500; // 👈 6
    let errorBody = {
      // 👈 6
      code: error.code || 'INTERNAL_SERVER_ERROR',
      message: error.message,
      details: error.details || {},
      stack: NODE_ENV !== 'production' ? error.stack : undefined,
    };

    // 👇 7
    if (error instanceof ServiceError) {
      if (error.isNotFound) {
        statusCode = 404;
      }

      if (error.isValidationFailed) {
        statusCode = 400;
      }
    }

    ctx.status = statusCode; // 👈 8
    ctx.body = errorBody; // 👈 8
  }
});

// 👇 9
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

1. Importeer onze `ServiceError`.
2. Haal de `NODE_ENV` op uit de config.
3. Voeg een stukje middleware toe.
4. Definiëren een try/catch en laat het request gewoon doorgaan. We willen enkel een mogelijke error opvangen.
5. Log alvast de error die opgetreden is. Een standaard JavaScript error wordt niet goed geprint op de console, onze logger kan hier wel goed mee omgaan.
   - Check in `src/core/logging.js` maar eens waarom dit zo is.
6. Vervolgens maken we reeds onze response body op. Voorlopig nemen we de status uit de Koa context of standaard 500. We retourneren ook enkel de stack in de body als we niet in productie draaien (om security redenen).
7. Vervolgens updaten we de status als de opgetreden error een `ServiceError` is en we kennen de error.
8. Als laatste stellen we de `status` en `body` van het response in.
9. Het enige geval waarbij we nog geen mooi error response hebben is een 404 van de Koa router. Dit vangen we op deze manier op.

> 💡 Tip: kijk eens wat een mooi response we krijgen als we verkeerde invoer geven 🤩

### ServiceError gebruiken

Nu moeten we enkel nog onze eigen `ServiceError` gebruiken in de servicelaag. We dienen alle errors op te vangen en om te vormen naar een `ServiceError`.

Als we een record toevoegen aan de database, dan kan er van alles foutlopen:

- niet voldaan aan unique constraint
- niet voldaan aan de referentiële integriteit
- ...

Hiervoor maken we eerst een aparte functie `handleDBError`, zodat we deze binnen de verschillende modules kan gebruikt worden. Maak hiervoor een bestand `_handleDBError.js` aan in de `src/service` map. We starten dit bestand met underscore aangezien dit bestand nergens anders nodig is, dat is een conventie.

```js
const ServiceError = require('../core/serviceError'); // 👈 2

// 👇 1
const handleDBError = (error) => {
  const { code = '', sqlMessage } = error; // 👈 3

  // 👇 4
  if (code === 'ER_DUP_ENTRY') {
    switch (true) {
      case sqlMessage.includes('idx_place_name_unique'):
        return ServiceError.validationFailed(
          'A place with this name already exists',
        );
      case sqlMessage.includes('idx_user_email_unique'):
        return ServiceError.validationFailed(
          'There is already a user with this email address',
        );
      default:
        return ServiceError.validationFailed('This item already exists');
    }
  }

  // 👇 4
  if (code.startsWith('ER_NO_REFERENCED_ROW')) {
    switch (true) {
      case sqlMessage.includes('fk_transaction_user'):
        return ServiceError.notFound('This user does not exist');
      case sqlMessage.includes('fk_transaction_place'):
        return ServiceError.notFound('This place does not exist');
    }
  }

  // Return error because we don't know what happened
  return error;
};

module.exports = handleDBError; // 👈 1
```

1. Creëer een functie die gegeven een database error een `ServiceError` gooit en exporteer deze.
2. Importeer de `ServiceError`.
3. Haal de nodige properties uit de fout.
4. Afhankelijk van de `sqlMessage`, bepaald door de unique index of de gedefinieerde relaties, gooien we de juiste `ServiceError`.
   - We gebruiken hiervoor een `switch(true)`. Dat lijkt misschien vreemd maar is een veelgebruikte techniek bij meerdere voorwaarden. Je zou ook meerdere if/else statements kunnen gebruiken.

Pas dan de servicelaag aan, zodat deze nu gebruik maakt van onze eigen `ServiceError` voor het afhandelen van fouten.

We geven een voorbeeld voor `src/service/transaction.js`:

```js
const ServiceError = require('../core/serviceError'); // 👈 1
const handleDBError = require('./_handleDBError'); // 👈 1

//...
const getById = async (id, userId) => {
  const transaction = await transactionRepository.findById(id);

  if (!transaction || transaction.user.id !== userId) {
    // throw new Error(`There is no transaction with id ${id}`); // 👈 2
    throw ServiceError.notFound(`No transaction with id ${id} exists`, { id }); // 👈 2
  }

  return transaction;
};

const create = async ({ amount, date, placeId, userId }) => {
  const existingPlace = await placeService.getById(placeId);

  if (!existingPlace) {
    throw ServiceError.notFound(`There is no place with id ${id}.`, { id }); // 👈 3
  }

  try {
    const id = await transactionRepository.create({
      amount,
      date,
      userId,
      placeId,
    });

    return getById(id, userId);
  } catch (error) {
    throw handleDBError(error); // 👈 4
  }
};
//...
```

1. Importeer `ServiceError` en `handleDBError`.
2. Vervang elke `Error` door de juiste `ServiceError` zoals bij de `getById`. Bekijk het response wanneer je een onbestaande transactie opvraagt. In dit geval geven we het `id` mee aan de details, dat is niet verplicht maar simpel als voorbeeld.
3. Gooi een `ServiceError.notFound` als de plaats niet bestaat in de `create` method.
4. Als de create van een transactie mislukt, proberen we de fout om te zetten naar een `ServiceError` of gooien we de fout opnieuw.

## Integratietesten

- Check uit op commit `7c99494` van onze [voorbeeldapplicatie](https://github.com/HOGENT-frontendweb/webservices-budget/) en bekijk de `validate`-functie. Deze werd aangepast om ook query parameters te valideren.
- Ook voor de overige endpoints werd een validatieschema toegevoegd.
  - **Let op:** voorzie ook validatie voor requests die geen invoer verwachten!
- Integratietesten werden toegevoegd om te checken op invoervalidatie.

## Oefening 2 - Je eigen project

Werk aan je eigen project:

- Maak gebruik van invoervalidatie voor alle endpoints en voeg de `validate`-functie toe.
- Voeg de request logging middleware toe.
- Voeg foutafhandeling toe.
- Voeg de testen toe.

> 💡 Tip: als extra functionaliteit kan je een andere validatie library of middleware gebruiken.

## Koa Helmet

De module [koa-helmet](https://www.npmjs.com/package/koa-helmet) is een middleware voor Koa. `koa-helmet` is een wrapper voor [helmet voor Express](https://github.com/helmetjs/helmet) om met Koa te werken. Het stelt verschillende HTTP response headers in om de beveiliging van webapplicaties die met Koa zijn gebouwd te verbeteren.

Enkele van de beveiligingsheaders die door koa-helmet zijn geïmplementeerd, zijn onder meer:

- **Content Security Policy (CSP)**: helpt Cross-Site Scripting (XSS) aanvallen te voorkomen. [Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- **X-Content-Type-Options**: voorkomt aanvallen van content-sniffing attacks door de browser te dwingen zich aan het aangegeven Content-Type te houden. [Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options)
- **Strict-Transport-Security**: dwingt het gebruik van veilige HTTPS-verbindingen af ​​door de browser te instrueren om alleen via HTTPS toegang te krijgen tot de website. [Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)
- **X-Frame-opties**: voorkomt [click-jacking](https://developer.mozilla.org/en-US/docs/Web/Security/Types_of_attacks#click-jacking)-aanvallen door te beperken waar jouw site in een `iframe` kan worden ingesloten.[Lees meer](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options)

Meer info op [https://github.com/helmetjs/helmet](https://github.com/helmetjs/helmet)

Samenvattend vereenvoudigt koa-helmet het proces van het instellen en beheren van beveiligingsheaders in Koa-applicaties, waardoor de algehele beveiligingspositie wordt verbeterd en bescherming wordt geboden tegen veelvoorkomende kwetsbaarheden op het web. Het helpt het risico op verschillende beveiligingsproblemen te minimaliseren en beschermt de gebruikers en de applicatie tegen mogelijke aanvallen.

Installeer koa-helmet:

```bash
yarn add koa-helmet
```

Pas `src/core/installMiddleware.js` en installeer koa-helmet in de middleware pipeline:

```js
const koaHelmet = require('koa-helmet');

// ...

// Add the body parser
app.use(bodyParser());

// Add some security headers
app.use(koaHelmet());

// Add CORS
// ...
```

### Oefening 4 - Je eigen project

Voeg Koa Helmet toe aan je eigen project.
