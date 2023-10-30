# Datalaag en CRUD

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-Web/webservices-budget.git
> cd webservices-budget
> git checkout -b les4 f6afd9b
> yarn install
> yarn start
> ```

**Voer [dit SQL-script uit](./data/budget.sql ':ignore').** Zonder dit script kan je geen queries uitvoeren tot het einde van dit hoofdstuk.

## Gelaagde architectuur

De **gelaagde architectuur** is een veel gebruikte architectuur waarin code is opgebouwd uit diverse lagen. In de context van het web zijn dit vaak volgende lagen:

- REST API
- Servicelaag
- Repositorylaag (optioneel indien je gebruik maakt van ORM)
- Datalaag

Veel frameworks zijn opgebouwd rond deze architectuur (Spring, .NET...). In NodeJS heb je de keuze, er is geen verplichte structuur.

Een alternatieve structuur, veel gebruikt bij microservices, is de [**hexagonale structuur**](https://medium.com/idealo-tech-blog/hexagonal-ports-adapters-architecture-e3617bcf00a0). Een mooie (maar complexe) implementatie in Node.js (en TypeScript) vind je hier: <https://github.com/jbreckmckye/node-typescript-architecture>.

Dit hoofdstuk focust op de twee onderste lagen: **data-** en **repositorylaag**.

## Datalaag

De datalaag is een typische laag in de gelaagde architectuur voor het web. Het handelt de communicatie met de databank af:

- connectie opzetten, onderhouden en afsluiten indien nodig.
- databank aanmaken en up-to-date houden (= migraties).
- In development: seeden (= vullen) van de database met testdata.
- CRUD-operaties: dit wordt vaak afgehandeld door een framework dat een soort repository-interface beschikbaar maakt, maar DIY kan ook.

Er zijn een aantal mogelijkheden om de datalaag te implementeren:

- zelf queries schrijven
- querybuilder
- Object Relational Mapper (ORM)

### Datalaag: zelf queries schrijven

Dit is waarschijnlijk de eerste mogelijkheid die in je opkomt wanneer je data moet ophalen in een applicatie. Het is zeker geen slecht idee, in de juiste context. Het zelf schrijven van queries is altijd een mogelijkheid maar het geeft je meestal meer werk dan nodig is om de code te onderhouden of om bepaalde zaken te implementeren.

In deze mogelijkheid schrijf je zelf queries in string-vorm (in JavaScript) die je vervolgens doorgeeft aan een bepaalde client die voor jou de query naar de databank zal sturen en je het antwoord teruggeeft. Deze queries kunnen placeholders bevatten voor bepaalde parameters (bv. WHERE-clauses of INSERT-queries). Hierbij handelt de client meestal SQL injection af. Gebruik je totaal geen client? Dan moet je zelf opletten voor SQL injection. Daarnaast geven deze clients vaak het pure resultaat terug zoals het van de query engine terugkwam, het is dus aan de developer om deze data te mappen naar het juiste formaat.

Dit is een mogelijkheid die heel geschikt is voor een kleine applicatie die weinig speciaals vereist van de databank, typische een applicatie met weinig tot geen relaties en/of CUD-queries. Nee, dit is geen schrijffout: weinig tot geen Create, Update of Delete queries. Indien de applicatie meer relaties krijgt en complexere tabellen, wordt het al gauw moeilijk om zelf geschreven queries te onderhouden.

#### Samengevat

- (grondige) kennis van SQL vereist
- queries in string-vorm
- je krijgt pure resultaten uit de databank terug (relaties zelf groeperen in aggregaten...)
- ideaal voor kleine applicaties
- bv. [mysql](https://www.npmjs.com/package/mysql),[pg](https://www.npmjs.com/package/pg), [mongodb](https://www.npmjs.com/package/mongodb), [redis](https://www.npmjs.com/package/redis):

### Datalaag: querybuilder

Een tweede optie is om de queries dynamisch te laten opbouwen door een bepaald framework. Hierbij vermijd je dat je zelf queries moet schrijven en onderhouden, het framework zal dit voor jou afhandelen. Daarbij krijg je ook gratis en voor niets bescherming tegen SQL injection bij deze frameworks.

Afhankelijk van het gekozen framework zijn relaties al dan niet ondersteund. Echter blijft de ondersteuning beperkt aangezien deze frameworks focussen op het bouwen van queries en niet op het eenvoudig maken van bepaalde OO-concepten in databanken. Vaak moet je dus zelf nog je relaties (en bijbehorende referentiële integriteit) afhandelen om een consistente databank te hebben.

Een heel bekende querybuilder voor NodeJS is [knex.js](https://www.npmjs.com/package/knex). Het biedt een eenvoudige interface m.b.v. het [builder patroon](https://refactoring.guru/design-patterns/builder) en heeft native ondersteuning voor async/await.

Om een meer OO-aanpak te krijgen, kan je gebruik maken van [objection.js](https://www.npmjs.com/package/objection). Objection laat je toe om eenvoudig en automatisch relaties op te halen. Er is ook ondersteuning voor CUD-operaties voor relaties, maar de documentatie raadt af om deze intensief te gebruiken.

#### Samengevat

- dynamisch queries opbouwen
- soms ondersteuning voor eenvoudig gebruik van relaties
- nog steeds kennis van SQL vereist
- bv. [knex.js](https://www.npmjs.com/package/knex) of [objection.js](https://www.npmjs.com/package/objection)

### Datalaag: Object Relational Mapper (ORM)

Dit is de meest eenvoudige aanpak voor ontwikkelaars die geen of beperkte kennis hebben van SQL en databankontwerp. Een ORM neemt de noodzaak van SQL-kennis weg en zal zelf queries genereren om data op te halen. Het enige wat een ORM moet weten is hoe het databankschema eruit ziet. Hierbij kan de ontwikkelaar gebruik maken van alle OO-concepten, het ORM zal ervoor zorgen dat de gegeven data weggeschreven kan worden naar de databank. Dat is letterlijk wat de naam beschrijft: Object Relational Mapper.

Enige voorzichtigheid met ORMs is noodzakelijk aangezien deze niet altijd de meest optimale query genereren voor de data die opgehaald moet worden. Ook kan de interface van het gekozen framework sommige aspecten juist moeilijker maken dan simpelweg de query schrijven of dynamisch opbouwen.

Het is dus belangrijk om te controleren of je effectief een ORM nodig hebt aangezien dit een redelijke complexiteit toevoegt aan je applicatie. Indien je bv. gebruik maakt van GraphQL is het overkill om een ORM te gaan gebruiken aangezien de gebruiker hierbij zelf kan kiezen welke data hij wel en niet ophaalt. Bij REST kan het dan weer een meerwaarde zijn. Het hangt sterk af van project tot project, denk hierbij bv. aan het aantal relaties of de moeilijkheid van de uitgevoerde queries.

#### Samengevat

- geen kennis van SQL vereist, genereert zelf queries
- eenvoudige interface om data op te vragen of weg te schrijven
- diepgaande ondersteuning voor relaties
- model definiëren kan complex zijn
- bv. [Sequelize](https://www.npmjs.com/package/sequelize) of [Prisma](https://www.npmjs.com/package/prisma), [TypeORM (enkel voor TypeScript)](https://www.npmjs.com/package/typeorm), [Mongoose (enkel voor MongoDB)](https://www.npmjs.com/package/mongoose)

### Datalaag: wat kiezen we nu?

Wij kiezen [knex.js](https://www.npmjs.com/package/knex) als querybuilder voor ons voorbeeld. Dit is prima voor wat we maar nodig hebben.

Voel je vrij om voor het project bv. een ORM framework te gebruiken!

We installeren knex en een MySQL client:

```bash
yarn add knex
yarn add mysql2
```

- [**knex**](https://www.npmjs.com/package/knex): een querybuilder en vormt onze interface naar de databank. Deze interface is generiek geschreven waardoor we nog een MySQL client moeten installeren, specifiek om onze MySQL databank aan te spreken.
- [**mysql2**](https://www.npmjs.com/package/mysql2): een MySQL client voor Node.js, gefocust op performantie én met ondersteuning voor async/await.

### Databank configuratie

Eerst moeten we onze configuratie uitbreiden met de gegevens van onze databank. Pas `src/config/development.js` als volgt aan:

```js
module.exports = {
  // ...
  database: {
    client: 'mysql2',
    host: 'localhost',
    port: 3306,
    name: 'budget',
    username: 'root',
    password: '',
  },
};
```

We splitsen deze zo klein mogelijk op om zoveel mogelijk vrijheid te hebben. Pas de instellingen aan jouw lokale instellingen aan of voorzie environment variables in de `custom-environment-variables.js` en `.env` bestanden.

## Connectie met de databank

We maken een module voor onze datalaag. Maak in de map `data` een bestand`index.js` aan met volgende inhoud:

```js
const knex = require('knex'); // 👈 4
const { getLogger } = require('../core/logging'); // 👈 8

