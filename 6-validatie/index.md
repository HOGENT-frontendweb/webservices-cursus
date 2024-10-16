# Validatie en foutafhandeling

<!-- TODO: startpunt en oplossing toevoegen -->

Heel wat REST API's die je online vindt, gaan er vanuit dat de invoer altijd correct is, geven totaal verkeerde foutmeldingen terug, of geven helemaal geen foutmeldingen. Dit is een bad practice! Een goede API geeft duidelijke foutmeldingen terug en valideert de invoer. Invoervalidatie is belangrijk voor de integriteit van de data en de veiligheid van de applicatie. Degelijke foutboodschappen helpen de gebruikers van de API om fouten te begrijpen en te corrigeren, indien mogelijk.

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

?> In geen geval is het goed om een HTTP 500 terug te geven bij fouten die de client kan vermijden. De HTTP 500 dient enkel voor serverfouten die de client niet kan vermijden. Een HTTP 400 is een fout veroorzaakt door de client en moet dus ook door de client worden opgelost.

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
import type { KoaContext } from '../types/koa'; // 👈 4
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
10. We definiëren een type `RequestValidationSchemeInput` en `RequestValidationScheme` om de validatieschema's te definiëren.
    - `RequestValidationSchemeInput`: een object met optionele properties `params`, `body` en `query` die een `SchemaLike` object bevatten. `SchemaLike` is een type dat een schema kan zijn, Joi is in staat om van diverse types een schema te maken (bv. string, number, object...).
    - `RequestValidationScheme`: een object met properties `params`, `body` en `query` die een `Schema` object bevatten.

!> **Merk op:** Je moet **overal** validatie toevoegen, ook al verwacht je geen invoer. Je denkt misschien dat het overbodig is om hard te valideren dat er niets meegegeven wordt, maar het is een belangrijk principe in het kader van bv. veiligheid.

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
   - Merk op: Nu kan je ook de conversie met `Number(...)` en `new Date(...)` verwijderen uit `createTransaction` (Joi doet de conversie voor ons).
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

### GET /api/transactions

Ook requests die geen invoer verwachten moeten de invoer valideren, nl. controleren of er effectief niks is meegegeven. Een gebruiker kan nl. meegeven wat hij wil en mogelijks wordt dit toch verwerkt (door bv. een programmeerfout). Dit kan leiden tot onverwachte resultaten of fouten.

In onze validation middleware kan je simpelweg `null` meegeven als parameters als je helemaal geen invoer verwacht. Als je één van de parameters (`body`, `query` of `params`) niet verwacht, dan laat je die leeg en vul je enkel de parameters in die je wel verwacht. Dit is wat we in de twee vorige requests steeds gedaan hebben.

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

Als laatste werken we onze `validate` functie af met query parameter validatie. Dit is de enige mogelijkheid die we nog niet hebben toegevoegd.

```ts
// src/core/validation.ts

// ...

const { error: queryErrors, value: queryValue } = parsedSchema.query.validate(
  ctx.query,
  JOI_OPTIONS,
);

if (queryErrors) {
  errors.set('query', cleanupJoiError(queryErrors));
} else {
  ctx.query = queryValue;
}
```

Controleer of je een foutmelding krijgt als je toch invoer meegeeft bij het request. Je kan bijvoorbeeld `GET /api/transactions?foo=bar` proberen.

## Request logging

We voegen een extra middleware toe die elk binnenkomend request zal loggen. Dit helpt o.a. enorm bij het debuggen. We voegen onze middleware toe voor het toevoegen van de `bodyParser` middleware in `src/core/installMiddleware.ts`:

```ts
// src/core/installMiddleware.ts
// ... (imports)

import { getLogger } from './logging'; // 👈 1

// ...

// 👇 2
app.use(async (ctx, next) => {
  // 👇 3
  getLogger().info(`⏩ ${ctx.method} ${ctx.url}`);

  // 👇 4
  const getStatusEmoji = () => {
    if (ctx.status >= 500) return '💀';
    if (ctx.status >= 400) return '❌';
    if (ctx.status >= 300) return '🔀';
    if (ctx.status >= 200) return '✅';
    return '🔄';
  };

  // 👇 5
  await next();

  // 👇 6
  getLogger().info(
    `${getStatusEmoji()} ${ctx.method} ${ctx.status} ${ctx.url}`,
  );
});

app.use(bodyParser());
// ...
```

