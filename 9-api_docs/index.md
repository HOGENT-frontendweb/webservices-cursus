# API documentatie

Voor het schrijven van API documentatie bestaan verschillende tools. Swagger is een van de bekendste. Swagger is een set van open-source tools die samenwerken om REST API's te ontwerpen, bouwen, documenteren en consumeren. Swagger is gebaseerd op de OpenAPI specificatie. In dit hoofdstuk leer je hoe je een REST API documenteert met OpenAPI en Swagger in NestJS.

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les9 TODO:
> pnpm install
> pnpm db:migrate
> pnpm db:seed
> pnpm start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.

## Swagger vs OpenAPI

![Swagger versus Open API](./images/swagger.png)

### OpenAPI Specification

[OpenAPI Specification (OAS)](https://swagger.io/specification/), voorheen bekend als Swagger Specification, biedt een standaard, programmeertaal-onafhankelijke beschrijving van een REST API in YAML- of JSON-formaat. Het geeft alleen aan welke functionaliteit de API biedt, niet welke implementatie of dataset achter die API schuilgaat.

Met OAS 3.0 kunnen zowel mensen als machines de functionaliteit van een REST API bekijken, begrijpen en interpreteren, zonder toegang tot de broncode of aanvullende documentatie. Uit de documentatie kan client code worden gegenereerd. Een voorbeeld van de basisstructuur vind je hier: <https://swagger.io/docs/specification/basic-structure/>. Hierdoor kan je bv. code die de API aanroept, of zelfs een basisstructuur voor een back-end, laten genereren.

**Een API is maar zo goed als jij (ja, jij) hem documenteert.**

### Swagger

Swagger is een set van open source tools opgebouwd rond de OpenAPI specificatie om REST API's te ontwerpen, bouwen, documenteren en consumeren:

- [Swagger Editor](https://editor.swagger.io/): browser-based editor voor het schrijven van OpenAPI specs.
- [Swagger UI](https://swagger.io/tools/swagger-ui/): creëert een documentatiepagina voor de OpenAPI specs als interactieve API documentation.
- [Swagger Codegen](https://github.com/swagger-api/swagger-codegen): genereert server stubs en client libraries vanuit de OpenAPI spec.

## Swagger installeren in NestJS

NestJS heeft uitstekende ondersteuning voor Swagger via de `@nestjs/swagger` package. Deze package genereert automatisch de OpenAPI specificatie op basis van decorators in je code.

Installeer de nodige packages:

```bash
pnpm add @nestjs/swagger
```

Voor validatie met Swagger gebruiken we ook `nestjs-swagger-dto`, een handige package die class-validator en Swagger decorators combineert:

```bash
pnpm add nestjs-swagger-dto
```

## Swagger configureren

In NestJS configureren we Swagger in het `main.ts` bestand. Voeg de volgende code toe:

```ts
// src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger'; // 👈 1
// ... andere imports

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const config = app.get(ConfigService<ServerConfig>);
  const port = config.get<number>('port') || 9000;

  app.setGlobalPrefix('api');
  // ... andere configuratie (filters, pipes, etc.)

  // 👇 2
  const swaggerConfig = new DocumentBuilder()
    .setTitle('Budget Web Services') // 👈 3
    .setDescription('API application') // 👈 4
    .setVersion('1.0') // 👈 5
    .addBearerAuth() // 👈 6
    .build();

  // 👇 7
  const document = SwaggerModule.createDocument(app, swaggerConfig);

  // 👇 8
  SwaggerModule.setup('docs', app, document);

  await app.listen(port);
}

bootstrap();
```

1. We importeren `SwaggerModule` en `DocumentBuilder` van `@nestjs/swagger`.
2. We maken een nieuwe Swagger configuratie aan met `DocumentBuilder`.
3. We geven de API een titel.
4. We voegen een beschrijving toe.
5. We specificeren de API versie.
6. We voegen ondersteuning toe voor Bearer authentication (JWT).
7. We genereren het OpenAPI document op basis van de configuratie en de decorators in onze code.
8. We maken de Swagger UI beschikbaar op `/docs`.

Start je applicatie en navigeer naar <http://localhost:9000/docs>. Je zou de Swagger UI moeten zien met de basis configuratie.

De JSON specificatie is beschikbaar op <http://localhost:9000/docs-json>.

## DTO's documenteren

In NestJS documenteren we onze API door decorators toe te voegen aan onze DTO's en controllers. We beginnen met de DTO's.

### Response DTO's

Laten we de `PlaceResponseDto` documenteren:

```ts
// src/place/place.dto.ts
import { ApiProperty } from '@nestjs/swagger'; // 👈 1

export class PlaceResponseDto {
  @ApiProperty({ example: 1, description: 'ID of the place' }) // 👈 2
  id: number;

  @ApiProperty({
    example: 'Loon',
    description: 'Name of the place where transactions can occur',
  }) // 👈 3
  name: string;

  @ApiProperty({
    example: 4,
    description: 'Rating of the place (1 to 5)',
    nullable: true, // 👈 4
    format: 'int32',
    type: 'integer',
  })
  rating: number | null;
}
```

1. We importeren `ApiProperty` van `@nestjs/swagger`.
2. We voegen een `@ApiProperty` decorator toe aan elk veld. We geven een voorbeeld en beschrijving mee.
3. Hetzelfde voor de `name` property.
4. Voor `rating` specificeren we dat het `nullable` is (kan `null` zijn), en dat het een integer is met format `int32`.

Voor lijst responses maken we een aparte DTO:

```ts
// src/place/place.dto.ts
export class PlaceListResponseDto {
  @ApiProperty({ type: () => [PlaceResponseDto] }) // 👈
  items: PlaceResponseDto[];
}
```

We gebruiken `type: () => [PlaceResponseDto]` om aan te geven dat `items` een array is van `PlaceResponseDto` objecten.

### Request DTO's met nestjs-swagger-dto

Voor request DTO's gebruiken we `nestjs-swagger-dto`. Deze package combineert class-validator decorators met Swagger documentatie:

```ts
// src/place/place.dto.ts
import { IsNumber, IsString } from 'nestjs-swagger-dto'; // 👈 1

export class CreatePlaceRequestDto {
  @IsString({ name: 'name', maxLength: 255 }) // 👈 2
  name: string;

  @IsNumber({
    name: 'rating',
    min: 1, // 👈 3
    max: 5, // 👈 3
    optional: true, // 👈 4
    format: 'int32',
    type: 'integer',
  })
  rating?: number;
}
```

1. We importeren de decorators van `nestjs-swagger-dto` (niet van `class-validator`!).
2. `@IsString` valideert dat de waarde een string is en documenteert dit automatisch in Swagger. We geven ook de naam en maximale lengte mee.
3. Voor `@IsNumber` specificeren we minimum en maximum waarden.
4. We markeren `rating` als optioneel.

De `nestjs-swagger-dto` decorators zorgen automatisch voor:

- Validatie (zoals `class-validator`)
- Swagger documentatie (zoals `@ApiProperty`)
- Type definitie in de OpenAPI spec

Dit bespaart veel dubbele code!

Voor update DTO's kunnen we vaak de create DTO herbruiken:

```ts
// src/place/place.dto.ts
export class UpdatePlaceRequestDto extends CreatePlaceRequestDto {}
```

## Controllers documenteren

Nu gaan we de controller endpoints documenteren. We voegen decorators toe aan de controller en de individual routes.

### Controller-niveau documentatie

Voeg de `@ApiBearerAuth()` decorator toe aan de controller om aan te geven dat authenticatie vereist is:

```ts
// src/place/place.controller.ts
import { Controller, Get, Post, Put, Delete, Body, Param, ParseIntPipe } from '@nestjs/common';
import { ApiBearerAuth, ApiResponse } from '@nestjs/swagger'; // 👈 1
import { PlaceService } from './place.service';
import {
  CreatePlaceRequestDto,
  PlaceResponseDto,
  PlaceListResponseDto,
  UpdatePlaceRequestDto,
} from './place.dto';

@ApiBearerAuth() // 👈 2
@Controller('places')
export class PlaceController {
  constructor(private placeService: PlaceService) {}

  // Routes komen hier...
}
```

1. We importeren `ApiBearerAuth` en `ApiResponse` van `@nestjs/swagger`.
2. We voegen `@ApiBearerAuth()` toe om aan te geven dat alle routes in deze controller authenticatie vereisen.

### GET /api/places

Documenteer de route om alle places op te halen:

```ts
// src/place/place.controller.ts
@ApiResponse({
  status: 200, // 👈 1
  description: 'Get all places', // 👈 2
  type: PlaceListResponseDto, // 👈 3
})
@Get()
async getAllPlaces(): Promise<PlaceListResponseDto> {
  return await this.placeService.getAll();
}
```

1. We specificeren de HTTP status code voor een succesvolle response.
2. We geven een beschrijving van wat deze route doet.
3. We specificeren het type van de response (het DTO).

### POST /api/places

Documenteer de route om een nieuwe place aan te maken:

```ts
// src/place/place.controller.ts
@ApiResponse({
  status: 201,
  description: 'Create place',
  type: PlaceResponseDto,
})
@Post()
async createPlace(
  @Body() createPlaceDto: CreatePlaceRequestDto,
): Promise<PlaceResponseDto> {
  return await this.placeService.create(createPlaceDto);
}
```

NestJS herkent automatisch dat `createPlaceDto` een request body is en documenteert dit in Swagger, inclusief het schema dat we met `nestjs-swagger-dto` hebben gedefinieerd.

### GET /api/places/:id

Documenteer de route om een specifieke place op te halen:

```ts
// src/place/place.controller.ts
@ApiResponse({
  status: 200,
  description: 'Get place by ID',
  type: PlaceResponseDto,
})
@Get(':id')
async getPlaceById(
  @Param('id', ParseIntPipe) id: number,
): Promise<PlaceResponseDto> {
  return await this.placeService.getById(id);
}
```

De `:id` parameter wordt automatisch herkend en gedocumenteerd door NestJS.

### PUT /api/places/:id

Documenteer de route om een place te updaten:

```ts
// src/place/place.controller.ts
@ApiResponse({
  status: 200,
  description: 'Update place',
  type: PlaceResponseDto,
})
@Put(':id')
async updatePlace(
  @Param('id', ParseIntPipe) id: number,
  @Body() updatePlaceDto: UpdatePlaceRequestDto,
): Promise<PlaceResponseDto> {
  return await this.placeService.updateById(id, updatePlaceDto);
}
```

### DELETE /api/places/:id

Documenteer de route om een place te verwijderen:

```ts
// src/place/place.controller.ts
@Delete(':id')
@HttpCode(HttpStatus.NO_CONTENT)
async deletePlace(@Param('id', ParseIntPipe) id: number): Promise<void> {
  await this.placeService.deleteById(id);
}
```

Voor een DELETE zonder response body hoeven we geen `@ApiResponse` toe te voegen. NestJS documenteert automatisch de 204 status code.

## Meerdere response types documenteren

Soms wil je meerdere mogelijke responses documenteren (success, error, not found, etc.):

```ts
// src/place/place.controller.ts
@ApiResponse({
  status: 200,
  description: 'Get place by ID',
  type: PlaceResponseDto,
})
@ApiResponse({
  status: 404,
  description: 'Place not found',
})
@ApiResponse({
  status: 401,
  description: 'Unauthorized - you need to be signed in',
})
@Get(':id')
async getPlaceById(
  @Param('id', ParseIntPipe) id: number,
): Promise<PlaceResponseDto> {
  return await this.placeService.getById(id);
}
```

Je kan meerdere `@ApiResponse` decorators toevoegen voor verschillende status codes.

## Login route documenteren

Laten we ook de login route documenteren:

```ts
// src/sessions/sessions.controller.ts
import { Controller, Post, Body } from '@nestjs/common';
import { ApiResponse } from '@nestjs/swagger';
import { AuthService } from '../auth/auth.service';
import { LoginRequestDto, LoginResponseDto } from './sessions.dto';
import { Public } from '../auth/decorators/public.decorator';

@Controller('sessions')
export class SessionsController {
  constructor(private authService: AuthService) {}

  @ApiResponse({
    status: 200,
    description: 'Login successful',
    type: LoginResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Invalid credentials',
  })
  @Public()
  @Post()
  async signIn(@Body() loginDto: LoginRequestDto): Promise<LoginResponseDto> {
    const token = await this.authService.login(loginDto);
    return { token };
  }
}
```

En de bijbehorende DTO's:

```ts
// src/sessions/sessions.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString } from 'class-validator';

export class LoginRequestDto {
  @ApiProperty({ example: 'thomas.aelbrecht@hogent.be' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: '12345678' })
  @IsString()
  password: string;
}

export class LoginResponseDto {
  @ApiProperty({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'JWT token for authentication',
  })
  token: string;
}
```

## API testen met Swagger UI

Nu is het tijd om de API te testen via de Swagger UI:

1. Open <http://localhost:9000/docs> in je browser.
2. Klik op de `POST /api/sessions` route.
3. Klik op **"Try it out"**.
4. Voer de volgende gegevens in:

  ```json
  {
    "email": "thomas.aelbrecht@hogent.be",
    "password": "12345678"
  }
  ```

<!-- markdownlint-disable ol-prefix -->

5. Klik op **"Execute"**. Je krijgt een JWT token terug.
6. Kopieer het token (zonder de quotes).
7. Klik rechtsboven op de **"Authorize"** knop (🔒).
8. Plak het token in het veld en klik op **"Authorize"**.
9. Nu kan je alle andere routes testen die authenticatie vereisen!

<!-- markdownlint-enable ol-prefix -->

Probeer de verschillende routes uit:

- `GET /api/places` - Alle places ophalen
- `POST /api/places` - Een nieuwe place aanmaken
- `GET /api/places/{id}` - Een specifieke place ophalen
- `PUT /api/places/{id}` - Een place updaten
- `DELETE /api/places/{id}` - Een place verwijderen

## Oefening 1 - Transactions documenteren

Documenteer de volledige `transactions` module:

1. Maak de nodige DTO's aan voor transactions:
   - `TransactionResponseDto` - Voor een enkele transaction
   - `TransactionListResponseDto` - Voor een lijst van transactions
   - `CreateTransactionRequestDto` - Voor het aanmaken van een transaction
   - `UpdateTransactionRequestDto` - Voor het updaten van een transaction

2. Voeg Swagger decorators toe aan de DTO's:
   - Gebruik `@ApiProperty` voor response DTO's
   - Gebruik `nestjs-swagger-dto` decorators voor request DTO's

3. Documenteer alle routes in `TransactionController`:
   - `GET /api/transactions` - Alle transactions ophalen (van aangemelde gebruiker)
   - `POST /api/transactions` - Een nieuwe transaction aanmaken
   - `GET /api/transactions/:id` - Een specifieke transaction ophalen
   - `PUT /api/transactions/:id` - Een transaction updaten
   - `DELETE /api/transactions/:id` - Een transaction verwijderen

4. Vergeet niet om meerdere response types te documenteren waar nodig (200, 401, 403, 404).

**Tips:**

- Een transaction heeft een `amount` (number), `date` (Date), `placeId` (number), en `userId` (number).
- Voor de response DTO kan je de volledige `place` en `user` objecten includen (zoals in de BudgetBackend).
- Gebruik de [NestJS Swagger documentatie](https://docs.nestjs.com/openapi/types-and-parameters) als referentie.
- Kijk naar de `place.dto.ts` en `place.controller.ts` voor inspiratie.

## Oefening 2 - Users documenteren

Documenteer de `users` module:

1. De `PublicUserResponseDto` is al gedocumenteerd in hoofdstuk 7, maar voeg eventueel extra Swagger decorators toe indien nodig.

2. Documenteer alle routes in `UserController`:
   - `GET /api/users` - Alle users ophalen (enkel voor admins)
   - `POST /api/users` - Een nieuwe user registreren (publieke route)
   - `GET /api/users/:id` - Een specifieke user ophalen (enkel eigen data of als admin)
   - `PUT /api/users/:id` - Een user updaten (enkel eigen data of als admin)
   - `DELETE /api/users/:id` - Een user verwijderen (enkel eigen data of als admin)

3. Speciale aandacht voor:
   - De `POST /api/users` route is publiek (gebruik `@Public()` decorator)
   - Voor registratie is een `RegisterUserRequestDto` nodig met `name`, `email` en `password`
   - De `GET /api/users/:id` route accepteert ook `'me'` als ID

**Let op:** Documenteer NOOIT het wachtwoord in response DTO's! We geven enkel publieke user data terug (id, name, email).

## Oefening 3 - Eigen project

Voeg volledige Swagger documentatie toe aan je eigen examenopdracht:

1. Installeer `@nestjs/swagger` en `nestjs-swagger-dto`.
2. Configureer Swagger in `main.ts`.
3. Documenteer alle DTO's met de juiste decorators.
4. Documenteer alle controller routes.
5. Test de API via de Swagger UI op `/docs`.

**Checklist:**

- [ ] Alle request DTO's gebruiken `nestjs-swagger-dto` voor validatie + documentatie
- [ ] Alle response DTO's gebruiken `@ApiProperty` decorators
- [ ] Alle controllers hebben `@ApiBearerAuth()` waar nodig
- [ ] Alle routes hebben `@ApiResponse` decorators
- [ ] Meerdere response types zijn gedocumenteerd (success, error, not found)
- [ ] De Swagger UI toont alle endpoints correct
- [ ] Je kan de API testen via de Swagger UI

> **Oplossing voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les9-opl TODO:
> pnpm install
> pnpm db:migrate
> pnpm db:seed
> pnpm start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.

## Geavanceerde Swagger features

### Tags gebruiken

Je kan routes groeperen met tags:

```ts
import { ApiTags } from '@nestjs/swagger';

@ApiTags('places') // 👈
@ApiBearerAuth()
@Controller('places')
export class PlaceController {
  // ...
}
```

### Query parameters documenteren

Voor query parameters gebruik je `@ApiQuery`:

```ts
import { ApiQuery } from '@nestjs/swagger';

@ApiQuery({
  name: 'limit',
  required: false,
  type: Number,
  description: 'Maximum number of results',
})
@ApiQuery({
  name: 'offset',
  required: false,
  type: Number,
  description: 'Number of results to skip',
})
@Get()
async getAllPlaces(
  @Query('limit') limit?: number,
  @Query('offset') offset?: number,
): Promise<PlaceListResponseDto> {
  // ...
}
```

### Enum types documenteren

Voor enum waarden:

```ts
export enum PlaceRating {
  ONE = 1,
  TWO = 2,
  THREE = 3,
  FOUR = 4,
  FIVE = 5,
}

export class CreatePlaceRequestDto {
  @IsString({ name: 'name', maxLength: 255 })
  name: string;

  @ApiProperty({ enum: PlaceRating }) // 👈
  @IsEnum(PlaceRating)
  rating?: PlaceRating;
}
```

## Waarom is API documentatie belangrijk?

1. **Voor andere developers**: Ze kunnen snel begrijpen hoe je API werkt zonder door de code te moeten spitten.
2. **Voor jezelf**: Over enkele maanden ben je vergeten hoe bepaalde endpoints werken. Goede documentatie helpt je om snel weer op te pikken waar je gebleven was.
3. **Voor frontend developers**: Ze kunnen direct aan de slag met je API zonder veel vragen te stellen.
4. **Voor testers**: Ze kunnen de API makkelijk testen via de Swagger UI.
5. **Voor automatisering**: Je kan client libraries genereren op basis van de OpenAPI specificatie.

**Onthoud:** Een API is maar zo goed als de documentatie. Investeer tijd in goede documentatie, het betaalt zich dubbel en dik terug!

## Handige links

- [NestJS OpenAPI (Swagger) documentatie](https://docs.nestjs.com/openapi/introduction)
- [OpenAPI Specification](https://swagger.io/specification/)
- [Swagger Editor](https://editor.swagger.io/) - Voor het testen van OpenAPI specs
- [nestjs-swagger-dto package](https://www.npmjs.com/package/nestjs-swagger-dto)

## Mogelijke extra's voor de examenopdracht

- Voeg paginatie toe aan je lijst endpoints en documenteer deze correct met query parameters
- Gebruik `@ApiTags` om je endpoints logisch te groeperen
- Voeg voorbeelden toe aan je DTO's met de `example` property
- Genereer een client library op basis van je OpenAPI spec met [OpenAPI Generator](https://openapi-generator.tech/)