// 👇 1 - start config
const config = require('config');

const NODE_ENV = config.get('env');
const isDevelopment = NODE_ENV === 'development';

const DATABASE_CLIENT = config.get('database.client');
const DATABASE_NAME = config.get('database.name');
const DATABASE_HOST = config.get('database.host');
const DATABASE_PORT = config.get('database.port');
const DATABASE_USERNAME = config.get('database.username');
const DATABASE_PASSWORD = config.get('database.password');
// 👆 1 einde config

let knexInstance; // 👈 5

// 👇 2
async function initializeData() {
  const logger = getLogger(); // 👈 9
  logger.info('Initializing connection to the database'); // 👈 9

  // 👇 1 - start knex opties
  const knexOptions = {
    client: DATABASE_CLIENT,
    connection: {
      host: DATABASE_HOST,
      port: DATABASE_PORT,
      database: DATABASE_NAME,
      user: DATABASE_USERNAME,
      password: DATABASE_PASSWORD,
      insecureAuth: isDevelopment,
    },
  };
  // 👆 6 einde knex opties
  knexInstance = knex(knexOptions); // 👈 7

  // 👇 8
  try {
    await knexInstance.raw('SELECT 1+1 AS result');
  } catch (error) {
    logger.error(error.message, { error }); // 👈 9
    throw new Error('Could not initialize the data layer'); // 👈 10
  }

  return knexInstance; // 👈 7
}

