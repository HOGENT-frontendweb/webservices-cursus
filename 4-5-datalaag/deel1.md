# Datalaag en places

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les4 1e3ffd2
> pnpm install
> pnpm start:dev
> ```

## Leerdoelen

- Je krijgt inzicht in de gelaagde architectuur
- Je kan een datalaag implementeren met Drizzle ORM in NestJS
- Je kan een simpele tabel definiëren en gebruiken met Drizzle
- Je weet wat migraties en seeds zijn
- Je kan migraties maken en uitvoeren
- Je kan seeds maken en uitvoeren

## Gelaagde architectuur

De **gelaagde architectuur** is een veel gebruikte architectuur waarin code is opgebouwd uit diverse lagen. In de context van het web zijn dit vaak volgende lagen:

- REST API (= presentatielaag)
- Servicelaag (= domeinlaag)
- Repositorylaag (= persistentielaag)
- Datalaag (= persistentielaag)

Veel frameworks zijn opgebouwd rond deze architectuur (Spring, .NET...). In pure Node.js heb je de keuze, er is geen verplichte structuur. In NestJS daarentegen is de structuur grotendeels opgelegd door het framework, en het volgt ook de gelaagde architectuur.

Een alternatieve structuur, veel gebruikt bij microservices, is de [**hexagonale structuur**](https://medium.com/idealo-tech-blog/hexagonal-ports-adapters-architecture-e3617bcf00a0). Een mooie (maar complexe) implementatie van deze structuur in Node.js (en TypeScript) vind je hier: <https://github.com/jbreckmckye/node-typescript-architecture>.

Dit hoofdstuk focust op de twee onderste lagen: **data-** en **repositorylaag**.

## Datalaag

De datalaag is een typische laag in de gelaagde architectuur voor het web. Het handelt de communicatie met de databank af:

- connectie opzetten, onderhouden en afsluiten indien nodig.
- databank aanmaken en up-to-date houden (= migraties).
- In development: seeden (= vullen) van de database met testdata.
- CRUD-operaties: dit wordt vaak afgehandeld door een framework die een soort repository-interface beschikbaar maakt, maar DIY kan ook.

Er zijn een aantal mogelijkheden om de datalaag te implementeren:

- zelf queries schrijven
- querybuilder
- Object Relational Mapper (ORM)

### Datalaag: zelf queries schrijven

Dit is waarschijnlijk de eerste mogelijkheid die in je opkomt wanneer je data moet ophalen in een applicatie. Het is zeker geen slecht idee, in de juiste context. Het zelf schrijven van queries is altijd een mogelijkheid maar het geeft je meestal meer werk dan nodig is om de code te onderhouden of om bepaalde zaken te implementeren.

In deze mogelijkheid schrijf je zelf queries in string-vorm (in JavaScript) die je vervolgens doorgeeft aan een bepaalde client die voor jou de query naar de databank zal sturen en je het antwoord teruggeeft. Deze queries kunnen placeholders bevatten voor bepaalde parameters (bv. `WHERE` clauses of `INSERT` queries). Hierbij handelt de client meestal SQL injection af. Gebruik je totaal geen client? Dan moet je zelf opletten voor SQL injection. Daarnaast geven deze clients vaak het pure resultaat terug zoals het van de query engine terugkwam, het is dus aan de developer om deze data te mappen naar het juiste formaat.

Dit is een mogelijkheid die heel geschikt is voor een kleine applicatie die weinig speciaals vereist van de databank, typische een applicatie met weinig tot geen relaties en/of CUD-queries. Nee, dit is geen schrijffout: weinig tot geen Create, Update of Delete queries. Indien de applicatie meer relaties krijgt en complexere tabellen, wordt het al gauw moeilijk om zelf geschreven queries te onderhouden.

#### Samengevat

- (grondige) kennis van SQL vereist
- queries in string-vorm
- je krijgt pure resultaten uit de databank terug (dus relaties zelf groeperen in aggregaten...)
- ideaal voor kleine applicaties
- bv. [mysql](https://www.npmjs.com/package/mysql),[pg](https://www.npmjs.com/package/pg), [mongodb](https://www.npmjs.com/package/mongodb), [redis](https://www.npmjs.com/package/redis)

### Datalaag: querybuilder

Een tweede optie is om de queries dynamisch te laten opbouwen door een bepaald framework. Hierbij vermijd je dat je zelf queries moet schrijven en onderhouden, het framework zal dit voor jou afhandelen. Daarbij krijg je bij deze frameworks gratis en voor niets bescherming tegen SQL injection.

Afhankelijk van het gekozen framework zijn relaties al dan niet ondersteund. Echter blijft de ondersteuning beperkt aangezien deze frameworks focussen op het bouwen van queries en niet op het eenvoudig maken van bepaalde OO-concepten in databanken. Vaak moet je dus zelf nog je relaties (en bijbehorende referentiële integriteit) afhandelen om een consistente databank te hebben.

Een heel bekende querybuilder voor Node.js is [knex.js](https://www.npmjs.com/package/knex). Het biedt een eenvoudige interface m.b.v. het [builder patroon](https://refactoring.guru/design-patterns/builder) en heeft native ondersteuning voor async/await.

Om een meer OO-aanpak te krijgen, kan je gebruik maken van [objection.js](https://www.npmjs.com/package/objection). Objection laat je toe om eenvoudig en automatisch relaties op te halen. Er is ook ondersteuning voor CUD-operaties voor relaties, maar de documentatie raadt af om deze intensief te gebruiken.

#### Samengevat

- dynamisch queries opbouwen
- soms ondersteuning voor eenvoudig gebruik van relaties
- nog steeds kennis van SQL vereist
- bv. [knex.js](https://www.npmjs.com/package/knex) of [objection.js](https://www.npmjs.com/package/objection)

### Datalaag: Object Relational Mapper (ORM)

Dit is de meest eenvoudige aanpak voor ontwikkelaars die geen of beperkte kennis hebben van SQL en databankontwerp. Een ORM neemt de noodzaak van SQL-kennis weg en zal zelf queries genereren om data op te halen. Het enige wat een ORM moet weten is hoe het databankschema eruit ziet. Hierbij kan de ontwikkelaar gebruik maken van alle OO-concepten, het ORM zal ervoor zorgen dat de gegeven data weggeschreven kan worden naar de databank. Dat is letterlijk wat de naam beschrijft: Object Relational Mapper.

Enige voorzichtigheid met ORMs is noodzakelijk aangezien deze niet altijd de meest optimale query genereren voor de data die opgehaald moet worden. Ook kan de interface van het gekozen framework sommige aspecten juist moeilijker maken dan simpelweg de query schrijven of dynamisch opbouwen.

Het is dus belangrijk om te controleren of je effectief een ORM nodig hebt aangezien dit een redelijke complexiteit toevoegt aan je applicatie. Indien je bv. gebruik maakt van GraphQL is het overkill om een ORM te gaan gebruiken aangezien de gebruiker hierbij zelf kan kiezen welke data hij wel of niet ophaalt. Bij REST kan het dan weer een meerwaarde zijn. Het hangt sterk af van project tot project, denk hierbij bv. aan het aantal relaties of de moeilijkheid van de uitgevoerde queries.

#### Samengevat

- geen kennis van SQL vereist, genereert zelf queries
- eenvoudige interface om data op te vragen of weg te schrijven
- diepgaande ondersteuning voor relaties
- model definiëren kan complex zijn
- bv. [Sequelize](https://www.npmjs.com/package/sequelize), [Prisma](https://www.npmjs.com/package/prisma), [Drizzle](https://orm.drizzle.team/), [TypeORM (enkel voor TypeScript)](https://www.npmjs.com/package/typeorm), [Mongoose (enkel voor MongoDB)](https://www.npmjs.com/package/mongoose)

### Datalaag: wat kiezen we nu?

Wij kiezen voor [Drizzle](https://orm.drizzle.team/), een ORM met native ondersteuning voor TypeScript.In ons voorbeeld hebben we een aantal relaties die we eenvoudig willen opvragen en we hebben geen geavanceerde queries nodig. Drizzle is dus een goede keuze voor ons project.

Voel je vrij om voor het project bv. een querybuilder of een ander ORM framework te gebruiken! We raden niet aan om zelf queries te schrijven, tenzij je écht een goede reden hebt.

## MySQL databank

Normaal heb je een lokale MySQL server draaien van het olod Databases. Mocht dit niet het geval zijn, dan heb je twee opties:

1. Je installeert MySQL zoals in de [instructies aan het begin van de cursus](../0-intro/software.md#mysql)
2. Je gebruikt een Docker container

### MySQL in Docker

Als je ervoor kiest om MySQL in een Docker container te draaien, maak je je best een `docker-compose.yml` bestand aan in de root van je project:

```yaml
services:
  db:
    image: mysql:8.0
    ports:
      - '3306:3306'
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: budget
      MYSQL_USER: devusr
      MYSQL_PASSWORD: devpwd
    healthcheck:
      test: ['CMD', 'mysqladmin', 'ping', '-h', 'localhost', '--silent']
      timeout: 30s
      interval: 30s
      retries: 5
      start_period: 30s