1. Importeer de getter van onze logger.
2. Voeg deze middleware toe net voor de de installatie van de bodyParser middleware.
3. We loggen alvast wanneer het request binnen komt. In Koa kan een request soms "uitsterven" door foutief gebruik van async/await, errors die "opgegeten" worden... Dan is het altijd handig om te weten of het request effectief binnen kwam of niet.
4. We definiëren een inline functie om de juiste emoji te krijgen afhankelijk van de HTTP status code van het response.
5. We wachten de request afhandeling af.
6. Daarna loggen we het resultaat.
   - Herinner je: **doe altijd maar één ding in een middleware!** We loggen hier enkel, we veranderen niets aan de request of response.

## Error handling

### ServiceError

We definiëren een klasse (de enige in deze cursus) die een error uit de servicelaag voorstelt. Het is een bad practice om in de servicelaag een HTTP status code in een error te schrijven. Daarmee forceer je de applicatie richting HTTP (en dus REST), terwijl ook perfect GraphQL, gRPC, tRPC of iets anders kan draaien bovenop de servicelaag.

We definiëren deze klasse in `src/core/serviceError.ts`:

```ts
// src/core/serviceError.ts

// 👇 2
const NOT_FOUND = 'NOT_FOUND';
const VALIDATION_FAILED = 'VALIDATION_FAILED';
const UNAUTHORIZED = 'UNAUTHORIZED';
const FORBIDDEN = 'FORBIDDEN';
const INTERNAL_SERVER_ERROR = 'INTERNAL_SERVER_ERROR';
const CONFLICT = 'CONFLICT';

// 👇 1
export default class ServiceError extends Error {
  // 👇 3
  code: string;

  // 👇 3
  constructor(code: string, message: string) {
    super(message);
    this.code = code;
    this.name = 'ServiceError';
  }

  // 👇 4
  static notFound(message: string) {
    return new ServiceError(NOT_FOUND, message);
  }

  static validationFailed(message: string) {
    return new ServiceError(VALIDATION_FAILED, message);
  }

  static unauthorized(message: string) {
    return new ServiceError(UNAUTHORIZED, message);
  }

  static forbidden(message: string) {
    return new ServiceError(FORBIDDEN, message);
  }

  static internalServerError(message: string) {
    return new ServiceError(INTERNAL_SERVER_ERROR, message);
  }

  static conflict(message: string) {
    return new ServiceError(CONFLICT, message);
  }

  // 👇 5
  get isNotFound(): boolean {
    return this.code === NOT_FOUND;
  }

  get isValidationFailed(): boolean {
    return this.code === VALIDATION_FAILED;
  }

  get isUnauthorized(): boolean {
    return this.code === UNAUTHORIZED;
  }

  get isForbidden(): boolean {
    return this.code === FORBIDDEN;
  }

  get isInternalServerError(): boolean {
    return this.code === INTERNAL_SERVER_ERROR;
  }

  get isConflict(): boolean {
    return this.code === CONFLICT;
  }
}
```

1. Definieer de klasse ServiceError.
2. Definieer een aantal constante strings die alle mogelijke errors voorstellen.
   - Je zou ook specifieke errors kunnen definiëren, bv. `PLACE_NOT_FOUND` of `TRANSACTION_NOT_FOUND`. In dit geval laat je deze constanten weg en gebruik je gewoon de constructor met de string als parameter.
   - We voegen volgende foutcodes toe:
     - `NOT_FOUND`: een resource wordt niet gevonden wordt.
     - `VALIDATION_FAILED`: de client geeft foutieve invoer
     - `UNAUTHORIZED`: een gebruiker is niet aangemeld voor een resource waarvoor je aangemeld moet zijn (zie volgend hoofdstuk).
     - `FORBIDDEN`: een gebruiker heeft onvoldoende rechten voor een bepaalde resource (zie volgend hoofdstuk).
     - `INTERNAL_SERVER_ERROR`: een onverwachte fout is opgetreden.
     - `CONFLICT`: de gebruiker voert een actie uit die niet toegelaten is (bv. een plaats verwijderen als hieraan nog transacties gekoppeld zijn).
3. Definieer een constructor die een foutcode en een bericht meekrijgt. Het bericht geven we door aan onze ouder, de foutcode houden we in onze klasse bij.
4. Daarnaast voorzien we enkele statische methodes om een specifieke fout te gooien.
5. En enkele getters om te kijken welk type fout opgetreden is.

### Middlewares

We voegen een twee extra middlewares toe om fouten af te handelen. Voeg deze als laatste middlewares toe in `src/core/installMiddleware.ts`:

