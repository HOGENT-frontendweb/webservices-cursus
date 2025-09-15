# Datalaag en CRUD (WIP)

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les4 TODO:
> yarn install
> yarn start:dev
> ```

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
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: budget
      MYSQL_USER: devusr
      MYSQL_PASSWORD: devpwd
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "--silent"]
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

### Environment variabele `DATABASE_URL`

We gaan de url naar onze databank niet hardcoderen. Dit maakt het moeilijk om aan te passen en zorgt ervoor dat productiecredentials mogelijk in de broncode terechtkomen.

Daarom voegen we in het `.env` bestand in de root van ons project de connectiestring toe via de variabele `DATABASE_URL`:

```ini
NODE_ENV=development
DATABASE_URL=mysql://<gebruikersnaam>:<wachtwoord>@localhost:3306/budget
```

Als je geen gebruik maakt van een lokale MySQL server, maar van een Docker container, gebruik dan de credentials die je in het `docker-compose.yml` bestand hebt opgegeven. In dat geval wordt dit je `.env` bestand:

```ini
NODE_ENV=development
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

<!-- TODO: hier verder gaan -->

### Drizzle connectie als provider

In NestJS wordt de connectie met de databank best als provider aangeboden. Op die manier zijn we zeker dat er slechts één connectie is in de volledige applicatie. We maken hiervoor een `drizzle` module aan:

```bash
nest generate module drizzle
```

Dit genereert een bestand `src/drizzle/drizzle.module.ts` met onze DrizzleModule.

Lees eerst de sectie rond [Async providers](https://docs.nestjs.com/fundamentals/async-providers).

Vervolgens definiëren we onze async provider in een bestand `src/drizzle/drizzle.provider.ts`. Maak dit bestand en definieer een contanste met de sleutel van de provider. Op basis van deze sleutel kunnen we de provider later injecteren in bv. onze services.

```ts
export const DrizzleAsyncProvider = 'DrizzleAsyncProvider';
```

Daaronder definiëren we onze Drizzle connectie die we aanbieden als async provider met deze sleutel:

<!-- TODO: zijn er al types voor de configuratie? -->

```ts
import { ConfigService } from '@nestjs/config';
import { drizzle, MySql2Database } from 'drizzle-orm/mysql2';
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

Importeer `Inject` uit het `@nestjs/common` package.

Opdat we onze provider kunnen gebruiken, definiëren we deze als provider en export in onze `DrizzleModule`:

```ts
import { Module } from '@nestjs/common';
import {
  DrizzleAsyncProvider,
  drizzleProvider,
} from './drizzle.provider';

@Module({
  providers: [...drizzleProvider], // 👈
  exports: [DrizzleAsyncProvider], // 👈
})
export class DrizzleModule {}
```

## Databankschema definiëren

Nu definiëren we ons schema in `src/drizzle/schema.ts`. Allereerst maken we de places tabel uit een vorig hoofdstuk:

```ts
export const places = mysqlTable(
  'places',
  {
    id: int('id', { unsigned: true }).primaryKey().autoincrement(),
    name: varchar('name', { length: 255 }).notNull(),
    rating: tinyint('rating', { unsigned: true }),
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

We definiëren een type `DatabaseProvider` van het type `MySql2Database`. Aan `MySql2Database` geven we het type van ons schema door via `typeof`. We breiden het type uit met een `$client` optie zodat we later onze connectie kunnen sluiten.

## Connectie afsluiten

Opdat onze NestJS server correct afsluit, moeten we onze databankconnectie sluiten als de NestJS server afgesloten wordt. NestJS biedt een aantal lifecycle events aan zodat je kan inhaken op gebeurtenissen in de applicatie.

Lees eerst de [documentatie over lifecycle events](https://docs.nestjs.com/fundamentals/lifecycle-events).

```ts
import { Module, OnModuleDestroy } from '@nestjs/common'; // 👈 1
import {
  DrizzleAsyncProvider,
  drizzleProvider,
  DatabaseProvider,
  InjectDrizzle,
} from './drizzle.provider';

@Module({
  providers: [...drizzleProvider],
  exports: [DrizzleAsyncProvider],
})
export class DrizzleModule implements OnModuleDestroy { // 👈 1
  constructor(@InjectDrizzle() private readonly db: DatabaseProvider) {} // 👈 3

  // 👇 2
  async onModuleDestroy() {
    await this.db.$client.end(); // 👈 4
  }
}
```

1. Laat de `DrizzleModule` de interface `OnModuleDestroy` implementeren.
2. Definieer een `onModuleDestroy` functie.
3. Injecteer onze Drizzle provider.
4. Sluit de connectie als deze module afgebroken wordt.

## Migrations

Vooraleer we queries kunnen uitvoeren op de databank, moeten we hierin eerst de nodige tabellen en relaties definiëren. Dit doen we met behulp van **migrations**. In sommige NoSQL databanken, zoals MongoDB, is dit niet nodig, maar in relationele databanken is dit een must.

Migrations zijn een soort versiebeheersysteem voor de databank. Ze kijken op welke versie het databankschema zit en doen eventueel updates. Ze brengen het databankschema naar een nieuwere versie.

Je kan ook wijzigingen ongedaan maken als er iets fout liep. Dit is zeer belangrijk bij databanken in productie! In development kan je simpelweg de databank droppen en opnieuw maken, dat is geen probleem. Echter is dit not done in productie.

Het is wel belangrijk dat je let op de volgorde van uitvoeren van de migraties om geen problemen te krijgen met bv. foreign keys die nog niet zouden bestaan.

![Migraties](./images/versioncontrol-xkcd.jpg ':size=70%')