volumes:
  db_data:
```

Dit bestand definieert een MySQL container met:

- als naam `db`
- een port mapping van 3306 in de container naar 3306 op jouw systeem
- een named volume om de data in de databank te bewaren
- het wachtwoord van de root gebruiker
- de naam van de databank die aangemaakt moet worden: `budget`
  - pas dit aan voor je eigen project
- de credentials voor de gebruiker `devusr`
  - deze heeft toegang tot de databank `budget`
- een healthcheck om te controleren of de databank al klaar is

Open een terminal in de root van je project en start de databank container

```bash
docker compose up -d
```

?> Voor de veiligheid kan je de eerste keer zonder de `-d` optie uitvoeren zodat je in de logs kan checken of de container goed opgestart wordt.

## Installatie Drizzle

Onze configuratie is gebaseerd op een aantal verschillende tutorials:

- <https://dev.to/anooop102910/how-to-integrate-drizzle-orm-with-nest-js-gdc>
- <https://trilon.io/blog/nestjs-drizzleorm-a-great-match>
- <https://orm.drizzle.team/docs/get-started/mysql-new>

Dus zoals je ziet moet je soms zelf wat puzzelen met verschillende tutorials om alles aan de praat te krijgen. Het is een best practice om een tutorial ook altijd eens door te lezen alvorens je die klakkeloos herhaalt. Niet elke tutorial is even goed of up-to-date. **Het is de bedoeling dat je externe modules altijd degelijk integreert in jouw projectstructuur, dus je hoeft niet noodzakelijk exact de documentatie te volgen.**

We installeren allereerst Drizzle en de MySQL driver:

```bash
pnpm add drizzle-orm mysql2
pnpm add -D drizzle-kit
```

- [**drizzle-orm**](https://www.npmjs.com/package/drizzle-orm): bevat alles van Drizzle
- [**mysql2**](https://www.npmjs.com/package/mysql2): MySQL driver voor Node.js
- [**drizzle-kit**](https://www.npmjs.com/package/drizzle-kit): een handige CLI om migraties en seeds te beheren
  - Merk op: `drizzle-kit` is een dev dependency aangezien je deze niet nodig hebt om de server te kunnen starten.

Na de installatie voer je het volgende commando uit om te selecteren welke packages gebuild mogen worden:

```bash
pnpm approve-builds

