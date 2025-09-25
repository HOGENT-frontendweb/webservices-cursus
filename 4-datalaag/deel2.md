# Relaties (WIP)

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les4 TODO:
> pnpm install
> pnpm start:dev
> ```

<!-- TODO: aanvullen met veel op veel relatie -->
<!-- TODO: get place by id aanvullen met relaties -->

## Leerdoelen

- Je kan meerdere tabellen definiëren en gebruiken met Drizzle
- Je kan relaties tussen tabellen definiëren en gebruiken met Drizzle
- Je kan complexe queries maken met Drizzle

## Inleiding

In een vorig hoofdstuk hebben we de basis gelegd voor het werken met Drizzle ORM. Nu gaan we dieper in op het definiëren van relaties tussen tabellen en het uitvoeren van complexe queries.

Hier zie je nogmaals het ERD waar we in dit hoofdstuk naartoe werken:

![ERD](../3-REST_api_bouwen/images/budget_erd.svg)

In het vorige hoofdstuk hebben we de places tabel reeds aangemaakt. We gaan nu de users, transactions en user_favorite_places tabellen toevoegen, inclusief de nodige relaties.

### Oefening - Schema aanvullen

Vul het schema aan met de tabellen voor transactions, users en favoriete places:

- Definieer enkel de kolommen, laat de foreign keys en indices nog weg.
- Definieer voor de user tabel enkel de kolommen `id` en `name`.
- Voor de tabel user_favorite_places definieer je een samengestelde primary key met behulp van de `primaryKey` functie: <https://orm.drizzle.team/docs/indexes-constraints#composite-primary-key>

<br />

- Oplossing +

  Voeg toe aan `src/drizzle/schema.ts`:

  ```ts
  // src/drizzle/schema.ts

  import {
    // ...
    datetime,
    json,
    primaryKey,
  } from 'drizzle-orm/mysql-core';

  // ...

  export const users = mysqlTable('users', {
    id: int('id', { unsigned: true }).primaryKey().autoincrement(),
    name: varchar('name', { length: 255 }).notNull(),
  });

  export const transactions = mysqlTable('transactions', {
    id: int('id', { unsigned: true }).primaryKey().autoincrement(),
    amount: int('amount').notNull(),
    date: datetime('date').notNull(),
    userId: int('user_id', { unsigned: true }).notNull(),
    placeId: int('place_id', { unsigned: true }).notNull(),
  });

  export const userFavoritePlaces = mysqlTable(
    'user_favorite_places',
    {
      userId: int('user_id', { unsigned: true }).notNull(),
      placeId: int('place_id', { unsigned: true }).notNull(),
    },
    (table) => [primaryKey({ columns: [table.userId, table.placeId] })],
  );
  ```

## Relaties definiëren

In Drizzle moet je relaties op twee plaatsen definiëren:

1. In de tabeldefinities: dit wordt door de databank gebruikt om foreign keys en indices aan te maken, en de referentiële integriteit te waarborgen.
2. In de relatie-definities: dit wordt door Drizzle gebruikt om de relaties tussen de tabellen te begrijpen en te beheren. Hierdoor kan je later in de ORM-like interface makkelijk de gerelateerde data opvragen.
   - **Merk op:** dit heeft enkel gevolgen voor jou als programmeur, de databank zelf maakt hier geen gebruik van. Hierdoor krijg je betere type-inferentie en autocompletion in je code editor.
   - Deze definities kan je bijgevolg in sommige gevallen weglaten. Denk bijvoorbeeld aan relaties die slechts in één richting worden gebruikt.

Lees de documentatie over dit verschil: <https://orm.drizzle.team/docs/relations#foreign-keys>.

In ons ERD hebben we volgende relaties:

1. Een user kan meerdere transactions hebben.
2. Een place kan meerdere transactions hebben.
3. Een transactie heeft één user en één place.
4. Een user kan meerdere favoriete places hebben.
5. Een place kan favoriet zijn bij meerdere users.

Welk soort relaties zijn dit: één-op-veel of veel-op-veel?

- Oplossing +

  Relaties 1, 2 en 3 zijn onderdeel van dezelfde veel-op-veel relatie tussen users en places via transactions. De tabel transactions is in dit geval een tussentabel met extra kolommen.

  Relaties 4 en 5 zijn onderdeel van dezelfde veel-op-veel relatie tussen users en places via de tabel user_favorite_places. De tabel user_favorite_places is in dit geval een pure tussentabel zonder extra kolommen.

Lees eerst de documentatie over de `foreignKey` functie: <https://orm.drizzle.team/docs/indexes-constraints#foreign-key>.

### Foreign keys toevoegen

Als eerste voegen we de foreign keys toe in de tabeldefinities in `src/drizzle/schema.ts`:

```ts
// src/drizzle/schema.ts

