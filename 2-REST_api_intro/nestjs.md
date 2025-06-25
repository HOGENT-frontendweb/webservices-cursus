<!-- markdownlint-disable first-line-h1 -->

## NestJS

Als IT'er is het belangrijk om te leren documentatie te lezen. De documentatie van NestJS is zeer uitgebreid en goed geschreven. We raden je aan om de documentatie grondig door te nemen, zeker als je vastloopt of iets niet begrijpt. De documentatie is beschikbaar op <https://docs.nestjs.com/>.

Om deze trend goed in te zetten, beginnen we met het lezen van de ["Introduction" sectie](https://docs.nestjs.com/) van de NestJS documentatie. Deze sectie geeft een beknopt overzicht van wat NestJS is, wat het doet, waarom je het zou gebruiken en hoe je een project opzet.

### Project opzetten

NestJS beschikt over een zeer uitgebreide Command Line Interface (CLI) die je helpt bij het opzetten van een nieuw project en het genereren van alle benodigde onderdelen. De CLI is een krachtig hulpmiddel dat je veel tijd kan besparen bij het ontwikkelen van je applicatie.

?> Merk op: we gebruiken min of meer de commando's vanop de NestJS documentatie, we zijn enkel gewisseld naar pnpm.

Allereerst installeer je de NestJS CLI globaal op je systeem. Dit kan je doen met het volgende commando:

```bash
pnpm add -g @nestjs/cli
```

Vervolgens maken we een nieuw project aan met de CLI. Dit kan je doen met het onderstaand commando. Tijdens de installatie kies je voor `pnpm` als package manager.

!> **Info voor de examenopdracht:** zorg ervoor dat je onderstaand commando in de root van jouw GitHub Classroom repository uitvoert, anders zal het project niet in de juiste map aangemaakt worden. Natuurlijk kan je het nadien verplaatsen.

```bash
nest new --strict webservices-budget
```

Hiermee maken we een nieuw NestJS project aan in de map `webservices-budget`. De `--strict` optie zorgt ervoor dat TypeScript strict is ingesteld, wat we aanraden om bugs te voorkomen. Dit is een goede gewoonte, zeker als je met TypeScript werkt. Het project wordt aangemaakt met de standaard mappenstructuur en een aantal voorbeeldbestanden.

Open deze map in VS Code.

### package.json

De [package.json](https://docs.npmjs.com/cli/v10/configuring-npm/package-json) bevat alle metadata van ons project, meer in het bijzonder alle dependencies en commando's om onze app te starten. Open de `package.json` en bekijk de inhoud. Deze bevat enkele properties:

- `name`: de naam van het project
- `version`: de versie van het project
- `description`: een korte beschrijving van het project
  - Deze mag je gerust aanvullen
- `author`: de auteur van de applicatie
  - Deze mag je gerust aanvullen
- `private`: of de applicatie publiek is of niet, npm zal bv. niet toelaten om een private package te publiceren
- `license`: de licentie van de applicatie
- `dependencies`: de packages waarvan deze applicatie gebruik maakt
- `devDependencies`: packages enkel nodig in development (en dus niet in productie)
- `scripts`: laten toe om een soort van shortcuts te maken voor scripts (bv. de applicatie starten, testen, builden voor productie, etc.)
- `jest`: de configuratie voor Jest, het test framework die gebruikt wordt (zie later)
- `packageManager`: de package manager die gebruikt wordt (in dit geval pnpm)

Voor de volledigheid kan je ook de volgende properties voorzien:

- `main`: het entry point van de applicatie
- `repository`: informatie over de repository van de applicatie

Met een simpele `pnpm install` installeren we meteen een identieke omgeving (met zowel `dependencies` als `devDependencies`) en dat maakt het handiger om in een team te werken (`pnpm install --prod` installeert enkel de `dependencies`).

Het verschil tussen `dependencies` en `devDependencies` is het moment wanneer ze gebruikt worden. De `dependencies` zijn nodig in productie, m.a.w. de applicatie kan niet werken zonder deze packages. De `devDependencies` zijn enkel nodig om bv. het leven van de developer makkelijker te maken (types in TypeScript, linting, etc.) of bevatten packages die enkel gebruikt worden _at build time_, of dus wanneer de applicatie omgevormd wordt tot iets wat browsers of JavaScript runtimes begrijpen.

Dependencies maken gebruik van [semantic versioning](https://semver.org/) (lees gerust eens door de specificatie). Kort gezegd houdt dit in dat elk versienummer bestaat uit drie delen: `MAJOR.MINOR.PATCH`, elke deel wordt met één verhoogd in volgende gevallen:

- `MAJOR`: wijzigingen die **_niet_** compatibel zijn met oudere versies
- `MINOR`: wijzigen die **_wel_** compatibel zijn met oudere versies
- `PATCH`: kleine bugfixes (compatibel met oudere versies)

In een `package.json` zie je ook vaak versies zonder prefix of met een tilde (~) of hoedje (^) als prefix, dit heeft volgende betekenis:

- geen prefix: exact deze versie
- tilde (~): ongeveer deze versie (zie <https://docs.npmjs.com/cli/v6/using-npm/semver#tilde-ranges-123-12-1>)
- hoedje (^): compatibel met deze versie (<https://docs.npmjs.com/cli/v6/using-npm/semver#caret-ranges-123-025-004>)

Kortom, een tilde is strenger dan een hoedje.

Het lijkt misschien een beetje raar, maar zo'n `package.json` wordt voor vele toepassingen en frameworks gebruikt. JavaScript programmeurs zijn gewoon van een `git pull`, `pnpm install` en `pnpm start` te doen, zonder per se te moeten weten hoe een specifiek framework opgestart wordt.

In jouw `package.json` zal je verschillende scripts zien om de server te starten:

- `start`: start de applicatie (zonder debugging of hot reloading)
- `start:dev`: start de applicatie in development modus (met hot reloading)
- `start:debug`: start de applicatie in debug modus
- `start:prod`: start de applicatie in productie modus

Deze scripts kan je uitvoeren met `pnpm <SCRIPT>`, bijvoorbeeld `pnpm start:dev`.

Er zijn nog heel wat andere opties voor de `package.json`. Je vindt alles op <https://docs.npmjs.com/cli/v10/configuring-npm/package-json>.

### pnpm-lock.yaml

Wanneer je een package installeert, zal pnpm een `pnpm-lock.yaml` bestand aanmaken. Dit bestand bevat de exacte versies van de packages die geïnstalleerd zijn. Dit bestand moet je zeker mee opnemen in je git repository. Dit zorgt ervoor dat iedereen exact dezelfde versies van de packages gebruikt.

Dit bestand vermijdt versieconflicten aangezien in de `package.json` niet altijd de exacte versie staat maar een bepaalde syntax die aangeeft welke versies toegelaten zijn (zie vorige sectie).

### .gitignore

Merk op dat er een `.gitignore` bestand aanwezig is in de root van het project. Dit bestand zorgt ervoor dat bepaalde bestanden en mappen niet naar GitHub gepusht worden. Dit is handig om te voorkomen dat je onnodige bestanden of mappen in je repository hebt, zoals de `node_modules` map die alle geïnstalleerde packages bevat. Je kan nl. de dependencies eenvoudig opnieuw installeren d.m.v. `pnpm install`.

Kijk gerust eens welke bestanden er allemaal genegeerd worden. Je kan dit bestand ook aanpassen naar eigen wens, maar dit is een vrij complete voor een Node.js project. Een vrij uitgebreide `.gitignore` voor Node.JS projecten is te vinden op GitHub: <https://github.com/github/gitignore/blob/main/Node.gitignore>.

### Projectstructuur

Alvorens we verder gaan, is het belangrijk om de projectstructuur van de basisapplicatie te begrijpen. Lees hiervoor de [First steps sectie](https://docs.nestjs.com/first-steps) in de NestJS documentatie. Een paar opmerkingen voor tijdens het lezen:

- Bootstrapping = het opstarten van de applicatie
- De sectie "Linting and formatting" mag je voorlopig nog negeren, we gaan dit later behandelen

### De obligate Hello World

Eens een developer een idee heeft van de basis van een framework, is het tijd om de obligate Hello World applicatie te maken. Gelukkig is dit net wat de NestJS CLI voor ons gegenereerd heeft. Open de `src/app.controller.ts` en `src/app.service.ts` bestanden en bekijk de code.

De `AppService` klasse bevat één methode `getHello()` die een string retourneert. Deze string wordt gebruikt in de `AppController` klasse, die een route definieert voor de root URL (`/`).

Start de applicatie in development modus met het volgende commando:

```bash
pnpm start:dev
```

Je zou nu een bericht moeten zien in de terminal dat de applicatie draait op `http://localhost:3000`. Open deze URL in je browser en je zou een "Hello World!" bericht moeten zien.

Ga naar de `AppService` klasse en pas de `getHello()` methode aan om een andere string te retourneren, bijvoorbeeld "Hallo wereld!". Sla het bestand op en herlaad de pagina in je browser. Je zou zien dat de tekst aangepast is naar "Hallo wereld!".