# Selecteer alles door op de letter a te drukken
# Druk op Enter
# Voer vervolgens de letter y in om te bevestigen
```

pnpm zal steeds vragen om goedkeuring als een package gebuild moet worden na installatie.

### Environment variabele `DATABASE_URL`

We gaan de url naar onze databank niet hardcoderen. Dit maakt het moeilijk om aan te passen en zorgt ervoor dat productiecredentials mogelijk in de broncode terechtkomen.

Daarom voegen we in het `.env` bestand in de root van ons project de connectiestring toe via de variabele `DATABASE_URL`:

```ini
DATABASE_URL=mysql://<gebruikersnaam>:<wachtwoord>@localhost:3306/budget
```

?> Pas voor jouw eigen project de naam van je databank aan. De naam vind je na de `/`.

Als je geen gebruik maakt van een lokale MySQL server, maar van een Docker container, gebruik dan de credentials die je in het `docker-compose.yml` bestand hebt opgegeven. In dat geval wordt dit je `.env` bestand:

```ini
DATABASE_URL=mysql://devusr:devpwd@localhost:3306/budget
```

### Configuratie drizzle-kit

Allereerst voegen we een `drizzle.config.ts` bestand toe in de root van ons project:

```ts
import { defineConfig } from 'drizzle-kit';

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL is not set');
}

export default defineConfig({
  dialect: 'mysql',
  schema: './src/drizzle/schema.ts',
  out: './migrations',
  dbCredentials: {
    url: process.env.DATABASE_URL,
  },
});
```

Dit bestand definieert een aantal zaken:

- `dialect`: de databank die we gebruiken, in ons geval MySQL
- `schema`: het bestand waarin we ons databankschema gaan definiëren
  - Je kan ook een map opgeven als je het schemabestand liever splitst over meerdere bestanden
- `out`: de map waarin de migraties worden opgeslagen
- `dbCredentials`: de connectiegegevens van de databank
  - In ons geval halen we deze uit de environment variabele `DATABASE_URL`
  - We gooien een error als deze variabele niet bestaat

### Configuratie aanvullen

Alvorens we onze connectie met de databank kunnen maken, moeten we nog een aantal zaken aanvullen in onze configuratie.

Vul het `src/config/configuration.ts` bestand aan met een interface voor de database configuratie:

```ts
export interface DatabaseConfig {
  url: string;
}
```

Vul vervolgens de default export in `src/config/configuration.ts` aan met de database configuratie:

```ts
export default () => ({
  // ...
  database: {
    url: process.env.DATABASE_URL,
  },
});
```

Voeg daarna de database configuratie toe aan de `ServerConfig` interface:

```ts
export interface ServerConfig {
  env: string;
  port: number;
  database: DatabaseConfig; // 👈
}
```

### Drizzle connectie als provider

In NestJS wordt de connectie met de databank best als provider aangeboden. Op die manier zijn we zeker dat er slechts één connectie is in de volledige applicatie. We maken hiervoor een `drizzle` module aan:

```bash
pnpm nest generate module drizzle
```

Dit genereert een bestand `src/drizzle/drizzle.module.ts` met onze DrizzleModule.

Lees eerst de sectie rond [Async providers](https://docs.nestjs.com/fundamentals/async-providers).

Vervolgens definiëren we onze async provider in een bestand `src/drizzle/drizzle.provider.ts`. Maak dit bestand en definieer een constante met de sleutel van de provider. Op basis van deze sleutel kunnen we de provider later injecteren in bv. onze services.

```ts
export const DrizzleAsyncProvider = 'DrizzleAsyncProvider';
```

Daaronder definiëren we onze Drizzle connectie die we aanbieden als async provider met deze sleutel:

```ts
import { ConfigService } from '@nestjs/config';
import { drizzle } from 'drizzle-orm/mysql2';
import * as mysql from 'mysql2/promise';
import { DatabaseConfig, ServerConfig } from '../config/configuration';