// ...
export const transactions = mysqlTable('transactions', {
  // ...
  userId: int('user_id', { unsigned: true })
    .references(() => users.id, { onDelete: 'cascade' }) // 👈
    .notNull(),
  placeId: int('place_id', { unsigned: true })
    .references(() => places.id, { onDelete: 'no action' }) // 👈
    .notNull(),
});

export const userFavoritePlaces = mysqlTable(
  'user_favorite_places',
  {
    userId: int('user_id', { unsigned: true })
      .references(() => users.id, { onDelete: 'cascade' }) // 👈
      .notNull(),
    placeId: int('place_id', { unsigned: true })
      .references(() => places.id, { onDelete: 'cascade' }) // 👈
      .notNull(),
  },
  (table) => [primaryKey({ columns: [table.userId, table.placeId] })],
);
```

Met deze foreign keys zorgen we ervoor dat:

- Als een user verwijderd wordt, ook alle bijhorende transactions en user_favorite_places verwijderd worden (cascade delete).
- Een place verwijderen faalt als er nog transacties aan gekoppeld zijn (no action). Je kan enkel een place verwijderen als er geen transacties meer aan gekoppeld zijn.

Hiermee zijn de relaties in de databank gedefinieerd.

### Relaties toevoegen in Drizzle

Vervolgens voegen we de relaties toe in de relatie-definities in `src/drizzle/schema.ts` onder de tabel-definities:

```ts
// src/drizzle/schema.ts
// ...
import { relations } from 'drizzle-orm';

// ...
export const placesRelations = relations(places, ({ many }) => ({
  transactions: many(transactions),
}));

export const usersRelations = relations(users, ({ many }) => ({
  transactions: many(transactions),
}));

export const transactionsRelations = relations(transactions, ({ one }) => ({
  place: one(places, {
    fields: [transactions.placeId],
    references: [places.id],
  }),
  user: one(users, {
    fields: [transactions.userId],
    references: [users.id],
  }),
}));

export const userFavoritePlacesRelations = relations(
  userFavoritePlaces,
  ({ one }) => ({
    // Relatie in de richting van user niet gebruikt
    place: one(places, {
      fields: [userFavoritePlaces.placeId],
      references: [places.id],
    }),
  }),
);
```

Merk op dat we in de `userFavoritePlacesRelations` enkel de relatie naar `places` definiëren. De relatie naar `users` wordt niet gebruikt in onze applicatie, dus die laten we weg.

Merk ook op dat de `relations` functie geïmporteerd wordt vanuit `drizzle-orm` en niet vanuit `drizzle-orm/mysql-core`. Hieraan zie je ook dat dit puur een Drizzle concept is en geen databank-concept.

### Oefening - Migratie maken en uitvoeren

1. Maak een nieuwe migratie aan.
2. Voer de migratie uit.

- Oplossing +

  Voer volgende commando's uit:

  ```bash
  pnpm db:generate
  pnpm db:migrate
  ```

## Seeds aanvullen

We gaan nu de seed data aanvullen met users, transactions en favoriete places. Vervolledig eerst de `resetDatabase` functie in `src/drizzle/seed.ts`:

```ts
// src/drizzle/seed.ts

async function resetDatabase() {
  console.log('🗑️ Resetting database...');

  await db.delete(schema.transactions);
  await db.delete(schema.places);
  await db.delete(schema.users);

  console.log('✅ Database reset completed\n');
}
```

Denk eraan om de tabellen in de juiste volgorde te verwijderen om foreign key problemen te vermijden.

Vervolgens definiëren we de functies om data toe te voegen aan de nieuwe tabellen:

```ts
// src/drizzle/seed.ts

async function seedUsers() {
  console.log('👥 Seeding users...');

  await db.insert(schema.users).values([
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
  ]);

  console.log('✅ Users seeded successfully\n');
}