```ts
// src/core/installMiddleware.ts

// ... (imports)
import ServiceError from './serviceError'; // 👈 1

const NODE_ENV = config.get<string>('env'); // 👈 2

// ...

// 👇 3
app.use(async (ctx, next) => {
  try {
    await next(); // 👈 4
  } catch (error: any) {
    // 👇 5
    getLogger().error('Error occured while handling a request', { error });

    // 👇 6
    let statusCode = error.status || 500;
    const errorBody = {
      code: error.code || 'INTERNAL_SERVER_ERROR',
      // Do not expose the error message in production
      message:
        error.message || 'Unexpected error occurred. Please try again later.',
      details: error.details,
      stack: NODE_ENV !== 'production' ? error.stack : undefined,
    };

    // 👇 7
    if (error instanceof ServiceError) {
      errorBody.message = error.message;

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

      if (error.isConflict) {
        statusCode = 409;
      }
    }

    // 👇 8
    ctx.status = statusCode;
    ctx.body = errorBody;
  }
});

// 👇 9
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
5. Log alvast de error die opgetreden is. We gebruiken hier `any` als type omdat we niet zeker weten welke fout opgetreden is. Een standaard JavaScript error wordt niet goed geprint op de console, onze logger kan hier wel goed mee omgaan.
   - Check in `src/core/logging.ts` maar eens waarom dit zo is.
6. Vervolgens maken we reeds onze response body op. Voorlopig nemen we de status uit de Koa context of standaard 500. We retourneren ook enkel de stack in de body als we niet in productie draaien (om veiligheidsredenen).
7. Vervolgens updaten we de status als de opgetreden error een `ServiceError` is en we kennen de error.
8. Als laatste stellen we de `status` en `body` van het response in.
9. Het enige geval waarbij we nog geen mooi error response hebben is een 404 van de Koa router. Dit vangen we op deze manier op.

> 💡 Tip: kijk eens wat een mooi response we krijgen als we verkeerde invoer geven. Kijk ook in de console hoe mooi de fout geprint wordt door onze logger. 🤩

### ServiceError gebruiken

Nu moeten we enkel nog onze eigen `ServiceError` gebruiken in de servicelaag. We dienen alle errors op te vangen en om te vormen naar een `ServiceError`.

Als we een record toevoegen aan de database, dan kan er van alles foutlopen:

- niet voldaan aan unique constraint
- niet voldaan aan de referentiële integriteit
- ...

Hiervoor maken we eerst een aparte functie `handleDBError`, zodat we deze binnen de verschillende modules kan gebruikt worden. Maak hiervoor een bestand `_handleDBError.ts` aan in de `src/service` map. We starten dit bestand met underscore aangezien dit bestand nergens anders nodig is, dat is een conventie.

```ts
// src/service/_handleDBError.ts
import ServiceError from '../core/serviceError'; // 👈 2

// 👇 1
const handleDBError = (error: any) => {
  // 👇 3
  const { code = '', message } = error;

  if (code === 'P2002') {
    switch (true) {
      case message.includes('idx_place_name_unique'):
        throw ServiceError.validationFailed(
          'A place with this name already exists',
        );
      case message.includes('idx_user_email_unique'):
        throw ServiceError.validationFailed(
          'There is already a user with this email address',
        );
      default:
        throw ServiceError.validationFailed('This item already exists');
    }
  }

  if (code === 'P2025') {
    switch (true) {
      case message.includes('fk_transaction_user'):
        throw ServiceError.notFound('This user does not exist');
      case message.includes('fk_transaction_place'):
        throw ServiceError.notFound('This place does not exist');
      case message.includes('transaction'):
        throw ServiceError.notFound('No transaction with this id exists');
      case message.includes('place'):
        throw ServiceError.notFound('No place with this id exists');
      case message.includes('user'):
        throw ServiceError.notFound('No user with this id exists');
    }
  }

  if (code === 'P2003') {
    switch (true) {
      case message.includes('place_id'):
        throw ServiceError.conflict(
          'This place does not exist or is still linked to transactions',
        );
      case message.includes('user_id'):
        throw ServiceError.conflict(
          'This user does not exist or is still linked to transactions',
        );
    }
  }

  // Rethrow error because we don't know what happened
  throw error;
};