// 👇 11
function getKnex() {
  if (!knexInstance)
    throw new Error(
      'Please initialize the data layer before getting the Knex instance'
    );
  return knexInstance;
}

// 👇 12
const tables = Object.freeze({
  transaction: 'transactions',
  user: 'users',
  place: 'places',
});

module.exports = {
  initializeData, // 👈 3
  getKnex, // 👈 11
  tables, // 👈 12
};
```

1. Importeer eerst de configuratie en maak een variabele aan voor elk van de databankinstellingen.
2. Maak vervolgens een functie `initializeData` die onze connectie zal aanmaken.
3. Exporteer deze functie alvast.
4. Importeer knex.
5. Maak een globale variabele om onze connectie in te bewaren. Hierdoor kunnen we deze later gebruiken om queries uit te voeren of om correct af te sluiten.
6. Definieer de connectie-opties voor knex. We gaan er hierbij vanuit dat de databank reeds bestaat.
7. Vervolgens maken we een nieuwe Knex-instantie en retourneren deze.
8. Als laatste checken we of de connectie goed functioneert door een simpele query uit te voeren.
9. We loggen ook voldoende informatie zodat we kunnen debuggen als iets fout gaat.
10. Het heeft geen zin om de server op te starten als we geen databankconnectie hebben. We gooien dus een error zodat de server crasht.
11. Nu is de datalaag klaar voor gebruik. We moeten enkel onze connectie nog beschikbaar maken voor gebruik. We definiëren een getter voor de Knex-instantie. We exporteren deze ook.
12. We definiëren ook een constant object `tables` met de namen van onze tabellen. Nee, we coderen deze niet hard! Zo hoeven we maar één aanpassing te maken indien nodig. We exporteren dit ook.

Nu dienen we de `initializeData` aan te roepen in ons opstartscript. Pas hiervoor `src/index.js` aan:

```js
// andere imports
const { initializeData } = require('./data'); // 👈 1
// configuratie

// 👇 2
async function main() {
  // logger initialiseren

  await initializeData(); // 👈 4

  // andere code
}
main(); // 👈 3
```

1. We importeren de `initializeData` functie in ons opstartscript.
2. Wrap alle code uit dit bestand (behalve imports en configuratie) in een `async main` functie. We mogen nl. geen `await` doen buiten een `async` functie.
3. Roep deze functie vervolgens aan.
4. Initialiseer de datalaag na het initialiseren van de logger. Zo kunnen we gebruik maken van de logger in de datalaag.

### Oefening 1 - Je eigen project

Voeg de datalaag toe aan je eigen project.

> 💡 Tip: je kan als extra functionaliteit ook gebruik maken van een ORM framework. Zoek op wat de best practices zijn voor het gebruik van een ORM framework in Node.js. Implementeer het maken van een verbinding met de database.

## Repository

Een repository is een abstractie voor de datalaag. Het definieert een aantal functies (CRUD...) die queries uitvoeren en,indien nodig, de query resultaten omvormen naar OO-objecten. Het is de tussenpersoon tussen domein en databank. Zo is het "eenvoudig" om te switchen tussen databanken. Dit is eenvoudiger in een taal met interfaces en klassen (bv. TypeScript). [Lees meer over het repository patroon](https://medium.com/@pererikbergman/repository-design-pattern-e28c0f3e4a30)

Het repository patroon is niet altijd nodig. Maak zelf de afweging of de extra laag nut heeft. Een simpel "doorgeefluik" naar de databank heeft geen nut. Dit heeft bv. wel nut indien data omgevormd moet worden. Zorg voor één lijn in een applicatie: ofwel voor alles een repository ofwel voor niets. Meestal is deze laag niet nuttig bij het gebruik van een ORM want het ORM is zelf de repository.

### Voorbeeld: findAll places

Een repository exporteert verschillende functies die data ophalen: `findAll`, `findById`, `create`, `updateById`, `deleteById`... We nemen `findAll` voor de places als voorbeeld. Maak een map `repository` aan en een bestand `place.js`. Voeg volgende code toe:

```js
const { tables, getKnex } = require('../data/index'); // 👈 1

