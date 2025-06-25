<!-- markdownlint-disable first-line-h1 -->

<!-- TODO: dit moet ergens anders komen -->

## Logging

Manueel links en rechts wat middleware injecteren om iets te loggen is natuurlijk niet zo handig. Een goede logger laat toe om eenvoudig meer of minder te loggen al naargelang we in productie of development draaien.

Logs kan je ook met een zeker 'level' loggen, zodat je niet telkens alles moet in/uit commentaar zetten als je wat meer/minder detail wil. En nog veel meer..., een goede logger is best een uitgebreid stuk software.

Er bestaan gelukkig veel degelijke third party log libraries, we gebruiken [Winston](https://github.com/winstonjs/) in deze cursus. We installeren deze met:

```bash
yarn add winston
```

Vervolgens maken we een map `core` in de `src` map. Deze map bevat alle core functionaliteit van onze applicatie, zoals de logger. In deze map maken we een bestand `logging.ts` aan en voegen we volgende code toe:

```ts
// src/core/logging.ts
import winston from 'winston'; // 👈 1

// 👇 2
const rootLogger: winston.Logger = winston.createLogger({
  level: 'silly',
  format: winston.format.simple(),
  transports: [new winston.transports.Console()],
});

// 👇 3
export const getLogger = () => {
  return rootLogger;
};
```

1. We importeren de `winston` package.
2. We maken een root logger aan met een log level van `silly` en een eenvoudige formattering. We loggen enkel naar de console.
   - Je kan andere transports toevoegen, zoals een file transport, een transport naar een database, een transport naar een cloud service, etc. Winston handelt dit allemaal voor je af.
   - We maken slechts één logger voor de hele applicatie, maar je kan er ook meerdere maken voor verschillende delen van de applicatie. In dit geval hanteren we het [singleton](https://www.patterns.dev/vanilla/singleton-pattern/) patroon.
3. We exporteren een functie `getLogger` die de root logger teruggeeft.

Vervolgens passen we `src/index.ts` aan om de logger te gebruiken:

```ts
// src/index.ts
import { getLogger } from './core/logging'; // 👈 1

// ...

// 👇 2
app.listen(9000, () => {
  getLogger().info('🚀 Server listening on http://127.0.0.1:9000');
});
```

1. We importeren de `getLogger` functie.
2. We loggen een bericht wanneer de server opgestart is.
   - We maakten daarnet een zogenaamde _named export_, dit betekent dat we de functie moeten importeren tussen `{}`.

Voor nu volstaat dit, maar in het volgende hoofdstuk zullen we de logger nog uitbreiden met bv. een file transport in test modus, een aangepast formaat voor de logs, etc.