// sleutel constante

export const drizzleProvider = [
  {
    provide: DrizzleAsyncProvider, // 👈 1
    inject: [ConfigService], // 👈 2
    // 👇 3
    useFactory: (configService: ConfigService<ServerConfig>) => {
      // 👇 4
      const databaseConfig = configService.get<DatabaseConfig>('database')!;
      // 👇 5
      return drizzle({
        client: mysql.createPool({
          uri: databaseConfig.url,
          connectionLimit: 5,
        }),
        mode: 'default',
      });
    },
  },
];
```

1. We bieden de Drizzle connectie aan met de sleutel `DrizzleAsyncProvider`.
2. We injecteren de `ConfigService` aangezien we onze database configuratie nodig hebben.
3. Aangezien de connectie asynchroon gemaakt wordt, moeten we gebruik maken van een async provider. De `useFactory` functie krijgt de geïnjecteerde `ConfigService` als parameter binnen.
4. We halen enkel de `database` configuratie op.
5. De `useFactory` functie geeft de Drizzle connectie terug.
   - We maken gebruik van een MySQL connection pool, dit houdt een lijst van connecties naar de databank open die hergebruikt kunnen worden.
   - In dit geval beperken we het aantal connecties tot 5.
   - Voor MySQL moeten we ook de waarde `default` meegeven aan de optie `mode`. Deze bepaalt hoe Drizzle queries zal uitvoeren.

Om ons leven makkelijker te maken definiëren we een custom decorator om de Drizzle connectie te injecteren. Zo hoeven we niet altijd de provider sleutel te gebruiken. Definieer deze in het bestand `src/drizzle/drizzle.provider.ts`:

```ts
export const InjectDrizzle = () => Inject(DrizzleAsyncProvider);
```

Een [decorator](https://www.typescriptlang.org/docs/handbook/decorators.html) is in principe een simpele functie. Dit herken je ook in onze `InjectDrizzle` decorator. Deze decorator roept onderliggend de `Inject` decorator van NestJS aan.

Importeer `Inject` uit het `@nestjs/common` package.

Opdat we onze provider kunnen gebruiken, definiëren we deze als provider en export in onze `DrizzleModule`:

```ts
import { Module } from '@nestjs/common';
import { DrizzleAsyncProvider, drizzleProvider } from './drizzle.provider';

@Module({
  providers: [...drizzleProvider], // 👈
  exports: [DrizzleAsyncProvider], // 👈
})
export class DrizzleModule {}
```

## Databankschema definiëren

Het ERD waar we uiteindelijk naartoe willen, ziet er zo uit (zie vorig hoofdstuk):

![ERD](../3-REST_api_bouwen/images/budget_erd.svg)

In dit hoofdstuk beginnen we met het definiëren van enkel de places tabel. Het schema voor onze databank schrijven we in het bestand `src/drizzle/schema.ts`:

```ts
// src/drizzle/schema.ts
import {
  int,
  mysqlTable,
  varchar,
  uniqueIndex,
  tinyint,
} from 'drizzle-orm/mysql-core';

export const places = mysqlTable(
  'places',
  {
    id: int('id', { unsigned: true }).primaryKey().autoincrement(),
    name: varchar('name', { length: 255 }).notNull(),
    rating: tinyint('rating', { unsigned: true }).notNull(),
  },
  (table) => [uniqueIndex('idx_place_name_unique').on(table.name)],
);
```

Je merkt dat de syntax van Drizzle heel leesbaar is. Probeer zelf eens te achterhalen wat deze code precies doet.

- Uitleg schema +

  - De `mysqlTable` functie maakt een nieuwe tabel aan. De eerste parameter is de naam van de tabel, de tweede parameter is een object met alle kolommen en hun eigenschappen, en de derde parameter is een functie die indices kan definiëren.
  - Elke kolom wordt gedefinieerd met een functie die het type van de kolom bepaalt, in dit geval `int`, `varchar` en `tinyint`. De opties die je kan meegeven variëren per data type: <https://orm.drizzle.team/docs/column-types/mysql>.
  - Je kan ook indices definiëren, in dit geval een unieke index op de naam van de plaats. Deze index heeft de naam `idx_place_name_unique`. Deze index zorgt ervoor dat er geen twee plaatsen met dezelfde naam kunnen bestaan.

Nu importeren we ons schema in `src/drizzle/drizzle.provider.ts`:

```ts
import * as schema from './schema';
```

En geven we het mee als optie aan de `drizzle` functie:

```ts
return drizzle({
  client: mysql.createPool({
    uri: databaseConfig.url,
    connectionLimit: 5,
  }),
  mode: 'default',
  schema, // 👈
});
```

Nu is Drizzle op de hoogte van ons schema en kunnen we queries uitvoeren.

Als laatste definiëren we een type voor onze provider, zo krijgen we de juiste aanvullingen in onze IDE:

```ts
export type DatabaseProvider = MySql2Database<typeof schema> & {
  $client: mysql.Pool;
};
```

We definiëren een type `DatabaseProvider` van het type `MySql2Database`. Aan `MySql2Database` geven we het type van ons schema door via `typeof`. We breiden het type uit met een `$client` optie zodat we later onze connectie kunnen sluiten. Importeer `MySql2Database` uit `drizzle-orm/mysql2`.

## Connectie afsluiten

Opdat onze NestJS server correct afsluit, moeten we onze databankconnectie sluiten als de NestJS server afgesloten wordt. NestJS biedt een aantal lifecycle events aan zodat je kan inhaken op gebeurtenissen in de applicatie.

Lees eerst de [documentatie over lifecycle events](https://docs.nestjs.com/fundamentals/lifecycle-events).

```ts
import { Module, OnModuleDestroy } from '@nestjs/common'; // 👈 1
import {
  type DatabaseProvider, // 👈 3
  DrizzleAsyncProvider,
  drizzleProvider,
  InjectDrizzle,
} from './drizzle.provider';