const findAll = () => {
  return getKnex()(tables.place) // 👈 2
    .select()
    .orderBy('name', 'ASC');
};

// 👇 3
module.exports = {
  findAll,
};
```

1. We importeren onze tabelnamen en de knex-getter. De repository gebruikt de querybuilder om de query op te bouwen. De services hoeven niet te weten hoe de query opgebouwd moet worden. Zo kan je eenvoudig switchen tussen databanken. Maar dit gebeurt niet vaak, maar toch...
2. We vragen dus de Knex-instantie op en starten een query voor de `places` tabel. Deze functie bouwt de SELECT-query op. Als voorbeeld sorteren we ook op de naam van de plaats.
3. We exporteren vervolgens de gedefinieerde functie.

### Oefening 2 - Je eigen project

Maak de repositorylaag aan in je eigen project.

Indien je werkt met een ORM framework:

- Definieer het model.
- Voorziet je ORM in een repository?
  - Zo ja, op welke manier? Gebruik deze.
  - Zo nee, definieer je eigen repository.

### Voorbeeld: findById transactions

We geven nog een extra voorbeeld om één specifieke transactie op te halen o.b.v. het id. Maak een bestand `transaction.js` aan in de map `repository` en voeg volgende code toe:

```js
const { tables, getKnex } = require('../data/index'); // 👈 1

// 👇 2
const SELECT_COLUMNS = [
  `${tables.transaction}.id`,
  'amount',
  'date',
  `${tables.place}.id as place_id`,
  `${tables.place}.name as place_name`,
  `${tables.user}.id as user_id`,
  `${tables.user}.name as user_name`,
];

// 👇 5
const formatTransaction = ({
  place_id,
  place_name,
  user_id,
  user_name,
  ...rest
}) => ({
  ...rest,
  place: {
    id: place_id,
    name: place_name,
  },
  user: {
    id: user_id,
    name: user_name,
  },
});

// 👇 3
const findById = async (id) => {
  // 👇 begin query (4)
  const transaction = await getKnex()(tables.transaction)
    .join(
      `${tables.place}`,
      `${tables.place}.id`,
      '=',
      `${tables.transaction}.place_id`
    )
    .join(
      `${tables.user}`,
      `${tables.user}.id`,
      '=',
      `${tables.transaction}.user_id`
    )
    .where('id', id)
    .first(SELECT_COLUMNS);
  // 👆 einde query (4)

  return transaction && formatTransaction(transaction); // 👈 5
};

// 👇 3
module.exports = {
  findById,
};
```

1. Importeer de tabelnamen en knex-getter.
2. We definiëren een array met alle op te halen kolommen.
   - Merk op: we maken aliassen voor de kolommen uit de tabellen `places` en `transactions` aangezien deze identiek zijn aan elkaar en voor conflicten zullen zorgen
3. Definieer een functie `findById` en exporteer.
4. Haal de transactie op.
   - We gebruiken opnieuw de Knex-instantie (`getKnex()`) om een nieuwe query te starten voor de `transactions` tabel.
   - We filteren op id (`where`-clause).
   - We kiezen het eerste record (`first()`, er is er logischerwijs maar één), anders kan het id geen primary key zijn...
   - We selecteren de gedefinieerde kolommen(`first(SELECT_COLUMNS)`). We kunnen de array hergebruiken in `findAll`.
   - We joinen ook nog de tabellen waarmee een transactie een relatie heeft: `places` en `users`.
5. We definiëren een functie die een transactie uit de databank omvormt naar een mooi object. Als er een transactie gevonden werd, dan vormen we het resultaat om naar het gewenste formaat. Return eens de niet omgevormde transactie om het verschil te zien (dit is dan het pure query-antwoord).

### Oefening 3 - Je eigen project

Maak een `findById` functie aan in je project.

> 💡 Tip: Je kan als extra functionaliteit gebruik maken van een **mapper package** om de mapping te definiëren.

### Voorbeeld: create transaction

Als laatste definiëren we een functie om een transactie toe te voegen in onze transaction repository:

```js
// ...