async function seedTransactions() {
  console.log('💰 Seeding transactions...');

  await db.insert(schema.transactions).values([
    // User Thomas
    // ===========
    {
      id: 1,
      userId: 1,
      placeId: 1,
      amount: 3500,
      date: new Date(2021, 4, 25, 19, 40),
    },
    {
      id: 2,
      userId: 1,
      placeId: 2,
      amount: -220,
      date: new Date(2021, 4, 8, 20, 0),
    },
    {
      id: 3,
      userId: 1,
      placeId: 3,
      amount: -74,
      date: new Date(2021, 4, 21, 14, 30),
    },
    // User Pieter
    // ===========
    {
      id: 4,
      userId: 2,
      placeId: 1,
      amount: 4000,
      date: new Date(2021, 4, 25, 19, 40),
    },
    {
      id: 5,
      userId: 2,
      placeId: 2,
      amount: -220,
      date: new Date(2021, 4, 9, 23, 0),
    },
    {
      id: 6,
      userId: 2,
      placeId: 3,
      amount: -74,
      date: new Date(2021, 4, 22, 12, 0),
    },
    // User Karine
    // ===========
    {
      id: 7,
      userId: 3,
      placeId: 1,
      amount: 4000,
      date: new Date(2021, 4, 25, 19, 40),
    },
    {
      id: 8,
      userId: 3,
      placeId: 2,
      amount: -220,
      date: new Date(2021, 4, 10, 10, 0),
    },
    {
      id: 9,
      userId: 3,
      placeId: 3,
      amount: -74,
      date: new Date(2021, 4, 19, 11, 30),
    },
  ]);

  console.log('✅ Transactions seeded successfully\n');
}

async function seedUserFavoritePlaces() {
  console.log('💰 Seeding UserFavoritePlaces...');

  await db.insert(schema.userFavoritePlaces).values([
    {
      userId: 1,
      placeId: 1,
    },
    {
      userId: 1,
      placeId: 2,
    },
    {
      userId: 2,
      placeId: 1,
    },
  ]);

  console.log('✅ UserFavoritePlaces seeded successfully\n');
}
```

Pas tot slot de `main` functie aan om deze nieuwe functies aan te roepen:

```ts
// src/drizzle/seed.ts

async function main() {
  console.log('🌱 Starting database seeding...\n');

  await resetDatabase();
  await seedUsers();
  await seedPlaces();
  await seedTransactions();
  await seedUserFavoritePlaces();

  console.log('🎉 Database seeding completed successfully!');
}
```

<!--
TODO:
  - Oefening:
    - TransactionController en UserController met routes aanmaken
    - DTO's aanmaken
    - TransactionService aanmaken met getAll, getById, create, update, delete, getTransactionsByPlaceId (met Error implementeren)
    - UserService aanmaken met getAll, getById, create, update, delete (met Error implementeren)
    - PlacesService uitbreiden met getFavoritePlacesByUserId
  - Methoden TransactionService en PlacesService implementeren in de les
  - Oefening: UserService implementeren
 -->

### Transactions

Als laatste voorbeeld passen we de methode `getAll` in de `TransactionService` aan:

```ts
// src/transactions/transaction.service.ts

export class TransactionService {
  // 👇 1
  constructor(
    @InjectDrizzle()
    private readonly db: DatabaseProvider,
  ) {}

  async getAll(
    userId: number,
    roles: string[],
  ): Promise<TransactionListResponseDto> {
    const items = await this.db.query.transactions.findMany({
      // 👇 2
      columns: {
        id: true,
        amount: true,
        date: true,
      },
      // 👇 3
      with: {
        place: true,
        user: true,
      },
    });

    return { items };
  }

  // ...
}
```

1. We injecteren onze Drizzle provider in de constructor.
2. We selecteren enkel de kolommen `id`, `amount` en `date`.
   - De kolommen `placeId` en `userId` wensen we niet in ons response. De eindgebruiker hoeft niet te weten hoe de transactions gekoppeld zijn aan de place en user.
3. We selecteren de place en de user.
   - Merk op dat we toch de place en de user kunnen ophalen zonder hun foreign keys in de `columns` te zetten. Drizzle gebruikt die wel in de query maar zet ze niet in de `SELECT`.

Maak ook de bijhorende methode in de `TransactionController` async.

De code van de overige methoden uit de services kan je raadplegen in onze voorbeeldapplicatie.