@Module({
  providers: [...drizzleProvider],
  exports: [DrizzleAsyncProvider],
})
// 👇 1
export class DrizzleModule implements OnModuleDestroy {
  constructor(@InjectDrizzle() private readonly db: DatabaseProvider) {} // 👈 3

  // 👇 2
  async onModuleDestroy() {
    await this.db.$client.end(); // 👈 4
  }
}
```

1. Laat de `DrizzleModule` de interface `OnModuleDestroy` implementeren.
2. Definieer een `onModuleDestroy` methode.
3. Injecteer onze Drizzle provider. Het type importeren we uit `drizzle.provider.ts`. De `import type` syntax zorgt ervoor dat deze import enkel gebruikt wordt voor types en niet in de gegenereerde JavaScript code terechtkomt.
4. Sluit de connectie als deze module afgebroken wordt.

## Migrations

Vooraleer we queries kunnen uitvoeren op de databank, moeten we hierin eerst de nodige tabellen en relaties definiëren. Dit doen we met behulp van **migrations**. In sommige NoSQL databanken, zoals MongoDB, is dit niet nodig, maar in relationele databanken is dit een must.

Migrations zijn een soort versiebeheersysteem voor de databank. Ze kijken op welke versie het databankschema zit en doen eventueel updates. Ze brengen het databankschema naar een nieuwere versie.

Je kan ook wijzigingen ongedaan maken als er iets fout liep. Dit is zeer belangrijk bij databanken in productie! In development kan je simpelweg de databank droppen en opnieuw maken, dat is geen probleem. Echter is dit not done in productie.

Het is wel belangrijk dat je let op de volgorde van uitvoeren van de migraties om geen problemen te krijgen met bv. foreign keys die nog niet zouden bestaan.

![Migraties](./images/versioncontrol-xkcd.jpg ':size=70%')

### Eerste migratie

Migrations in Drizzle worden beheerd met behulp van de `drizzle-kit` CLI. We hebben deze al geïnstalleerd als dev dependency en we hebben ook al een `drizzle.config.ts` bestand aangemaakt.

Via de CLI kan je migraties aanmaken en uitvoeren. Laten we een eerste migratie maken om onze `places` tabel aan te maken:

```bash
pnpm drizzle-kit generate
```

Het `generate` commando maakt een nieuwe migratie aan in de `migrations` map. Dit hebben we zo gedefinieerd in de `out` optie in `drizzle.config.ts`. De migratie bevat de nodige SQL-code om de `places` tabel aan te maken. De naam van de migratie is bevat een volgnummer en een paar willekeurige woorden.

Open de migratie en kijk wat Drizzle gegenereerd heeft.

Alvorens we de migratie kunnen uitvoeren, moeten we zeker zijn dat onze `budget` databank bestaat. Drizzle doet dit helaas niet voor ons. Je zou dit kunnen forceren via een migratie maar in productie bestaat de databank altijd als je die via een managed service (op AWS, Azure...) aanmaakt.

Open dus MySQL Workbench en controleer of de `budget` databank bestaat. Mocht je gebruik maken van [Docker Compose](#mysql-in-docker), dan bestaat deze databank reeds. Als je geen Docker gebruikt, moet je een nieuwe databank aanmaken. Uiteraard pas je de naam van de databank aan naar de naam die je gekozen hebt in de `DATABASE_URL` variabele in `.env`.

Deze migratie kan je uitvoeren met het volgende commando:

```bash
pnpm drizzle-kit migrate
```

Controleer in MySQL Workbench of de tabel effectief is aangemaakt. Je zal ook een tabel `__drizzle_migrations` zien. Deze tabel houdt bij welke migraties al uitgevoerd zijn.

Om ons wat typewerk te besparen, voegen we twee scripts toe aan ons `package.json` bestand:

```json
{
  "scripts": {
    "db:generate": "drizzle-kit generate",
    "db:migrate": "drizzle-kit migrate"
  }
}
```

?> Voeg deze scripts toe in het bestaande `scripts` object, niet als nieuw object.

### Metadata migraties

Drizzle maakte ook een `migrations/meta` map aan. Hierin houdt Drizzle in de `xxx_snapshot.json` bestanden bij hoe het databankschema eruit zag na elke migratie. De `xxx` komt overeen met het volgnummer van de migratie waarover de snapshot gaat. Drizzle heeft de snapshots nodig om te bepalen wat er juist veranderd is aan het databankschema om, indien nodig, een nieuwe migratie te maken.

In de `migrations/meta` map vind je ook een `_journal.json` bestand. Dit bevat een object met een oplijsting van alle migraties in volgorde van uitvoering. Drizzle gebruikt dit bestand om te bepalen welke migraties uitgevoerd moeten worden.

### Merge conflicten migraties

Als je met meerdere samenwerkt aan eenzelfde project, kan je wel eens merge conflicten tegenkomen in de `migrations` map. Je lost deze conflicten het eenvoudigst op door de migratie(s) op jouw branch te verwijderen en de inkomende migraties (van bv. de `main` branch) te laten staan.

Hetzelfde geldt voor de bestanden in de `migrations/meta` map: bewaar enkel de inkomende snapshots en journal entries (van bv. de `main` branch).

Nadien kan je simpelweg een nieuwe migratie genereren via `pnpm db:generate`.

Jouw lokale databank zal dan wel inconsistent zijn met de migraties in de `migrations` map. Dat kan je ook simpel oplossen door die te droppen en opnieuw aan te maken.

### drizzle-kit push

De Drizzle kit biedt ook een [`drizzle-kit push`](https://orm.drizzle.team/docs/drizzle-kit-push) commando aan. Dit commando vergelijkt het huidige schema met de databank en past de databank aan om overeen te komen met het schema. Dit commando kan je wel gebruiken in lokaal development om snel wijzigingen door te voeren, maar in productie niet! In productie maak je altijd gebruik van migraties.

## Seeds

Met seeds kan je testdata toevoegen aan een databank. Dit wordt typisch enkel gebruikt in development, niet in testing of production. Let op dat je data in de juiste volgorde toevoegt! In ons geval moeten we eerst de plaatsen toevoegen vooraleer we transacties kunnen toevoegen.

?> Mocht je in productie toch data willen toevoegen, zoals bv. een aantal categorieën van producten in een webshop, dan maak je hiervoor een migratie en geen seed.

Indien je niet zelf de data wil genereren, kan je gebruik maken van de ingebouwde functionaliteit van Drizzle: <https://orm.drizzle.team/docs/seed-overview>. Probeer dit gerust zelf uit in je eigen project (dit is geen extra).

### Seeds in Drizzle

Wij willen iets meer controle over de specifieke data die we toevoegen. Daarom maken we zelf een seed script aan in `src/drizzle/seed.ts`. Dit script doorloopt volgende stappen:

1. Connectie maken met de databank
2. Places toevoegen

Allereerst definiëren we een nieuwe connectie in een bestand `src/drizzle/seed.ts`. Deze connectie is gelijkaardig aan de connectie die we in de `DrizzleModule` hebben gedefinieerd, maar dan zonder NestJS. Op die manier kunnen we dit script ook los van de NestJS applicatie uitvoeren.

```ts
import { drizzle } from 'drizzle-orm/mysql2';
import * as mysql from 'mysql2/promise';
import * as schema from './schema';