// 👇 1
const create = async ({ amount, date, placeId, userId }) => {
  //     👇 3
  const [id] = await getKnex()(tables.transaction).insert({
    amount,
    date,
    place_id: placeId,
    user_id: userId,
  }); // 👈 2
  return id; // 👈 3
};

module.exports = {
  findById,
  create, // 👈 4
};
```

1. Voeg de functie `create` toe.
2. We starten een INSERT-query en geven de nodige data voor de transactie mee. De repository zet data van de servicelaag om naar het juiste formaat voor de tabel waarmee hij werkt. Dit gebeurt hier voor `place_id` en `user_id`. De kolomnaam is immers `place_id` en niet `placeId`.
3. We krijgen van MySQL een array terug met op de eerste positie het id van de aangemaakte entiteit, vandaar `[id]`.
4. We retourneren het id van de aangemaakte entiteit.
5. Exporteer de functie.

Merk op dat we in de repositorylaag geen errors opvangen. Dit gebeurt in de servicelaag (zie verder).

### Oefening 4 - Je eigen project

- Maak een `create` functie aan voor een entiteit in je eigen project.
- Maak ook `updateById` en `deleteById` aan.

## Services

Om deze repositories nu te gebruiken, importeren we alle functies die in de modules gedefinieerd werden. Pas `src/service/place.js` als volgt aan:

```js
const placesRepository = require('../repository/place'); // 👈 1

const getAll = async () => {
  const items = await placesRepository.findAll(); // 👈 2
  return {
    items,
    count: items.length,
  }; // 👈 3
};
```

1. Importeer alle functies uit de places repository.
2. In de functie `getAll` halen we de data nu op via de repository.
3. En retourneren dit in een object, samen met de count (het aantal elementen in de lijst).
   - Merk op: deze functie is async geworden doordat we een await doen op de functie uit de transaction repository.

Doordat deze functie async geworden is dienen we de REST-laag ook aan te passen. Voorlopig halen we simpelweg de lijst van places op in onze handler voor `GET /api/places`, maar deze functie is async geworden. Vergeet dus niet om await toe te voegen in `src/rest/place.js` of je zal geen correct antwoord krijgen!

```js
const placeService = require('../service/place');

const getAllPlaces = async (ctx) => {
  const places = await placeService.getAll();
  ctx.body = places;
};
// ...
```

### Repository in NodeJS

Er is geen gouden graal, dit is slechts een voorbeeldaanpak. We hebben nu volgende mappenstructuur in de map `src`:

- `data`: connectie met databank opzetten en beheren, met in deze map ook deze mappen:
  - `migrations`: zie verder
  - `seeds`: zie verder
- `repository`: bevat repositories
- `service`: bevat services/domein logica
- `rest`: bevat de REST-laag

### Oefening 5 - Je eigen project

- Pas de service- en REST-laag aan in je eigen project voor de `findAll` functie uit de repository.
- Voeg een `findCount` functie toe in je repository. Deze haalt het totaal aantal rijen op in de betreffende tabel. Meer in [de knex documentatie](https://knexjs.org/guide/query-builder.html#count).
- Gebruik deze in de `getAll` (= service) om een property `count` toe te voegen aan de returnwaarde.
- Doe dit ook voor de andere methodes: `getById`, `create`, `updateById` en de `deleteById`.

Indien je voor een ORM framework gaat, pas dan de service- en REST-laag aan.

<!-- markdownlint-disable-next-line -->

- Oplossing +

  Een voorbeeldoplossing is te vinden op <https://github.com/HOGENT-Web/webservices-budget> in commit `TODO:`

  ```bash
  git clone https://github.com/HOGENT-Web/webservices-budget.git
  git checkout -b oplossing TODO:
  yarn install
  yarn start
  ```

### Problemen!

Momenteel hebben we nog een aantal vragen in onze applicatie:

- Wie zal ervoor zorgen dat het databank-schema up to date is met de laatste versie van het schema? Denk aan:
  - nieuwe tabellen, kolommen, procedures, triggers...
  - hernoemde tabellen, kolommen...
  - verdwenen tabellen, kolommen...
- Wie zal ervoor zorgen dat we degelijke dummy data hebben in de databank?

Het antwoord: we doen dit niet handmatig, zelfs geen dummy data!

## Migrations

Migrations zijn een soort version control voor de databank. Ze kijken op welke versie het databankschema zit en doen eventueel updates. Ze brengen het databankschema naar een nieuwere versie.

Je kan ook wijzigingen ongedaan maken als er iets fout liep. Dit is zeer belangrijk in production databanken!

Het is wel belangrijk dat je let op de volgorde van uitvoeren van de migraties om geen problemen te krijgen met bv. foreign keys die nog niet zouden bestaan.

![Migraties](./images/versioncontrol-xkcd.jpg ':size=70%')

### Migrations: KnexJS

KnexJS heeft [builtin migrations](https://knexjs.org/#Migrations). Je moet in de [configuratie](https://knexjs.org/#Installation-migrations) enkel aangeven waar de migrations staan.

Migrations in KnexJS zijn JavaScript modules die twee functies exporteren:

1. `up`: bevat de code die deze migratie uitvoert.
2. `down`: bevat de code die de migratie ongedaan maakt.

Er is één bestand per migratie. De bestandsnaam bevat een timestamp en een korte beschrijving van de migratie: `YYYYMMDDHHmm_description.js`, bv. `202309111840_createUserTable.js`. Door de timestamp vooraan kan je een bepaalde volgorde afdwingen. KnexJS voert de migraties uit in alfabetische volgorde.

In onze budget app hebben we enkele migraties:

- `places` tabel aanmaken
- `users` tabel aanmaken
- `transactions` tabel aanmaken
- een kolom `rating` aan een place toevoegen

### Migrations: voorbeeld

We starten met het aanmaken van een migratie voor de tabel `places`. Maak een map `migrations` aan in de map `data`. Voeg vervolgens een bestand `202309111845_createPlaceTable.js` toe met volgende inhoud:

```js
const { tables } = require('..');

