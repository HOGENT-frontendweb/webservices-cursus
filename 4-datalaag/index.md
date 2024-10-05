# Datalaag en CRUD

## Startpunt voorbeeldapplicatie

```bash
git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
cd webservices-budget
git checkout -b les4 4e63e94
yarn install
yarn start:dev
```

## Gelaagde architectuur

De **gelaagde architectuur** is een veel gebruikte architectuur waarin code is opgebouwd uit diverse lagen. In de context van het web zijn dit vaak volgende lagen:

- REST API (= presentatielaag)
- Servicelaag (= domeinlaag)
- Repositorylaag (= persistentielaag)
- Datalaag (= persistentielaag)

Veel frameworks zijn opgebouwd rond deze architectuur (Spring, .NET...). In Node.js heb je de keuze, er is geen verplichte structuur.

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
- bv. [Sequelize](https://www.npmjs.com/package/sequelize), [Prisma](https://www.npmjs.com/package/prisma), [TypeORM (enkel voor TypeScript)](https://www.npmjs.com/package/typeorm), [Mongoose (enkel voor MongoDB)](https://www.npmjs.com/package/mongoose)

### Datalaag: wat kiezen we nu?

Wij kiezen voor [Prisma](https://www.npmjs.com/package/prisma), een ORM met native ondersteuning voor TypeScript. In ons voorbeeld hebben we een aantal relaties die we eenvoudig willen opvragen en we hebben geen geavanceerde queries nodig. Prisma is dus een goede keuze voor ons project.

Voel je vrij om voor het project bv. een querybuilder of een ander ORM framework te gebruiken! We raden niet aan om zelf queries te schrijven, tenzij je écht een goede reden hebt.

## Installatie Prisma

?> Onze configuratie is gebaseerd op de officiële [Prisma documentatie](https://www.prisma.io/docs/getting-started/setup-prisma/start-from-scratch/relational-databases-typescript-postgresql). Echter hebben we deze aangepast zodat Prisma mooi in onze gelaagde structuur past. **Het is de bedoeling dat je externe modules altijd degelijk integreert in jouw projectstructuur, dus je hoeft niet noodzakelijk exact de documentatie te volgen.**

We installeren allereerst Prisma en de Prisma client:

```bash
yarn add prisma @prisma/client
```

- [**prisma**](https://www.npmjs.com/package/prisma): CLI voor Prisma, waarmee je de Prisma client kan genereren en migraties kan uitvoeren.
- [**@prisma/client**](https://www.npmjs.com/package/@prisma/client): de Prisma client, die de connectie met de databank afhandelt en waarmee je queries kan uitvoeren.

### Databankschema definiëren

Allereerst moeten we een databankschema definiëren. We laten Prisma dit voor ons doen, we kiezen ook meteen voor MySQL als databank. We initialiseren Prisma met volgend commando:

```bash
yarn prisma init --datasource-provider mysql
```

Als we aan `yarn` een commando/script meegeven dat niet in `package.json` staat, zal `yarn` dit commando uitvoeren alsof het een CLI-commando is. Dit is handig voor packages die geen CLI-commando's hebben. CLI-commando's staan in de `node_modules/.bin` map. `yarn` zal deze automatisch vinden en uitvoeren.

We merken echter dat Prisma ons schema buiten de `src` map plaatst. Dit is niet de bedoeling, we willen alles netjes in onze `src` map houden. We passen dit aan door de `prisma` property toe te voegen aan onze `package.json`:

```json
{
  "prisma": {
    "schema": "src/data/schema.prisma"
  }
}
```

Vervolgens verplaatsen we `schema.prisma` naar `src/data/schema.prisma` en verwijderen we de `prisma` map. We bekijken de inhoud van `schema.prisma`:

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}
```

We zien dat Prisma een `datasource` en een `generator` definieert. De `datasource` bevat de connectiegegevens van de databank. Deze gegevens worden opgehaald uit de environment variabele `DATABASE_URL`. De `generator` definieert de codegenerator die Prisma zal gebruiken om de Prisma client te genereren, in dit geval de JavaScript client.

Vervolgens creëren we het volledige databankschema voor onze budgetapplicatie in `src/data/schema.prisma`:

```prisma
// ...

model Place {
  @@map("places")             // Set the table name to "places"

  id           Int            @id @default(autoincrement()) @db.UnsignedInt
  name         String         @unique(map: "idx_place_name_unique") @db.VarChar(255)
  rating       Int?           @db.UnsignedTinyInt
  transactions Transaction[]
}

model Transaction {
  @@map("transactions") // Set the table name to "transactions"

  id       Int          @id @default(autoincrement()) @db.UnsignedInt
  amount   Int
  date     DateTime     @db.DateTime(0)
  user_id  Int          @db.UnsignedInt
  place_id Int          @db.UnsignedInt
  place   Place         @relation(fields: [place_id], references: [id], onDelete: NoAction, onUpdate: NoAction, map: "fk_transaction_place")
  user    User          @relation(fields: [user_id], references: [id], onDelete: NoAction, onUpdate: NoAction, map: "fk_transaction_user")
}

model User {
  @@map("users")               // Set the table name to "users"

  id            Int            @id @default(autoincrement()) @db.UnsignedInt
  name          String         @db.VarChar(255)
  transactions  Transaction[]
}
```

Zoals je kan zien gebruikt Prisma een zeer leesbare syntax voor het databankschema. Lees zelf eens door het schema en probeer te achterhalen wat Prisma precies zal aanmaken in de databank. Meer informatie over het schema vind je in de [Prisma documentatie](https://www.prisma.io/docs/orm/prisma-schema/overview).

Zoals je ziet definiëren we onze relaties ook in de schema, net alsof we objectgeoriënteerd aan het werk zijn. Prisma zal deze relaties automatisch voor ons afhandelen met bv. een tussentabel voor veel-op-veel relaties, enz.

### Configuratie connectie

Prisma voegde ook reeds variabele `DATABASE_URL` toe aan ons `.env` bestand aan in de root van ons project. We passen deze variabele aan zodat deze overeenkomt met onze databank:

```ini
DATABASE_URL="mysql://<gebruikersnaam>:<wachtwoord>@localhost:3306/budget"
```

!> **Let op:** Het .env bestand mag nooit op GitHub komen! Als je de `.gitignore` uit [hoofdstuk 2](../2-REST_api_intro/index.md#gitignore) correct hebt ingesteld, zal dit bestand niet op GitHub komen.

## Migrations

Vooraleer we queries kunnen uitvoeren op de databank, moeten we hierin eerst de nodige tabellen en relaties definiëren. Dit doen we met behulp van **migrations**. In sommige NoSQL databanken, zoals MongoDB, is dit niet nodig, maar in relationele databanken is dit een must.

Migrations zijn een soort versiebeheersysteem voor de databank. Ze kijken op welke versie het databankschema zit en doen eventueel updates. Ze brengen het databankschema naar een nieuwere versie.

Je kan ook wijzigingen ongedaan maken als er iets fout liep. Dit is zeer belangrijk bij databanken in productie! In development kan je simpelweg de databank droppen en opnieuw maken, dat is geen probleem. Echter is dit not done in productie.

Het is wel belangrijk dat je let op de volgorde van uitvoeren van de migraties om geen problemen te krijgen met bv. foreign keys die nog niet zouden bestaan.

![Migraties](./images/versioncontrol-xkcd.jpg ':size=70%')

### Migrations in Prisma

Prisma heeft een heleboel ingebouwde mechanismen om migraties automatisch uit te voeren. Het enige wat je moet doen is het schema aanpassen en vragen aan Prisma om een migratie te genereren. Prisma zal dan de nodige SQL genereren om de databank up-to-date te brengen.

Wij hebben reeds ons schema gedefinieerd. We kunnen nu een migratie genereren met volgend commando:

```bash
yarn prisma migrate dev --name init
```

Hier maken we een nieuwe migratie aan met de naam `init`. Prisma zal de nodige SQL genereren en deze uitvoeren op de databank. We geven ook de optie `dev` mee, zo weet Prisma dat we in development werken. In development kan je veel meer doen dan in productie, bv. de hele databank droppen en opnieuw maken, in productie is uiteraard dit not done. Later wordt duidelijk hoe je de databank in productie kan updaten.

Als we dit commando zonder de `--name` optie uitvoeren, dan voeren we alle bestaande migraties uit. Dit is handig als je bv. je project op een andere computer wil opzetten.

!> Het is **not done** om migratiebestanden manueel aan te passen! Prisma zal de nodige SQL genereren voor jou. Indien je toch manueel een migratiebestand aanpast, kan Prisma niet meer garanderen dat de databank correct geüpdatet wordt. Dit kan leiden tot corrupte data of zelfs een corrupte databank. Als je een fout maakt, kan je de migratie altijd ongedaan maken en opnieuw genereren..

Na dit commando zal Prisma een map `migrations` aanmaken in de `src/data` map, en zal de databank ook up-to-date zijn. In deze map vind je de gegenereerde SQL-bestanden. Deze bestanden bevatten de SQL die Prisma zonet uitgevoerd heeft op de databank. Je kan deze bestanden bekijken om te zien wat Prisma precies gedaan heeft, of in productie zal doen. Het `migration_lock.toml` bestand bevat het type databank en mag je **niet** aanpassen!

Je merkt dat de naam van de migratie voorafgegaan wordt door een timestamp. Dit is om de volgorde van uitvoeren te garanderen. Prisma voert de migraties uit in alfabetische volgorde.

Wanneer je de databank lokaal eens wil weggooien en opnieuw maken, kan je dit doen met volgend commando:

```bash
yarn prisma migrate reset
```

Neem een kijkje in bv. MySQL Workbench en je zal een volledig afgewerkte `budget` databank zien. Mooi, niet?

Het `migrate` commando zal ook altijd een nieuwe Prisma Client genereren. Dit is de interface die je gebruikt om queries uit te voeren op de databank. Deze client is gegenereerd op basis van het schema dat je hebt gedefinieerd in `schema.prisma`. Het opnieuw genereren is altijd nodig aangezien we nieuwe tabellen of relaties hebben toegevoegd en we de juiste IntelliSense willen via TypeScript.

### Oefening 1 - Je eigen project

1. Installeer Prisma.
2. Genereer een Prisma schema.
3. Definieer al een basis schema voor je eigen project.
4. Genereer een eerste migratie.
5. Controleer of de databank correct geüpdatet is.

?> Het is niet erg als je nog geen idee hebt hoe het volledige schema eruit zal zien. Je kan altijd later nog migraties toevoegen. In principe kan je ook migraties weggooien en opnieuw maken tot zolang je niet in productie draait.

## Seeds

Met seeds kan je testdata toevoegen aan een databank. Dit wordt typisch enkel gebruikt in development, niet in testing of production. Let op dat je data in de juiste volgorde toevoegt! In ons geval moeten we eerst de plaatsen toevoegen vooraleer we transacties kunnen toevoegen.

?> Mocht je in productie toch data willen toevoegen, zoals bv. een aantal categorieën van producten in een webshop, dan maak je hiervoor een migratie en geen seed.

Indien je niet zelf de data wil genereren, kan je gebruik maken van het package [@faker-js/faker](https://github.com/faker-js/faker).

### Seeds in Prisma

Prisma heeft ook ondersteuning voor seeds. Deze seeds worden uitgevoerd na de migraties. We moeten enkel in de `package.json` aangeven hoe Prisma de seeds kan uitvoeren. We voegen een `seed` property toe aan de `prisma` property:

```json
{
  "prisma": {
    "schema": "src/data/schema.prisma",
    "seed": "tsx ./src/data/seed.ts"
  }
}
```

In dit geval zeggen we dat het bestand `src/data/seed.ts` uitgevoerd moet worden door `tsx`. We maken dit bestand aan:

```ts
// src/data/seed.ts
import { PrismaClient } from '@prisma/client'; // 👈 1

const prisma = new PrismaClient(); // 👈 1

// 👇 2
async function main() {
  // Seed users
  // ==========
  await prisma.user.createMany({
    data: [
      {
        id: 1,
        name: 'Thomas Aelbrecht',
      },
      {
        id: 2,
        name: 'Pieter Van Der Helst',
      },
      {
        id: 3,
        name: 'Karine Samyn',
      },
    ],
  });

  // Seed places
  // ===========
  await prisma.place.createMany({
    data: [
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
    ],
  });

  // Seed transactions
  // =================
  await prisma.transaction.createMany({
    data: [
      // User Thomas
      // ===========
      {
        id: 1,
        user_id: 1,
        place_id: 1,
        amount: 3500,
        date: new Date(2021, 4, 25, 19, 40),
      },
      {
        id: 2,
        user_id: 1,
        place_id: 2,
        amount: -220,
        date: new Date(2021, 4, 8, 20, 0),
      },
      {
        id: 3,
        user_id: 1,
        place_id: 3,
        amount: -74,
        date: new Date(2021, 4, 21, 14, 30),
      },
      // User Pieter
      // ===========
      {
        id: 4,
        user_id: 2,
        place_id: 1,
        amount: 4000,
        date: new Date(2021, 4, 25, 19, 40),
      },
      {
        id: 5,
        user_id: 2,
        place_id: 2,
        amount: -220,
        date: new Date(2021, 4, 9, 23, 0),
      },
      {
        id: 6,
        user_id: 2,
        place_id: 3,
        amount: -74,
        date: new Date(2021, 4, 22, 12, 0),
      },
      // User Karine
      // ===========
      {
        id: 7,
        user_id: 3,
        place_id: 1,
        amount: 4000,
        date: new Date(2021, 4, 25, 19, 40),
      },
      {
        id: 8,
        user_id: 3,
        place_id: 2,
        amount: -220,
        date: new Date(2021, 4, 10, 10, 0),
      },
      {
        id: 9,
        user_id: 3,
        place_id: 3,
        amount: -74,
        date: new Date(2021, 4, 19, 11, 30),
      },
    ],
  });
}

// 👇 3
main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
```

1. We importeren de Prisma client en maken een instantie aan.
2. We definiëren een `main` functie die de seeding zal uitvoeren. We seeden eerst de gebruikers, dan de plaatsen en tenslotte de transacties.
   - We maken hier gebruik van de Prisma client. Deze heeft één property per tabel, in dit geval `user`, `place` en `transaction`. Deze properties hebben functies zoals `createMany` om meerdere records toe te voegen.
   - Je zal merken dat Prisma suggesties geeft voor de velden die je kan invullen. Dit is de IntelliSense die we eerder vermeld hebben.
3. We roepen de `main` functie aan en sluiten de connectie met de databank af na het uitvoeren van de seeding of bij een fout.

Nu kunnen we onze seeds uitvoeren met volgend commando:

```bash
yarn prisma db seed
```

### Opmerking over migrations en seeds uitvoeren

Migrations en seeds moeten steeds vóór de start van de server uitgevoerd worden. Dat geeft een aantal mogelijkheden:

- externe service die hiervoor zorgt
- scripts die uitgevoerd worden voor de server start (voor `yarn start`)
- de server doet het zelf

Wij kozen voor de tweede optie. Bijgevolg zal je er steeds moeten aan denken om je migraties en seeds uit te voeren alvorens je de server start.

?> **Tip:** documenteer duidelijk in de `README.md` hoe je de server start en welke stappen je moet ondernemen om de databank correct te initialiseren. _Dit is ook één van de minimumvereisten voor de examenopdracht (en wordt vaak verwaarloosd)._

### Oefening 2 - Je eigen project

1. Configureer seeding voor je eigen project.
2. Maak seeds aan voor alle tabellen die je in de vorige oefening hebt gedefinieerd.

## Datalaag finaliseren

Nu rest ons enkel nog een module te maken voor onze datalaag. Maak in de map `data` een bestand `index.ts` aan met volgende inhoud:

```ts
// src/data/index.ts
import { PrismaClient } from '@prisma/client'; // 👈 1
import { getLogger } from '../core/logging';

export const prisma = new PrismaClient(); // 👈 1

// 👇 2
export async function initializeData(): Promise<void> {
  getLogger().info('Initializing connection to the database');

  await prisma.$connect();

  getLogger().info('Successfully connected to the database');
}

// 👇 3
export async function shutdownData(): Promise<void> {
  getLogger().info('Shutting down database connection');

  await prisma?.$disconnect();

  getLogger().info('Database connection closed');
}
```

1. Importeer de Prisma client en maak een instantie aan. Het is belangrijk dat we slechts één instantie hebben van de Prisma client. Per instantie die je aanmaakt wordt een nieuwe pool van connecties aangemaakt. Dit kan leiden tot een overbelasting van de databank of de webserver.
   - We exporteren de instantie zodat we deze kunnen gebruiken in andere modules.
   - We gebruiken hier het [singleton](https://refactoring.guru/design-patterns/singleton) patroon.
2. We definiëren een functie waarin we de connectie effectief maken. We loggen ook dat de connectie succesvol is.
   - Deze functie heeft `Promise<void>` als return type. De functie geeft nl. niets terug en is asynchroon. Door het feit dat de functie asynchroon is, kunnen we niet gewoon `: void` gebruiken.
   - Een client aanmaken legt nl. niet meteen een connectie met de databank. Die wordt pas gemaakt als ze écht nodig is.
3. We definiëren een functie om de connectie af te sluiten. We loggen ook dat de connectie succesvol is afgesloten.
   - Dit is nodig aangezien Node.js niet zal afsluiten zolang er nog open connecties zijn.

Nu dienen we de `initializeData` aan te roepen in ons opstartscript. Pas hiervoor `src/index.ts` aan:

```ts
// andere imports
import { initializeData } from './data'; // 👈 1
// configuratie

// 👇 2
async function main(): Promise<void> {
  // middlewares

  await initializeData(); // 👈 4

  // rest laag + listen
}
main(); // 👈 3
```

1. We importeren de `initializeData` functie in ons opstartscript.
2. Wrap alle code uit dit bestand (behalve imports en configuratie) in een `async main` functie. We mogen nl. geen `await` doen buiten een `async` functie.
3. Roep deze functie vervolgens aan.
4. Initialiseer de datalaag na het toevoegen van de middlewares aan de Koa app.

### Oefening 3 - Je eigen project

Voeg de Prisma client toe aan je eigen project.

## Repository

Een repository is een abstractie voor de datalaag. Het definieert een aantal (CRUD) functies die queries uitvoeren en, indien nodig, de query resultaten omvormen naar OO-objecten. Het is de tussenpersoon tussen domein en databank. Zo is het "eenvoudig" om te switchen tussen databanken. Dit is eenvoudiger in een taal met interfaces en klassen (bv. TypeScript). [Lees meer over het repository patroon](https://medium.com/@pererikbergman/repository-design-pattern-e28c0f3e4a30)

Het repository patroon is niet altijd nodig. Maak zelf de afweging of de extra laag nut heeft. Een simpel "doorgeefluik" naar de databank heeft geen nut. Dit heeft bv. wel nut indien data omgevormd moet worden. Zorg voor één lijn in een applicatie: ofwel voor alles een repository ofwel voor niets.

Meestal is deze laag niet nuttig bij het gebruik van een ORM want het ORM is zelf de repository. Aangezien wij Prisma gebruiken, is het niet nodig om een extra repositorylaag te voorzien.

## Services

Nu moeten we enkel nog de Prisma client gebruiken in onze services.

### Places

We passen allereerst de `src/service/place.ts` aan:

```ts
import { prisma } from '../data'; // 👈 1

// 👇 3
export const getAll = async () => {
  return prisma.place.findMany(); // 👈 2
};
```

1. Importeer de Prisma client.
2. Vraag alle plaatsen op via de Prisma client.
3. Aangezien deze functie nu een Promise teruggeeft, maken we deze ook async.
   - Je kan ook `return await` doen, maar dat is vrij zinloos als je niets met het resultaat van de Promise doet.

Doordat deze functie async geworden is dienen we de REST-laag ook aan te passen. Voorlopig halen we simpelweg de lijst van places op in onze handler voor `GET /api/places`, maar deze functie is async geworden. Vergeet dus niet om await toe te voegen in `src/rest/place.ts` of je zal geen correct antwoord krijgen!

```ts
// ...

const getAllPlaces = async (ctx: Context) => {
  const places = await placeService.getAll();
  ctx.body = {
    items: places,
  };
};
// ...
```

De andere functies in de service kan je op dezelfde manier aanpassen:

```ts
// ...
export const getById = async (id: number) => {
  const place = await prisma.place.findUnique({
    where: {
      id,
    },
    include: {
      transactions: {
        select: {
          id: true,
          amount: true,
          date: true,
          place: true,
          user: true,
        },
      },
    },
  });

  if (!place) {
    throw new Error('No place with this id exists');
  }

  return place;
};

export const create = async ({ name, rating }: any) => {
  return prisma.place.create({
    data: {
      name,
      rating,
    },
  });
};

export const updateById = async (id: number, { name, rating }: any) => {
  return prisma.place.update({
    where: {
      id,
    },
    data: {
      name,
      rating,
    },
  });
};

export const deleteById = async (id: number) => {
  await prisma.place.delete({
    where: {
      id,
    },
  });
};
```

Merk op dat we een fout gooien als de place niet bestaat. Na deze aanpassingen kan je de import van de mock data verwijderen, en moet je de REST-laag verder aanpassen zodat de CRUD endpoints ook beschikbaar zijn (werk met `await`).

Controleer of elk endpoint van de places correct werkt.

### Transactions

Tot nu toe hebben we enkel data uit dezelfde tabel opgevraagd. Als alle services enkel uit "hun" tabel data ophalen, dan is het een vrij nutteloze service- of domeinlaag.

We passen de functie `getAll` in `src/service/transaction.ts` aan:

```ts
// 👇 1
const TRANSACTION_SELECT = {
  id: true,
  amount: true,
  date: true,
  place: true,
  user: {
    select: {
      id: true,
      name: true,
    },
  },
};

export const getAll = async () => {
  // 👇 2
  return prisma.transaction.findMany({
    select: TRANSACTION_SELECT,
  });
};
```

1. We definiëren een object `TRANSACTION_SELECT` dat aangeeft welke velden we willen selecteren. We kunnen dit later hergebruiken bij de `getById` functie.
   - We selecteren alles van een transactie, en we halen de place en user op. We selecteren enkel de `id` en `name` van de user.
   - Later komen nog extra attributen (voor authenticatie/autorisatie) in de user, die willen we hier niet selecteren.
2. Vervolgens geven we dit object mee aan de `findMany` functie.
   - Vergeet niet om `await` toe te voegen in de REST-laag.

Controleer of je het juiste antwoord krijgt bij het ophalen van alle transacties.

Pas de overige functies zelf aan.

### Oefening 4 - Je eigen project

Pas de service- en REST-laag aan in je eigen project zodat nu de databank gebruikt wordt.

## Types toevoegen aan services

Vervolgens voegen we types toe aan onze services. Op deze manier zijn we altijd zeker van het type van de data die we binnenkrijgen als argument en het type van de data die we teruggeven.

Maak een map `types` aan in de `src` map. Aangezien elke entiteit in onze databank een `id` heeft, maken we een bestand `common.ts` aan in deze map:

```ts
// src/types/common.ts
export interface Entity {
  id: number;
}
```

Voeg hierin een bestand `place.ts` toe. Daarin definiëren we het type van een plaats. We erven van `Entity`, zo krijg elke plaats ook een `id`. We voegen `null` toe aan de rating aangezien dit optioneel is.

```ts
// src/types/place.ts
import type { Entity } from './common';

export interface Place extends Entity {
  name: string;
  rating: number | null;
}
```

Vervolgens definiëren we het type voor een gebruiker in `user.ts`:

```ts
// src/types/user.ts
import type { Entity } from './common';

export interface User extends Entity {
  name: string;
}
```

Als laatste definiëren we het type voor een transactie in `transaction.ts`:

```ts
// src/types/transaction.ts
import type { Entity } from './common';
import type { Place } from './place';
import type { User } from './user';

export interface Transaction extends Entity {
  amount: number;
  date: Date;
  user: Pick<User, 'id' | 'name'>;
  place: Pick<Place, 'id' | 'name'>;
}
```

Hier maken we gebruik van `Pick`, een ingebouwd type in TypeScript. Dit type laat ons toe om enkel bepaalde velden van een type te selecteren. In dit geval willen we enkel de `id` en `name` van de user en de place. Je geeft de verschillende velden mee als string gescheiden door een `|`.

Vervolgens passen we de services aan zodat ze deze types gebruiken:

```ts
// src/service/place.ts

export const getAll = async (): Promise<Place[]> => {
  // ...
};

export const getById = async (id: number): Promise<Place> => {
  // ...
};

export const deleteById = async (id: number): Promise<void> => {
  // ...
};
```

Aangezien alle functies asynchroon zijn, voegen we `Promise` toe aan de return types.

1. De `getAll` functie geeft een array van `Place` objecten terug.
2. De `getById` functie geeft een `Place` object terug.
3. De `deleteById` functie geeft niets terug, dus `void`.

Vervolgens definiëren we de types voor de parameters van de `create` en `updateById` functies:

```ts
// src/types/place.ts
// ...

export interface PlaceCreateInput {
  name: string;
  rating: number | null;
}

export interface PlaceUpdateInput extends PlaceCreateInput {}
```

We definiëren een `PlaceCreateInput` en `PlaceUpdateInput` interface. De `PlaceUpdateInput` interface erft van de `PlaceCreateInput` interface. We kiezen er ook voor om alle velden voor de `PlaceCreateInput` interface opnieuw te definiëren. Je zou dit ook kunnen hergebruiken van een `Place` interface, maar dit is minder flexibel.

Vervolgens passen we de `create` en `updateById` functies aan in de `src/service/place.ts`:

```ts
// src/service/place.ts
export const create = async (place: PlaceCreateInput): Promise<Place> => {
  return prisma.place.create({
    data: place,
  });
};

export const updateById = async (
  id: number,
  changes: PlaceUpdateInput,
): Promise<Place> => {
  return prisma.place.update({
    where: {
      id,
    },
    data: changes,
  });
};
```

Analoog kan je de types toevoegen voor een transactie en een gebruiker.

### Oefening 5 - Je eigen project

1. Voeg types toe aan je eigen project.
2. Gebruik deze types in je services.

## Types toevoegen aan REST

Als laatste voegen we types toe aan onze REST-laag. Dit is de laatste laag waar we nog geen types hebben toegevoegd.

We breiden onze gemeenschappelijke types uit met een `ListResponse` en een `IdParams` interface:

```ts
// src/types/common.ts
// ...

export interface ListResponse<T> {
  items: T[];
}

export interface IdParams {
  id: number;
}
```

De `ListResponse` interface bevat een array van items van een bepaald type. Dat type geven we mee als parameter `T` van het generieke type. De `IdParams` interface bevat een enkel veld `id` van het type `number`. Dit hergebruiken we later aangezien we vaak enkel een id nodig hebben als parameter.

Vervolgens passen we de types aan in de `src/rest/place.ts`:

```ts
// src/types/place.ts
import type { Entity, ListResponse } from './common';

// ...

export interface CreatePlaceRequest extends PlaceCreateInput {}
export interface UpdatePlaceRequest extends PlaceUpdateInput {}

export interface GetAllPlacesResponse extends ListResponse<Place> {}
export interface GetPlaceByIdResponse extends Place {}
export interface CreatePlaceResponse extends GetPlaceByIdResponse {}
export interface UpdatePlaceResponse extends GetPlaceByIdResponse {}
```

We voegen enkel types toe voor requests die effectief data doorgeven en responses die data teruggeven:

- `CreatePlaceRequest` en `UpdatePlaceRequest` zijn de types voor de request bodies van de `POST` en `PUT` requests.
- `GetAllPlacesResponse` is de response voor de `GET` request die alle places opvraagt.
- `GetPlaceByIdResponse`, `CreatePlaceResponse` en `UpdatePlaceResponse` zijn de responses voor de `GET`, `POST` en `PUT` requests die een enkele plaats opvragen/aanmaken/aanpassen.

Vervolgens voegen we enkele types toe voor Koa. Maak een nieuw bestand `koa.ts` aan in de `src/types` map:

```ts
// src/types/koa.ts
import type { ParameterizedContext } from 'koa';
import type { SessionInfo } from '.';
import type Application from 'koa';
import type Router from '@koa/router';

// 👇 1
export interface BudgetAppState {
  session: SessionInfo;
}

// 👇 2
export interface BudgetAppContext<
  Params = unknown,
  RequestBody = unknown,
  Query = unknown,
> {
  request: {
    body: RequestBody;
    query: Query;
  };
  params: Params;
}

// 👇 3
export type KoaContext<
  ResponseBody = unknown,
  Params = unknown,
  RequestBody = unknown,
  Query = unknown,
> = ParameterizedContext<
  // 👇 4
  BudgetAppState,
  BudgetAppContext<Params, RequestBody, Query>,
  ResponseBody
>;

// 👇 5
export interface KoaApplication
  extends Application<BudgetAppState, BudgetAppContext> {}

// 👇 5
export interface KoaRouter extends Router<BudgetAppState, BudgetAppContext> {}
```

1. We definiëren een `BudgetAppState` interface. State is één van de properties uit de Koa context. Momenteel hebben we nog geen state, dus laten we de interface leeg.
2. Daarnaast kan je ook de Koa context uitbreiden met extra properties. We definiëren hiervoor een `BudgetAppContext` interface. Deze interface ontvangt drie types als parameters:
   - `Params`: het type van de parameters uit de URL
   - `RequestBody`: het type van de HTTP request body
   - `Query`: het type van de query parameters uit het HTTP request
   - Deze parameters hebben allemaal standaard het type `unknown`. Dit betekent dat we de waarde niet weten. Je bent dus verplicht een type op te geven als je hiermee werkt.
3. Vervolgens definiëren we een eigen type voor de Koa context. We geven hier een extra type parameter `ResponseBody` mee, het type van de HTTP response body. De overige parametertypes hebben dezelfde functie als in de `BudgetAppContext` interface.
4. Koa voorziet een `ParameterizedContext` waarmee je de context kan typeren. Deze interface verwacht drie type parameters: de state, de context en de response body. We geven onze `BudgetAppState` en `BudgetAppContext` interfaces mee als state en context. De response body vullen we in met het generieke type `ResponseBody`.
5. Als laatste definiëren we onze eigen types voor de Koa applicatie en router. Deze interfaces zijn een extensie van de standaard Koa interfaces. We geven onze `BudgetAppState` en `BudgetAppContext` interfaces mee als extra types.

Nu kunnen we deze types gebruiken in onze REST-laag. Pas de `src/rest/place.ts` aan:

```ts
// src/rest/place.ts
// ...
import type { BudgetAppContext, BudgetAppState } from '../types/koa';
import type { KoaContext, KoaRouter } from '../types/koa';
import type {
  CreatePlaceRequest,
  CreatePlaceResponse,
  GetAllPlacesResponse,
  GetPlaceByIdResponse,
  UpdatePlaceRequest,
  UpdatePlaceResponse,
} from '../types/place';
import type { IdParams } from '../types/common';

// 👇 1
const getAllPlaces = async (ctx: KoaContext<GetAllPlacesResponse>) => {
  // ...
};

// 👇 2
const getPlaceById = async (
  ctx: KoaContext<GetPlaceByIdResponse, IdParams>,
) => {
  // ...
};

// 👇 3
const createPlace = async (
  ctx: KoaContext<CreatePlaceResponse, void, CreatePlaceRequest>,
) => {
  // ...
};

// 👇 4
const updatePlace = async (
  ctx: KoaContext<UpdatePlaceResponse, IdParams, UpdatePlaceRequest>,
) => {
  // ...
};

// 👇 5
const deletePlace = async (ctx: KoaContext<void, IdParams>) => {
  // ...
};

// 👇 6
const getTransactionsByPlaceId = async (
  ctx: KoaContext<GetAllTransactionsResponse, IdParams>,
) => {
  // ...
};

// 👇 7
export default (parent: KoaRouter) => {
  const router = new Router<BudgetAppState, BudgetAppContext>({
    prefix: '/places',
  });
  // ...
};
```

1. We vervangen de `Context` type door onze eigen `KoaContext` type. We geven ook het type van de response mee, in dit geval `GetAllPlacesResponse`.
2. We geven ook het type van de parameters mee aan de `getPlaceById` functie. We verwachten een `IdParams` object als parameters in de URL.
3. De `createPlace` functie verwacht geen parameters in de URL, maar wel een `CreatePlaceRequest` object in de body van de request.
4. De `updatePlace` functie verwacht een `IdParams` object in de URL en een `UpdatePlaceRequest` object in de body van de request.
5. De `deletePlace` functie geeft niets terug en verwacht enkel een `IdParams` object in de URL.
6. De `getTransactionsByPlaceId` geeft een lijst van transacties terug en ontvangt een `IdParams` object in de URL.
   - Probeer zelf de interface `GetAllTransactionsResponse` te schrijven in `src/types/transaction.ts`. Maak hierbij gebruik van de `ListResponse`.
7. We gebruiken ook ons eigen `KoaRouter` type in plaats van de standaard Koa router.
   - We geven hier ook onze `BudgetAppState` en `BudgetAppContext` interfaces mee als extra types aan de Koa router.

Analoog kan je de types toevoegen voor de andere routes in de REST-laag.

Als laatste moeten we enkel nog onze state en context types toevoegen aan de algemene router in `src/rest/index.ts`:

```ts
// ...
import type {
  BudgetAppContext,
  BudgetAppState,
  KoaApplication,
} from '../types/koa';

// 👇
export default (app: KoaApplication) => {
  // 👇
  const router = new Router<BudgetAppState, BudgetAppContext>({
    prefix: '/api',
  });

  // ...
};
```

En ook nog in de `src/index.ts`:

```ts
// ..
import type { BudgetAppContext, BudgetAppState } from './types/koa';

async function main(): Promise<void> {
  const app = new Koa<BudgetAppState, BudgetAppContext>();

  // ...
}
main();
```

Nu is onze applicatie volledig voorzien van de nodige types. Hier en daar moeten we nog een paar types finetunen, maar dat is voor later.

### Oefening 6 - Je eigen project

1. Voeg request/response types toe aan je eigen project.
2. Gebruik deze types in je REST.
3. Vervolledig je repositories en services in je project met alle benodigde CRUD-operaties.
4. Vervolledig ook de migrations en seeds.
5. Vervolledig je `README.md` met de nodige informatie om de applicatie correct op te starten.

## Oplossing voorbeeldapplicatie

```bash
git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
cd webservices-budget
git checkout -b les4-opl 0eca476
yarn install
yarn start:dev
```

## Mogelijke extra's voor de examenopdracht

- Gebruik van een ander ORM framework of een querybuilder.
  - We raden niet aan om zelf queries te schrijven, tenzij je écht een goede reden hebt
- Gebruik van een mapper package in de repositorylaag (indien van toepassing).
- Gebruik de [Node TypeScript Architecture](https://github.com/jbreckmckye/node-typescript-architecture).