const connection = mysql.createPool({
  uri: process.env.DATABASE_URL,
  connectionLimit: 5,
});

const db = drizzle(connection, {
  schema,
  mode: 'default',
});
```

Daarna definiëren we een functie om de databank leeg te maken. We gebruiken hiervoor de [`delete` functie van Drizzle](https://orm.drizzle.team/docs/delete#sql-delete).

```ts
async function resetDatabase() {
  console.log('🗑️ Resetting database...');

  await db.delete(schema.places);

  console.log('✅ Database reset completed\n');
}
```

Vervolgens definiëren we een functie om places toe te voegen. We gebruiken hiervoor de [`insert` functie van Drizzle](https://orm.drizzle.team/docs/insert#sql-insert).

```ts
async function seedPlaces() {
  console.log('📍 Seeding places...');

  await db.insert(schema.places).values([
    {
      id: 1,
      name: 'Loon',
      rating: 5,
    },
    {
      id: 2,
      name: 'Dranken Geers',
      rating: 3,
    },
    {
      id: 3,
      name: 'Irish Pub',
      rating: 4,
    },
  ]);

  console.log('✅ Places seeded successfully\n');
}
```

Tot slot definiëren we een `main` functie die deze functies aanroept:

```ts
async function main() {
  console.log('🌱 Starting database seeding...\n');

  await resetDatabase();
  await seedPlaces();

  console.log('🎉 Database seeding completed successfully!');
}
```

Deze `main` functie voeren we uit. Daarna sluiten we de connectie:

```ts
main()
  .then(async () => {
    await connection.end();
  })
  .catch(async (e) => {
    console.error(e);
    await connection.end();
    process.exit(1);
  });