module.exports = {
  up: async (knex) => {
    await knex.schema.createTable(tables.place, (table) => {
      table.increments('id'); // 👈 1

      table.string('name', 255).notNullable(); // 👈 2

      table.unique('name', 'idx_place_name_unique'); // 👈 3
    });
  },
  down: (knex) => {
    return knex.schema.dropTableIfExists('places');
  },
};
```

- Een migration-file exporteert twee functies genaamd `up` en `down`. De `up` functie is in dit voorbeeld `async` door het gebruik van `await`, nodig voor de creatie van de tabel.
- Beide functies krijgen de Knex-instantie mee als argument. Dit is de interface naar de databank.
- De `up`-functie zal de tabel `places` aanmaken. Hiervoor wordt de `createTable`-functie van de [Knex Schema API](https://knexjs.org/guide/schema-builder.html) gebruikt Het eerste argument van de `createTable` functie is de tabelnaam. Uiteraard codeer je dit niet hard, dit is maar een voorbeeld. Je kan het tables object uit de datalaag importeren.
- Het tweede argument is een functie die een interface naar de tabel meekrijgt. Met deze interface kunnen we de tabel volledig instellen (kolommen, indices...). Merk op: deze interface bouwt een CREATE TABLE DDL-statement op. Per functie-aanroep op deze interface wordt geen DDL-statement uitgevoerd! Enkel als de functie van dit 2e argument uitgevoerd is.
  1. We maken eerst een kolom met als naam `id`, het type van deze kolom is `INT`. Deze kolom heeft een auto-increment en is daarom de primary key
  2. We voegen nog een kolom `name` toe. Deze kolom is van het type `string` en heeft een maximum lengte van 255 karakters. Deze kolom mag ook geen `NULL` bevatten
  3. We stellen ook nog een `UNIQUE INDEX` in op de kolom `name`. We geven deze index de naam `idx_place_name_unique` om eenvoudiger een mooie foutboodschap te kunnen retourneren naar de client. Je kan deze checks ook in de code uitvoeren maar databankservers zijn vaak meer uit de kluiten gewassen dan de backend-server. **Alles wat de databank kan doen, laat je de databank doen**
- De `down`-functie gooit simpelweg de eventueel gemaakte tabel weg.
  - Waarom is hier geen `async` nodig? Deze functie retourneert de `Promise` meteen, dus `async` is niet nodig

### Databank aanmaken

Alvorens we de migratie uitvoeren dienen we er zeker van te zijn dat de database bestaat. Dit is niet altijd het geval. We kunnen de databank ook laten aanmaken door KnexJS. We voegen hiervoor een extra stap toe in onze `initializeData` functie:

```js
async function initializeData() {
  const logger = getLogger();
  logger.info('Initializing connection to the database');

  const knexOptions = {
    client: DATABASE_CLIENT,
    connection: {
      host: DATABASE_HOST,
      port: DATABASE_PORT,
      // database: DATABASE_NAME, // 👈 1
      user: DATABASE_USERNAME,
      password: DATABASE_PASSWORD,
      insecureAuth: isDevelopment,
    },
  };
  knexInstance = knex(knexOptions); // 👈 1

  // 👇 2
  try {
    await knexInstance.raw('SELECT 1+1 AS result');
    await knexInstance.raw('CREATE DATABASE IF NOT EXISTS ??', DATABASE_NAME); // 👈 3

    // We need to update the Knex configuration and reconnect to use the created database by default
    // USE ... would not work because a pool of connections is used
    await knexInstance.destroy(); // 👈 4

    knexOptions.connection.database = DATABASE_NAME; // 👈 5
    knexInstance = knex(knexOptions); // 👈 6
    await knexInstance.raw('SELECT 1+1 AS result'); // 👈 7
  } catch (error) {
    logger.error(error.message, { error });
    throw new Error('Could not initialize the data layer');
  }

  // ...
}
```

1. We verwijderen de databank naam en maken eerst een connectie zonder databank.
2. Vervolgens breiden we onze connectiecheck uit.
3. We maken een databank aan, indien deze nog niet bestaat. De `??` zijn een placeholder voor de databanknaam, die we als parameter doorgeven. Deze wordt geëscaped door KnexJS.
4. We gooien de connectie weg.
5. We passen de connectie-opties aan zodat we de al dan niet aangemaakte databank kunnen gebruiken.
6. We maken een nieuwe connectie aan.
7. We testen of de connectie goed functioneert.

### Migrations uitvoeren

Migrations worden typisch uitgevoerd voor de server opstart. We voegen deze code toe aan onze `initializeData` in `src/data/index.js`:

```js
const { join } = require('path');