export default handleDBError; // 👈 1
```

1. Creëer een functie die gegeven een database error een `ServiceError` gooit en exporteer deze.
2. Importeer de `ServiceError`.
3. Haal de nodige properties uit de fout.
4. Afhankelijk van de `code`, bepaald door de unique index of de gedefinieerde relaties, gooien we de juiste `ServiceError`.
   - We gebruiken hiervoor een `switch(true)`. Dat lijkt misschien vreemd maar is een veelgebruikte techniek bij meerdere voorwaarden. Je zou ook meerdere if/else statements kunnen gebruiken.
   - De codes krijgen we van MySQL en betekenen het volgende:
     - `P2002`: er werd een unique constraint geschonden.
     - `P2025`: er werd niet voldaan aan referentiële integriteit, het gevraagde record bestaat dus niet.
     - `P2003`: er werd geprobeerd om een entiteit te verwijderen die nog een relatie heeft met een andere entiteit.

Pas vervolgens de servicelaag aan, zodat deze nu gebruik maakt van onze eigen `ServiceError` voor het afhandelen van fouten.

We geven een voorbeeld voor `src/service/transaction.ts`:

```ts
// src/service/transaction.ts

// ... (imports)
import ServiceError from '../core/serviceError'; // 👈 1
import handleDBError from './_handleDBError'; // 👈 1

// ...
export const getById = async (id: number): Promise<Transaction> => {
  const transaction = await prisma.transaction.findUnique({
    where: {
      id,
    },
    select: TRANSACTION_SELECT,
  });

  if (!transaction) {
    // 👇 2
    throw ServiceError.notFound('No transaction with this id exists');
  }

  return transaction;
};

export const create = async ({
  amount,
  date,
  placeId,
  userId,
}: TransactionCreateInput): Promise<Transaction> => {
  // 👇 3
  try {
    // 👇 4
    await placeService.checkPlaceExists(placeId);

    return await prisma.transaction.create({
      data: {
        amount,
        date,
        user_id: userId,
        place_id: placeId,
      },
      select: TRANSACTION_SELECT,
    });
  } catch (error: any) {
    // 👇 5
    throw handleDBError(error);
  }
};
// ...
```

1. Importeer `ServiceError` en `handleDBError`.
2. Als we geen transactie terugkregen, dan gooien we nu de gepaste `ServiceError`.
3. We wrappen de `create` functie in een try/catch.
   - **Let op!** We doen hier `return await` omdat we alle fouten hier willen opvangen. Zonder de `await` zou de fout opgevangen moeten worden in de functie die `create` aanroept (= REST-laag).
4. We maken een nieuwe functie `checkPlaceExists` in `src/service/place.ts` die controleert of een place bestaat. Deze functie zal een `ServiceError` gooien als de plaats niet bestaat.
   - Implementeer deze functie zelf. In deze functie tel je het aantal plaatsen met het gegeven id. Als dit 0 is, dan gooi je een `ServiceError.notFound`.
5. We vangen een foutmelding op en geven deze door aan `handleDBError`. Deze functie vormt de error om, indien gekend, of retourneert dezelfde fout. De returnwaarde van deze functie wordt opnieuw gegooid.
   - Onze [error handler](#middlewares) (zie hierboven) zal de fout opvangen en een mooi response teruggeven.

## Integratietesten

Check uit op commit `19547fd` van onze [voorbeeldapplicatie](https://github.com/HOGENT-frontendweb/webservices-budget/) en bekijk de code:

- Voor de overige endpoints werd een validatieschema toegevoegd.
  - Kijk naar hoe we de validatie voor `GET /api/users/:id` hebben toegevoegd. Wat valt je op?
  - **Let op:** voorzie ook validatie voor requests die geen invoer verwachten!
- Integratietesten werden toegevoegd om te checken op invoervalidatie.

> 💡 Je moet ook niet overdrijven met integratietesten! Je merkt dat dit soort testen heel wat werk vereisen, dus je moet goed afwegen of het de moeite waard is om zoveel testen te schrijven.

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

Pas `src/core/installMiddleware.ts` en installeer koa-helmet in de middleware pipeline:

```ts
// src/core/installMiddleware.ts
// ... (imports)
import koaHelmet from 'koa-helmet'; // 👈

// ...

app.use(bodyParser());

app.use(koaHelmet()); // 👈

// ...
```

### Oefening 4 - Je eigen project

Werk aan je eigen project:

- Maak gebruik van invoervalidatie voor alle endpoints en voeg de `validate`-functie toe.
- Voeg de request logging middleware toe.
- Voeg foutafhandeling toe.
- Voeg de testen toe.
- Voeg Koa Helmet toe.

> 💡 Tip: als extra functionaliteit kan je een andere validatie library of middleware gebruiken. Zorg er wel voor dat deze library minstens ondersteuning heeft voor validatie van URL parameters, query parameters en request body.

<br />

> **Oplossing voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les6-opl 098b979
> yarn install
> yarn start:dev
> ```