```

We moeten de functie op deze manier uitvoeren aangezien we geen `await` kunnen gebruiken in de top-level code.

### Seed script uitvoeren

Voeg een nieuw script toe aan je `package.json` bestand:

```json
{
  "scripts": {
    "db:seed": "env-cmd tsx src/drizzle/seed.ts"
  }
}
```

Dit script voert ons seed script uit. We gebruiken `env-cmd` om de environment variabelen uit ons `.env` bestand te laden. We gebruiken `tsx` om TypeScript bestanden rechtstreeks uit te voeren zonder deze eerst te moeten compileren.

Alvorens het script uitgevoerd kan worden, moet je eerst de nodige modules installeren:

```bash
pnpm add -D env-cmd tsx
```

- [**env-cmd**](https://www.npmjs.com/package/env-cmd): een library om environment variabelen in te laden vanuit een bestand
- [**tsx**](https://www.npmjs.com/package/tsx): een runtime om TypeScript bestanden rechtstreeks uit te voeren
  - Merk op: dit kan ook met [**ts-node**](https://www.npmjs.com/package/ts-node), maar `tsx` is sneller en moderner.

Nu kan je het seed script uitvoeren:

```bash
pnpm db:seed
```

Controleer in MySQL Workbench of de data effectief is toegevoegd.

## Opmerking over migrations en seeds

Migrations en seeds moeten steeds vóór de start van de server uitgevoerd worden. Dat geeft een aantal mogelijkheden:

- externe service die hiervoor zorgt
- scripts die uitgevoerd worden voor de server start (voor `pnpm start:dev`)
- de server doet het zelf

Wij kozen voor de tweede optie. Bijgevolg zal je er steeds moeten aan denken om je migraties en seeds uit te voeren alvorens je de server start.

?> **Tip:** documenteer duidelijk in de `README.md` hoe je de server start en welke stappen je moet ondernemen om de databank correct te initialiseren. _Dit is ook één van de ontvankelijkheidscriteria voor de examenopdracht (en wordt vaak verwaarloosd)._

## Oefening - Je eigen project

1. Voeg één tabel (zonder relaties) toe aan je eigen project.
2. Maak een migratie aan en voer deze uit.
3. Maak seeds aan voor de tabel die je in stap 1 hebt gedefinieerd.

## Repository

Een repository is een abstractie voor de datalaag. Het definieert een aantal (CRUD) functies die queries uitvoeren en, indien nodig, de query resultaten omvormen naar OO-objecten. Het is de tussenpersoon tussen domein en databank. Zo zou het "eenvoudig" moeten zijn om te switchen tussen databanken. Dit is eenvoudiger in een taal met interfaces en klassen (bv. TypeScript). [Lees meer over het repository patroon](https://medium.com/@pererikbergman/repository-design-pattern-e28c0f3e4a30)

Het repository patroon is niet altijd nodig. Maak zelf de afweging of de extra laag nut heeft. Een simpel "doorgeefluik" naar de databank heeft geen nut. Dit heeft bv. wel nut indien data omgevormd moet worden. Zorg voor één lijn in een applicatie: ofwel voor alles een repository ofwel voor niets.

Meestal is deze laag niet nuttig bij het gebruik van een ORM want het ORM is zelf de repository. Aangezien wij Drizzle gebruiken, is het niet nodig om een extra repositorylaag te voorzien. Onze lagen zien er dus als volgt uit:

```mermaid
flowchart TD
  A(REST) --> B(Service)
  B --> C(Data)
```

Een pijl van de ene naar de andere laag betekent dat de ene laag de andere laag gebruikt. In dit geval gebruikt de REST-laag de service-laag en de service-laag gebruikt de datalaag. Als je voor een repository zou kiezen, zou de service-laag de repository-laag gebruiken, en de repository-laag de datalaag.

## Services

Nu moeten we enkel nog de Drizzle client gebruiken in onze `PlaceService`. Hiervoor importeren we eerst de `DrizzleModule` in de `PlacesModule`:

```ts
import { Module } from '@nestjs/common';
import { PlaceService } from './place.service';
import { PlaceController } from './place.controller';
import { DrizzleModule } from '../drizzle/drizzle.module'; // 👈

@Module({
  imports: [DrizzleModule], // 👈
  providers: [PlaceService],
  controllers: [PlaceController],
  exports: [PlaceService],
})
export class PlaceModule {}
```

### PlaceService

Daarna kunnen we onze Drizzle provider injecteren in de `PlaceService`. Open `src/places/places.service.ts` en voeg een constructor toe:

```ts
// ...
import {
  type DatabaseProvider,
  InjectDrizzle,
} from '../drizzle/drizzle.provider';

export class PlaceService {
  constructor(
    @InjectDrizzle()
    private readonly db: DatabaseProvider,
  ) {}

  // ...
}
```

Vervolgens passen we de `getAll` methode aan zodat deze Drizzle gebruikt om de places uit de databank op te halen:

```ts
export class PlaceService {
  // ...

  async getAll(): Promise<PlaceListResponseDto> {
    const items = await this.db.query.places.findMany();
    return { items };
  }