async function initializeData() {
  //..

  const knexOptions = {
    //..
    debug: isDevelopment,
    migrations: {
      tableName: 'knex_meta',
      directory: join('src', 'data', 'migrations'),
    }, // 👈 1
  };

  //..
  // Run migrations
  // 👈 2
  try {
    await knexInstance.migrate.latest();
  } catch (error) {
    logger.error('Error while migrating the database', {
      error,
    });

    // No point in starting the server when migrations failed
    throw new Error('Migrations failed, check the logs');
  }
  logger.info('Succesfully connected to the database');
  return knexInstance;
}
//..
```

1. We geven mee aan Knex waar onze migraties staan en in welke tabel hij metadata over de uitgevoerde migraties mag bijhouden.
2. Nadat de connectie aangemaakt is en goed functioneert, voeren we de migraties uit. We gebruiken de `latest` functie van de Knex Migration API. Deze functie zal kijken op welke versie de databank zit en zal deze vervolgens up to date maken. Als de migraties gefaald zijn, gooien we een error waardoor de server crasht. Het heeft geen zin om de server te starten met een mogelijks corrupte databank, de developer moet dit zelf controleren en fixen.

### Opmerking

De volgorde van uitvoeren van migraties is belangrijk. Je dient eerst de Place en User tabel te creëren, dan pas de Transaction tabel. In de Transaction tabel definiëren we de referentiële integriteit. Belangrijk is om mee te geven hoe de delete dient te gebeuren : CASCADE, RESTRICT, NO ACTION, SET NULL

Voor de migratie van de Transaction tabel

`src/data/migrations/202309190850_createTransactionTable.js`

```js
const { tables } = require('..');

