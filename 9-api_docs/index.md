# API documentatie

Voor het schrijven van API documentatie bestaan wel wat tools. Swagger is een van de bekendste. Swagger is een set van open-source tools die samenwerken om REST API's te ontwerpen, builden, documenteren en consumeren. Swagger is gebaseerd op de OpenAPI specificatie. In dit hoofdstuk leer je hoe je een REST API documenteert met OpenAPI en Swagger.

<!-- TODO: startpunt en oplossing toevoegen -->

## Swagger vs Open API

![Swagger versus Open API](./images/swagger.png)

### OpenAPI Specification

[OpenAPI Specification (OAS)](https://swagger.io/specification/), voorheen bekend als Swagger Specification, biedt een standaard, programmeertaal onafhankelijke beschrijving van een REST API in YAML- of JSON-formaat. Het geeft alleen aan welke functionaliteit de API biedt, niet welke implementatie of dataset achter die API schuilgaat.

Met OAS 3.0 kunnen zowel mensen als machines de functionaliteit van een REST API bekijken, begrijpen en interpreteren, zonder toegang tot de broncode, aanvullende documentatie. Uit de documentatie kan de client code worden gegenereerd. Een voorbeeld van de basis structuur vind je hier: <https://swagger.io/docs/specification/basic-structure/>.

**Een API is maar zo goed als jij (ja, jij) hem documenteert.**

### Swagger

Swagger is een set van open source tools opgebouwd rond de OpenAPI specificatie om REST API's te ontwerpen, builden, documenteren en consumeren:

- [Swagger Editor](https://editor.swagger.io/): browser-based editor voor het schrijven van OpenAPI specs.
- [Swagger UI](https://swagger.io/tools/swagger-ui/): creëert een documentatiepagina voor de OpenAPI specs als interactieve API documentation.
- [Swagger Codegen](https://github.com/swagger-api/swagger-codegen): genereert server stubs en client libraries vanuit de OpenAPI spec.

Swagger installeer je als volgt:

```bash
yarn add swagger-jsdoc koa2-swagger-ui
```

- `swagger-jsdoc`: deze library leest de [JSDoc](https://jsdoc.app/) annotated source code en genereert een OpenAPI (Swagger) specification. JSDoc is een API-documentatiegenerator voor JavaScript, vergelijkbaar met Javadoc. Je voegt documentatie-opmerkingen rechtstreeks toe aan de broncode, direct naast de code zelf. De JSDoc-tool scant de broncode en genereert de OpenAPI spec.
- `koa2-swagger-ui`: Swagger UI middleware voor Koa. Dit genereert een documentatiepagina vanuit de OpenAPI definities.

## API documentatie

OpenAPI definities schrijf je in YAML of JSON. Wij maken hier gebruik van YAML. Documenteer onderstaande aspecten:

- `Metadata`: bevat de OpenAPI versie en info over de API (title, version...).
- `Servers`: de API servers en base URL.
- `API tags`: tags worden gebruikt voor het groeperen van gerelateerde operaties bv. transactions en places.
- `API components`: documentatie van de verschillende herbruikbare data modellen: schema's, parameters, beveiligingsschema's, request bodies, responses, headers, voorbeelden, koppelingen en callbacks.
- `API paths`: paden naar de documentatie, relatief t.o.v. de root.

### Swagger configuratie

Voeg een nieuw bestand `swagger.config.ts` toe in de root van je project:

```ts
export default {
  failOnErrors: true,
  apis: ['./src/rest/*.ts'],
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Budget API with Swagger',
      version: '0.1.0',
      description:
        'This is a simple CRUD API application made with Koa and documented with Swagger',
      license: {
        name: 'MIT',
        url: 'https://spdx.org/licenses/MIT.html',
      },
    },
    servers: [{ url: 'http://localhost:9000/' }],
  },
};
```

In dit bestand definiëren we de algemene informatie over de API en de servers. Enkel de `definition` property bevat de OpenAPI specificatie. De andere properties zijn specifiek voor `swagger-jsdoc`. Je kan het `info` object nog aanvullen met meer informatie, zie de [Open API specificatie](https://swagger.io/specification/#info-object) voor meer details.

De `apis` array bevat de paden naar de bestanden die de OpenAPI specificatie genereren. In dit geval zijn dat de bestanden in de `src/rest` map.

We stellen ook in dat een fout gegooid wordt indien er een foute specificatie wordt gegenereerd. Dit is handig om fouten in de documentatie snel op te sporen. Je maakt bijvoorbeeld heel snel fouten tegen de indentatieregels van YAML als je YAML in JSDoc commentaar schrijft. Jammer genoeg merkt het niet alle fouten op. Als je bv. verwijst naar een onbestaand schema, dan zal dit niet opgemerkt worden. Je kan dit wel testen door de JSON output (van <http://localhost:9000/swagger.json>) te plakken in <https://editor.swagger.io>.

### Swagger UI middleware

Voeg vervolgens de middleware toe in `src/core/installMiddleware.ts`:

```ts
// src/core/installMiddleware.ts
// ...
import { koaSwagger } from 'koa2-swagger-ui';
import swaggerJsdoc from 'swagger-jsdoc';
import swaggerOptions from '../../swagger.config';
// ...

const isDevelopment = NODE_ENV === 'development';

// ...
// ... (voor 404 middleware)
if (isDevelopment) {
  // 👇 1
  const spec = swaggerJsdoc(swaggerOptions) as Record<string, unknown>;

  // 👇 2
  app.use(
    koaSwagger({
      routePrefix: '/swagger',
      specPrefix: '/openapi.json',
      exposeSpec: true,
      swaggerOptions: { spec },
    }),
  );
}
```

1. De `swaggerOptions` worden ingelezen uit het bestand `swagger.config.ts` en doorgegeven aan `swaggerJsdoc` om de OpenAPI specificatie te genereren. De `swaggerJsdoc` functie doorloopt de JSDoc annotaties in de bestanden die in `apis` zijn opgegeven en genereert de OpenAPI specificatie.
   - Aangezien de `swaggerJsdoc` functie een foutief type teruggeeft (`object`), casten we het resultaat naar `Record<string, unknown>`.
2. Vervolgens installeren we de Swagger UI middleware met `koaSwagger`. De Swagger UI is beschikbaar op `/swagger` en de OpenAPI specificatie op `/swagger.json`. We geven de gegenereerde specificatie mee aan de Swagger UI.

### Aanpassing voor koa-helmet

koa-helmet's Content Security Policy (CSP) is niet nodig in development, dit levert problemen op met de Swagger UI. Pas `src/core/installMiddleware.ts`:

```ts
// src/core/installMiddleware.ts
// ...

// Add some security headers
app.use(
  koaHelmet({
    // Not needed in development (destroys Swagger UI)
    contentSecurityPolicy: isDevelopment ? false : true,
  }),
);

// Add CORS
// ...
```

## Algemene API documentatie

Allereerst zullen we wat algemene documentatie toevoegen aan het bestand `src/rest/index.ts`. Met `swagger-jsdoc` kunnen we JSDoc commentaar toevoegen aan de bestaande code om de OpenAPI specificatie te genereren. Op die manier schrijven we overal kleine onderdelen van de hele specificatie die door `swagger-jsdoc` worden samengevoegd. We schrijven onze Open API specificatie in [YAML](https://yaml.org/).

Via [components](https://swagger.io/docs/specification/v3_0/components/) kan je herbruikbare onderdelen van de API definiëren. In onderstaand voorbeeld definiëren we een schema `Base` voor een object met een `id` property. Deze property heeft het type `integer`. Voeg de JSDoc commentaar toe boven de `installRoutes` functie in `src/rest/index.ts`.

```ts
// src/rest/index.ts

/**
 * @swagger
 * components:
 *   schemas:
 *     Base:
 *       required:
 *         - id
 *       properties:
 *         id:
 *           type: integer
 *           format: "int32"
 */
```

Vervolgens definiëren we hoe een `id` URL parameter eruit ziet:

```ts
// src/rest/index.ts

/**
 * @swagger
 * components:
 *   parameters:
 *     idParam:
 *       in: path
 *       name: id
 *       description: Id of the item to fetch/update/delete
 *       required: true
 *       schema:
 *         type: integer
 *         format: "int32"
 */
```

Met Swagger kunnen we ook definiëren hoe gebruikers geauthenticeerd moeten worden. In dit voorbeeld definiëren we een authenticatie met een JWT token:

```ts
// src/rest/index.ts

/**
 * @swagger
 * components:
 *  securitySchemes:
 *    bearerAuth: # arbitrary name for the security scheme
 *      type: http
 *      scheme: bearer
 *      bearerFormat: JWT # optional, arbitrary value for documentation purposes
 */
```

Als laatste definiëren we nog vier error responses:

```ts
// src/rest/index.ts

/**
 * @swagger
 * components:
 *   responses:
 *     400BadRequest:
 *       description: You provided invalid data
 *     401Unauthorized:
 *       description: You need to be authenticated to access this resource
 *     403Forbidden:
 *       description: You don't have access to this resource
 *     404NotFound:
 *       description: The requested resource could not be found
 */
```

Zoals je ziet is de Open API specificatie enorm uitgebreid en veel schrijven. Het is belangrijk om de documentatie up-to-date te houden. De Swagger UI is een handige tool om de documentatie te bekijken en testen.

Start de server en kijk eens naar de Swagger UI op <http://localhost:9000/swagger>.

## Documentatie voor de places

In dit voorbeeld werken we de documentatie uit voor de `places` API. Voeg de volgende JSDoc commentaren toe aan het bestand `src/rest/places.ts` (bovenaan onder de imports).

```ts
// src/rest/places.ts
// ... (imports)

/**
 * @swagger
 * tags:
 *   name: Places
 *   description: Represents an income source or a expense item
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Place:
 *       allOf:
 *         - $ref: "#/components/schemas/Base"
 *         - type: object
 *           required:
 *             - id
 *             - name
 *             - rating
 *           properties:
 *             name:
 *               type: "string"
 *             rating:
 *               type: "integer"
 *               minimum: 1
 *               maximum: 5
 *           example:
 *             id: 123
 *             name: Loon
 *             rating: 4
 *     PlacesList:
 *       required:
 *         - items
 *       properties:
 *         items:
 *           type: array
 *           items:
 *             $ref: "#/components/schemas/Place"
 *
 *   requestBodies:
 *     Place:
 *       description: The place info to save
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               rating:
 *                 type: number
 *                 minimum: 1
 *                 maximum: 5
 *             required:
 *               - name
 */
```

Als eerste definiëren we een tag. [Tags](https://swagger.io/docs/specification/v3_0/grouping-operations-with-tags/) worden gebruikt om gerelateerde operaties te groeperen. In dit geval groeperen we alle operaties die te maken hebben met de `places`.

Vervolgens definiëren we een schema `Place` en een schema `PlacesList`. Het schema `Place` bevat een `id`, `name` en `rating`. Het `id` erven we over van `Base` m.b.v. `allOf`. De `rating` moet een getal zijn tussen 1 en 5. Het schema `PlacesList` bevat een array van `Place` objecten. We definiëren ook een voorbeeld van een `Place` object.

Als laatste definiëren we een request body `Place` voor het geval een plaats wordt geretourneerd.

Je merkt dat we met `$ref` kunnen verwijzen naar andere onderdelen van de specificatie. Dit maakt de specificatie overzichtelijk en herbruikbaar. `#/components/schemas/Base` verwijst naar het schema `Base` dat we eerder hebben gedefinieerd. `#/components/schemas/Place` verwijst naar het schema `Place` dat we hier definiëren.

### GET /api/places

Voeg de volgende JSDoc commentaren toe aan de `getPlaces` functie in `src/rest/places.ts`.

```ts
/**
 * @swagger
 * /api/places:
 *   get:
 *     summary: Get all places
 *     tags:
 *       - Places
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of places
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/PlacesList"
 *       400:
 *         $ref: '#/components/responses/400BadRequest'
 *       401:
 *         $ref: '#/components/responses/401Unauthorized'
 */
```

Hier definiëren we de documentatie voor de `GET /api/places` route. De route retourneert een lijst van plaatsen. De response bevat een lijst van plaatsen, gedefinieerd in het schema `PlacesList`. Bekijk de structuur van de OpenAPI documentatie, herken je bepaalde elementen?

Bekijk de Swagger UI op <http://localhost:9000/swagger>. Je zou nu een onderdeel moeten zien voor de `places` API.

### Oefening 1 - GET /api/places/:id

- Definieer de documentatie voor de `GET /api/places/:id` route. De route retourneert een plaats met een specifieke `id`.
- Gebruik de documentatie over [parameters](https://swagger.io/docs/specification/v3_0/describing-parameters/) om de `id` parameter te documenteren.
- De response bevat een plaats, gedefinieerd in het schema `Place`.
- Verwijs ook naar de `404NotFound` als mogelijk response.

<br />

- Oplossing +

  ```ts
  /**
   * @swagger
   * /api/places/{id}:
   *   get:
   *     summary: Get a single place
   *     tags:
   *       - Places
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - $ref: "#/components/parameters/idParam"
   *     responses:
   *       200:
   *         description: The requested place
   *         content:
   *           application/json:
   *             schema:
   *               $ref: "#/components/schemas/Place"
   *       400:
   *         $ref: '#/components/responses/400BadRequest'
   *       401:
   *         $ref: '#/components/responses/401Unauthorized'
   *       404:
   *         $ref: '#/components/responses/404NotFound'
   */
  ```

### Oefening 2 - DELETE /api/places/:id

- Herhaal de oefening voor de `DELETE /api/places/:id` route. De route verwijdert een plaats met een specifieke `id`.
- De route retourneert geen data, enkel een status code 204.
- De route kan ook een `404NotFound` response retourneren.

<br />

- Oplossing +

  ```ts
  /**
   * @swagger
   * /api/places/{id}:
   *   delete:
   *     summary: Delete a place
   *     tags:
   *       - Places
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - $ref: "#/components/parameters/idParam"
   *     responses:
   *       204:
   *         description: No response, the delete was successful
   *       400:
   *         $ref: '#/components/responses/400BadRequest'
   *       401:
   *         $ref: '#/components/responses/401Unauthorized'
   *       404:
   *         $ref: '#/components/responses/404NotFound'
   */
  ```

### POST /api/places

Vervolgens voegen we de documentatie toe voor de `POST /api/places` route. Voeg de volgende JSDoc commentaren toe aan de `createPlace` functie in `src/rest/places.ts`.

```ts
/**
 * @swagger
 * /api/places:
 *   post:
 *     summary: Create a new place
 *     tags:
 *       - Places
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       $ref: "#/components/requestBodies/Place"
 *     responses:
 *       200:
 *         description: The created place
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/Place"
 *       400:
 *         $ref: '#/components/responses/400BadRequest'
 *       401:
 *         $ref: '#/components/responses/401Unauthorized'
 */
```

We definiëren de request body m.b.v. `requestBody` en verwijzen naar de `Place` request body die we voorheen hebben gedefinieerd. De response bevat de aangemaakte plaats, gedefinieerd in het schema `Place`. We verwijzen ook naar de `400BadRequest` response want de client kan foutieve invoer geven die niet voldoet aan de validatie.

### Oefening 4 - PUT /api/places/:id

- Definieer de documentatie voor de `PUT /api/places/:id` route. De route update een plaats met een specifieke `id`.
- De route verwacht een plaats in de request body, gedefinieerd in het schema `Place`.
- De response bevat de geüpdatete plaats, gedefinieerd in het schema `Place`.
- Verwijs ook naar de `400BadRequest` en `404NotFound` als mogelijke responses.

<br />

- Oplossing +

  ```ts
  /**
   * @swagger
   * /api/places/{id}:
   *   put:
   *     summary: Update an existing place
   *     tags:
   *       - Places
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - $ref: "#/components/parameters/idParam"
   *     requestBody:
   *       $ref: "#/components/requestBodies/Place"
   *     responses:
   *       200:
   *         description: The updated place
   *         content:
   *           application/json:
   *             schema:
   *               $ref: "#/components/schemas/Place"
   *       400:
   *         $ref: '#/components/responses/400BadRequest'
   *       401:
   *         $ref: '#/components/responses/401Unauthorized'
   *       404:
   *         $ref: '#/components/responses/404NotFound'
   */
  ```

### Oefening 5 - Andere routes

Vervolledig zelf de documentatie voor alle overige routes in de applicatie.

## Oefening 6 - Eigen project

- Voeg Swagger toe aan je eigen project.
- Definieer de algemene documentatie voor je API.
- Definieer de documentatie voor **alle** routes in je API.

## Mogelijke extra's voor de examenopdracht

- Gebruik [apidoc](https://apidocjs.com/) i.p.v. Swagger
  - Let op: apidoc gebruikt geen OpenAPI specificatie (en dus geen aanvaarde standaard)
