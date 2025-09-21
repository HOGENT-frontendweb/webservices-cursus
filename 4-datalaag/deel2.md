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

## Leerdoelen

- Je kan meerdere tabellen definiëren en gebruiken met Drizzle
- Je kan relaties tussen tabellen definiëren en gebruiken met Drizzle
- Je kan complexe queries maken met Drizzle

### Oefening - Schema aanvullen

1. Vul het schema aan met de tabellen voor transactions en users.
2. Denk aan de foreign keys. Zorg ervoor dat die naar de juiste kolommen verwijzen.
3. Voeg ook de nodige indices toe.

- Oplossing +

  Voeg toe aan `src/drizzle/schema.ts`:

  ```ts
  export const users = mysqlTable(
    'users',
    {
      id: int('id', { unsigned: true }).primaryKey().autoincrement(),
      name: varchar('name', { length: 255 }).notNull(),
    },
    (table) => [uniqueIndex('idx_user_email_unique').on(table.email)],
  );

  export const transactions = mysqlTable('transactions', {
    id: int('id', { unsigned: true }).primaryKey().autoincrement(),
    amount: int('amount').notNull(),
    date: datetime('date').notNull(),
    userId: int('user_id', { unsigned: true })
      .references(() => users.id, { onDelete: 'cascade' })
      .notNull(),
    placeId: int('place_id', { unsigned: true })
      .references(() => places.id, { onDelete: 'no action' })
      .notNull(),
  });
  ```

### Oefening - Relaties toevoegen

Voeg de volgende relaties toe aan het schema:

1. Een user kan meerdere transactions hebben.
2. Een place kan meerdere transactions hebben.
3. Een transactie heeft één user en één place.

- Oplossing +

  Voeg toe aan `src/drizzle/schema.ts`:

  ```ts
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
  ```

### Oefening - Migratie maken en uitvoeren

1. Maak een nieuwe migratie aan.
2. Voer de migratie uit.

- Oplossing +

  Voer volgende commando's uit:

  ```bash
  pnpm db:generate
  pnpm db:migrate
  ```

```ts
async function resetDatabase() {
  console.log('🗑️ Resetting database...');

  // Delete data in correct order (respecting foreign key constraints)
  await db.delete(schema.transactions);
  await db.delete(schema.places);
  await db.delete(schema.users);

  console.log('✅ Database reset completed\n');
}
```

Vervolgens definiëren we de functies om de data toe te voegen:

```ts
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
```

### Transactions

Als laatste voorbeeld passen we de methode `getAll` in de `TransactionService` aan:

```ts
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