module.exports = {
  up: async (knex) => {
    await knex.schema.createTable(tables.transaction, (table) => {
      table.increments('id');

      table.integer('amount').notNullable();

      table.dateTime('date').notNullable();

      table.integer('user_id').unsigned().notNullable();

      // Give this foreign key a name for better error handling in service layer
      table
        .foreign('user_id', 'fk_transaction_user')
        .references(`${tables.user}.id`)
        .onDelete('CASCADE');

      table.integer('place_id').unsigned().notNullable();

      // Give this foreign key a name for better error handling in service layer
      table
        .foreign('place_id', 'fk_transaction_place')
        .references(`${tables.place}.id`)
        .onDelete('CASCADE');
    });
  },
  down: (knex) => {
    return knex.schema.dropTableIfExists(tables.transaction);
  },
};
```

### Oefening 6 - Je eigen project

Maak voor een tabel in je project de migratie aan en voer deze uit.

## Seeds

Met seeds kan je testdata toevoegen aan een databank. Dit wordt typisch enkel gebruikt in development (niet in testing of production). Typisch maak je één seed per tabel.

Let hier ook op de volgorde, bv. bij relaties!

### Seeds: KnexJS

KnexJS heeft [builtin seeds](https://knexjs.org/#Seeds-API). Je moet in de [configuratie](https://knexjs.org/#Seeds-CLI) enkel aangeven waar seeds staan.

Seeds zijn JavaScript modules die één functie `seed` exporteren. Deze functie bevat de code die de testdata toevoegt. Er is één bestand per seed (of dus per tabel). De bestandsnaam bevat een timestamp en een korte beschrijving van de seed: `YYYYMMDDHHmm_description.js`, bv. `202309111930_places.js`. Door de timestamp vooraan kan je een bepaalde volgorde afdwingen. KnexJS voert de seeds uit in alfabetische volgorde.

Maak het seed bestand aan voor de seeding van de places tabel. Maak hiervoor een map `seeds` in de map data. Maak een nieuw bestand `202309111935_places.js` met deze inhoud:

```js
module.exports = {
  // 👇 1
  seed: async (knex) => {
    // first delete all entries
    await knex('places').delete(); // 👈 2

    // then add the fresh places
    await knex('places').insert([
      { id: 1, name: 'Loon', rating: 5 },
      { id: 2, name: 'Dranken Geers', rating: 3 },
      { id: 3, name: 'Irish Pub', rating: 4 },
    ]); // 👈 3
  },
};
```

1. Een seed bestand exporteert één functie genaamd `seed`. Deze functie krijgt opnieuw de Knex-instantie mee als argument. Dit is de interface naar de databank.
2. Het is nuttig om eerst de tabel leeg te maken. Mogelijks bleef er nog data achter van een vorige opstart. Dit kan zorgen voor id conflicten, e.d.
3. Vervolgens voegen we onze testdata toe. Je kan kiezen om vaste ids te nemen of om deze te laten genereren door de databank.
   - Wat is een voordeel van vaste ids? Hiermee is het eenvoudig om relaties te definiëren. Logisch, want je kent het id van elke record, bij generatie is dit telkens verschillend.

### Seeds uitvoeren

Seeds worden typisch uitgevoerd voor de server opstart. We voegen deze code toe aan onze `initializeData` in `src/data/index.js`:

```js
async function initializeData() {
  const knexOptions = {
    // ...
    seeds: {
      // 👈 1
      directory: join('src', 'data', 'seeds'),
    },
  };
  // ...
  if (isDevelopment) {
    // 👈 2
    // 👇 3
    try {
      await knexInstance.seed.run();
    } catch (error) {
      logger.error('Error while seeding database', {
        error,
      });
    }
  }

  return knexInstance;
}
```

1. We geven aan Knex mee waar de seeds staan. We voegen deze code toe aan onze `initializeData`.
2. We voeren de seed enkel uit indien we in development mode zijn.
3. We gebruiken de run functie van de Knex Seed API. Hierna is de datalaag pas echt opgestart. Het is niet erg als de seeds falen; we loggen dit enkel, de server kan nadien gewoon opstarten.

### Oefening 7 - Je eigen project

Maak de seeding aan voor 1 tabel en zorg ervoor dat de seeding kan worden uitgevoerd.

## Het totaalplaatje

Hoe en wanneer moeten migrations en seeds uitgevoerd worden?

- vóór de start van de server

Dat geeft een aantal mogelijkheden:

- externe service die hiervoor zorgt
- scripts die uitgevoerd worden voor de server start (voor `yarn start`)
- de server doet het zelf

We kiezen de laatste optie.

Let op! Onze aanpak is niet aangepast voor/getest op servers die parallel draaien! De server is niet op de hoogte van de andere servers. Gevolg? Mogelijke conflicten tussen meerdere servers die tegelijk migreren of seeden.

### Opstarten van de datalaag

Als de datalaag opstart, worden volgende stappen uitgevoerd:

1. connectie maken met databank (zonder databank te specifiëren)
2. connectie controleren
3. databank aanmaken (indien onbestaand)
4. connectie weggooien
5. nieuwe connectie maken (op de aangemaakte databank)
6. migraties uitvoeren
   - indien gefaald: server stopt
7. indien in development: seeds uitvoeren
   - indien gefaald: geen probleem, server start verder op
8. datalaag is succesvol opgestart

Code: zie [GitHub](https://github.com/HOGENT-Web/webservices-budget/blob/main/src/data/index.js)

## Oefening 8 - Je eigen project

Werk aan je eigen project!

- Vervolledig je repositories en services in je project met alle benodigde CRUD-operaties.
- Vervolledig ook de migrations en seeds.

OF

- Voeg in de Budget WebService de migratie, seeding, repo, service en rest toe voor de CRUD van de Users

## Mogelijke extra's voor de examenopdracht

- Gebruik van een ORM framework.
- Gebruik van een mapper package in de repositorylaag.