  // ...
}
```

!> Merk op dat de functie nu `async` is geworden aangezien we asynchroon data ophalen uit de databank en hiervoor `await` gebruiken.

Hier gebruiken we de ORM interface van Drizzle (via het `query` property). Drizzle voorziet namelijk twee interfaces om queries uit te voeren:

1. een SQL-like interface, zie <https://orm.drizzle.team/docs/select>
2. een ORM interface, zie <https://orm.drizzle.team/docs/rqb>

We gebruiken hier de ORM interface aangezien deze eenvoudiger is voor eenvoudige queries. We halen alle plaatsen op via de `findMany` functie. In sommige gevallen is de ORM interface echter te beperkt en moet je de SQL-like interface gebruiken. Tijdens het programmeren zal je snel merken welke interface je in welk geval het best gebruikt.

De `getAll` methode heeft nu het `async` keyword gekregen, dus we moeten ook de bijhorende methode in de `PlaceController` async maken én het returntype aanpassen:

```ts
export class PlaceController {
  // ...

  async getAllPlaces(): Promise<PlaceListResponseDto> {
    return this.placeService.getAll();
  }

  // ...
}
```

Daarna passen we de `getById` aan:

```ts
// ...
import { eq } from 'drizzle-orm';
import { places } from '../drizzle/schema';

export class PlaceService {
  // ...
  async getById(id: number): Promise<PlaceDetailResponseDto> {
    // 👇 1
    const place = await this.db.query.places.findFirst({
      where: eq(places.id, id), // 👈 2
    });

    // 👇 3
    if (!place) {
      throw new NotFoundException('No place with this id exists');
    }

    // 👇 4
    return place;
  }
  // ...
}
```

1. We halen de eerste plaats op die voldoet aan de `WHERE` clause.
2. We definiëren de `WHERE` clause. We filteren de places tabel op het id dat gelijk is aan de parameter `id`.
   - De `eq` functie komt uit `drizzle-orm` en wordt gebruikt om een vergelijking te maken.
   - `places.id` verwijst naar de `id` kolom uit de `places` tabel.
3. Als geen place gevonden werd, gooien we een `NotFoundException`.
4. We geven de gevonden place terug. Drizzle heeft deze automatisch omgevormd naar een JavaScript object met de juiste opbouw (inclusief relaties).

Maak ook de bijhorende methode in de `PlaceController` async.

Als laatste voorbeeld passen we de `create` methode aan:

```ts
export class PlaceService {
  // ...

  async create(place: CreatePlaceRequestDto): Promise<PlaceResponseDto> {
    const [newPlace] = await this.db
      .insert(places)
      .values(place)
      .$returningId();

    return this.getById(newPlace.id);
  }

  // ...
}
```

In deze methode gebruiken we de SQL-like interface van Drizzle. Je merkt dat de code leest alsof het SQL is, maar dan in JavaScript functies.

We voegen de nieuwe place toe en vragen om het id terug te geven via de `$returningId` functie. De `insert` functie geeft altijd een array terug, we pakken het eerste element hieruit.

Daarna halen we de volledige place op via de `getById` methode zodat we ook de relaties meekrijgen.

Maak uiteindelijk de bijhorende methode in de `PlaceController` async.

#### Oefening - Update en delete place

1. Pas de `update` methode aan zodat deze Drizzle gebruikt om een place te updaten.
   - Gebruik hiervoor de SQL-like interface van Drizzle om de place te updaten.
   - Retourneer de place via de `getById` methode.
2. Pas de `delete` methode aan zodat deze Drizzle gebruikt om een place te verwijderen.
   - Gebruik hiervoor de SQL-like interface van Drizzle om de place te verwijderen.
   - Gooi een `NotFoundException` als de place niet bestaat. Tip: de `delete` methode geeft het aantal verwijderde rijen terug.
   - Retourneer niets.
3. Maak de bijhorende methoden in de `PlaceController` async.

- Oplossing +

  Pas `src/places/places.service.ts` aan:

  ```ts
  export class PlaceService {
    // ...

    async update(
      id: number,
      place: UpdatePlaceRequestDto,
    ): Promise<PlaceResponseDto> {
      await this.db.update(places).set(changes).where(eq(places.id, id));

      return this.getById(id);
    }

    async delete(id: number): Promise<void> {
      const [result] = await this.db.delete(places).where(eq(places.id, id));

      if (result.affectedRows === 0) {
        throw new NotFoundException('No place with this id exists');
      }
    }

    // ...
  }
  ```

### Oefening - Je eigen project

1. Vervolledig de service en controller van de entiteit die je in de vorige oefeningen hebt aangemaakt zodat deze de databank gebruikt i.p.v. mock data.
2. Maak de nodige methoden in de controllers async.
3. Vervolledig je `README.md` met de nodige informatie om de applicatie correct op te starten.

> **Oplossing voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les4-opl e27a0a6
> pnpm install
> docker compose up -d
> pnpm db:migrate
> pnpm db:seed
> pnpm start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.

## Mogelijke extra's voor de examenopdracht

- Gebruik van een ander ORM framework of een querybuilder.
  - We raden niet aan om zelf queries te schrijven, tenzij je écht een goede reden hebt
- Gebruik van een mapper package in de repositorylaag (indien van toepassing).
- Gebruik een ander type databank (column oriented, document based...)
  - Let op: wisselen van MySQL naar bv. PostgreSQL is geen extra. Dit blijft nog steeds hetzelfde type databank.
- Gebruik een package om seed data te genereren, bv. <https://www.npmjs.com/package/faker>.
