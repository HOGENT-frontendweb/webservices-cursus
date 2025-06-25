<!-- markdownlint-disable first-line-h1 -->

## Health controller

Voor het volgende voorbeeld gaan we een eenvoudige controller maken die een health check uitvoert. Deze controller zal een endpoint aanbieden dat we kunnen gebruiken om te controleren of de server draait. Het is een veelvoorkomende praktijk in webservices om te controleren of de service beschikbaar is, NestJS heeft uitgebreide mogelijkheden om dit te doen <https://docs.nestjs.com/recipes/terminus#setting-up-a-healthcheck>. Voor deze oefening gaan we echter een eenvoudige controller maken die een `ping` endpoint aanbiedt.

### Controller genereren

Controllers in NestJS zijn verantwoordelijk voor het afhandelen van inkomende verzoeken en het retourneren van antwoorden. Ze zijn de brug tussen de client en de service laag van de applicatie. Lees eerst volgende secties in de documentatie:

- [Controllers](https://docs.nestjs.com/controllers#controllers)
- [Routing](https://docs.nestjs.com/controllers#routing)

NestJS biedt een CLI commando om automatisch een controller te genereren:

```bash
nest generate controller health
```

Dit commando maakt de volgende bestanden aan:

- `src/health/health.controller.ts`: de controller zelf
- `src/health/health.controller.spec.ts`: test bestand voor de controller

De controller wordt ook automatisch toegevoegd aan de `app.module.ts` (zie de `controllers` array). Zonder deze toevoeging zou de controller niet beschikbaar zijn in de applicatie.

### Route implementeren

Open het bestand `src/health/health.controller.ts` en vervang de inhoud door:

```typescript
import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get('ping')
  ping(): string {
    return 'pong';
  }
}
```

Deze controller zal alle requests op `/health` afhandelen. De `@Controller('health')` decorator geeft aan dat deze controller verantwoordelijk is voor alle routes die beginnen met `/health`.

De `@Get('ping')` decorator geeft aan dat de `ping()` methode reageert op `GET` verzoeken op de route `/health/ping`. De methode `ping()` retourneert een string "pong".

Start de server (als deze nog niet draait) en open de url <http://localhost:3000/health/ping> in je browser of Postman. Je zou de string "pong" moeten zien.
