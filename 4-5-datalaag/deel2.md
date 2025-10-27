# Relaties

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les5 e27a0a6
> pnpm install
> pnpm db:migrate
> pnpm db:seed
> pnpm start:dev
> ```

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

- Definieer enkel de kolommen, laat de foreign keys nog weg.
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

Voer de seeding uit:

```bash
pnpm db:seed
```

## PlaceService - getById

We gaan nu de services aanpassen om de relaties te gebruiken. We beginnen hiervoor met de getById methode uit de `PlaceService`. Hierbij willen we de place ophalen samen met alle bijhorende transactions en bij elke transaction ook de user en de place.

Lees eerst de sectie "Include relations" in de Drizzle documentatie: <https://orm.drizzle.team/docs/rqb#include-relations>.

```ts
export class PlaceService {
  // ...
  async getById(id: number): Promise<PlaceDetailResponseDto> {
    const place = await this.db.query.places.findFirst({
      where: eq(places.id, id),
      // 👇
      with: {
        transactions: {
          with: {
            user: true,
            place: true,
          },
        },
      },
    });

    // ...
  }
  // ...
}
```

Met de `with` optie halen we gerelateerde gegevens op in de ORM-like manier. In dit geval laden we alle transactions die aan deze place gekoppeld zijn. Voor elke transaction gebruiken we opnieuw `with` om de bijbehorende user- en place-informatie op te halen.

Daarnaast heb je ook de mogelijk om SQL-like joins uit te voeren, lees hierover de documentatie t.e.m. "Full Join": <https://orm.drizzle.team/docs/joins>.

### Oefening implementeer PlaceDetailResponseDto

- Oplossing +

  Definieer eerst een `PublicUserResponseDto` in `src/user/user.dto.ts`:

  ```ts
  // src/user/user.dto.ts
  export class PublicUserResponseDto {
    id: number;
    name: string;
  }
  ```

  Definieer ook een `TransactionResponseDto` in `src/transaction/transaction.dto.ts`:

  ```ts
  // src/transactions/transaction.dto.ts
  import { PlaceResponseDto } from '../place/place.dto';
  import { PublicUserResponseDto } from '../user/user.dto';

  export class TransactionResponseDto {
    id: number;
    amount: number;
    date: Date;
    user: PublicUserResponseDto;
    place: PlaceResponseDto;
  }
  ```

  Definieer tot slot een `PlaceDetailResponseDto` in `src/place/place.dto.ts`:

  ```ts
  // src/place/place.dto.ts
  import { TransactionResponseDto } from '../transactions/transaction.dto';

  export class PlaceDetailResponseDto extends PlaceResponseDto {
    transactions: TransactionResponseDto[];
  }
  ```

  Pas het returnType aan in de service en controller voor het ophalen van 1 plaats, de creatie en update van een plaats

## Creatie TransactionService

De volgende service die we gaan maken is de `TransactionService`. Deze service bevat de basis CRUD-methoden voor transacties. Alvorens we deze implementeren, maken we als oefening eerst de controller en de bijhorende DTO's aan.

### Oefening - TransactionController

Definieer een nieuwe module `TransactionModule` en een controller `TransactionController` met de volgende routes:

- `GET /transactions` - Haal alle transacties op
- `GET /transactions/:id` - Haal een transactie op basis van zijn id
- `POST /transactions` - Maak een nieuwe transactie aan
- `PUT /transactions/:id` - Werk een bestaande transactie bij
- `DELETE /transactions/:id` - Verwijder een transactie

Laat alle routes momenteel nog een `Error` gooien met de boodschap "Not implemented".

Maak ook de bijhorende DTO's aan in `src/transactions/transaction.dto.ts`.

- Oplossing +

  Maak eerst een nieuwe module aan:

  ```bash
  pnpm nest g module transaction
  ```

  Maak vervolgens de controller aan:

  ```bash
  pnpm nest g controller transaction --no-spec
  ```

  Controleer of deze controller in de `TransactionModule` gedefinieerd werd (in de `controllers` array).

  Maak vervolgens het DTO bestand aan:

  ```ts
  // src/transactions/transaction.dto.ts
  import { PlaceResponseDto } from '../place/place.dto';
  import { PublicUserResponseDto } from '../user/user.dto';

  export class TransactionListResponseDto {
    items: TransactionResponseDto[];
  }

  export class TransactionResponseDto {
    id: number;
    amount: number;
    date: Date;
    user: PublicUserResponseDto;
    place: PlaceResponseDto;
  }

  export class CreateTransactionRequestDto {
    placeId: number;
    userId: number;
    amount: number;
    date: Date;
  }

  export class UpdateTransactionRequestDto extends CreateTransactionRequestDto {}
  ```

  Importeer de `PublicUserResponseDto` in `src/transactions/transaction.dto.ts`.

  Definieer tot slot de routes in de controller:

  ```ts
  // src/transactions/transaction.controller.ts
  import {
    Body,
    Controller,
    Delete,
    Get,
    HttpCode,
    HttpStatus,
    Param,
    ParseIntPipe,
    Post,
    Put,
  } from '@nestjs/common';
  import {
    CreateTransactionRequestDto,
    UpdateTransactionRequestDto,
    TransactionResponseDto,
    TransactionListResponseDto,
  } from './transaction.dto';

  @Controller('transactions')
  export class TransactionController {
    @Get()
    async getAllTransactions(): Promise<TransactionListResponseDto> {
      throw new Error('Not implemented');
    }

    @Post()
    async createTransaction(
      @Body() createTransactionDto: CreateTransactionRequestDto,
    ): Promise<TransactionResponseDto> {
      throw new Error('Not implemented');
    }

    @Get(':id')
    async getTransactionById(
      @Param('id') id: string,
    ): Promise<TransactionResponseDto> {
      throw new Error('Not implemented');
    }

    @Put(':id')
    async updateTransaction(
      @Param('id') id: string,
      @Body() updateTransactionDto: UpdateTransactionRequestDto,
    ): Promise<TransactionResponseDto> {
      throw new Error('Not implemented');
    }

    @Delete(':id')
    @HttpCode(HttpStatus.NO_CONTENT)
    async deleteTransaction(@Param('id') id: string): Promise<void> {
      throw new Error('Not implemented');
    }
  }
  ```

### Oefening - TransactionService

Maak een `TransactionService` aan met de nodige methoden (zie vorige oefening). Je mag de methoden voorlopig nog een `Error` laten gooien met de boodschap "Not implemented".

- Oplossing +

  Maak een nieuwe service aan:

  ```bash
  pnpm nest g service transaction --no-spec
  ```

  Controleer of deze service in de `TransactionModule` gedefinieerd werd (in de `providers` array). Exporteer de service ook in de `TransactionModule`.

  Definieer vervolgens de methoden in de service:

  ```ts
  import { Injectable } from '@nestjs/common';
  import {
    CreateTransactionRequestDto,
    TransactionListResponseDto,
    TransactionResponseDto,
    UpdateTransactionRequestDto,
  } from './transaction.dto';

  @Injectable()
  export class TransactionService {
    async getAll(): Promise<TransactionListResponseDto> {
      throw new Error('Not implemented');
    }

    async getById(id: number): Promise<TransactionResponseDto> {
      throw new Error('Not implemented');
    }

    async create(
      dto: CreateTransactionRequestDto,
    ): Promise<TransactionResponseDto> {
      throw new Error('Not implemented');
    }

    async updateById(
      id: number,
      { amount, date, placeId, userId }: UpdateTransactionRequestDto,
    ): Promise<TransactionResponseDto> {
      throw new Error('Not implemented');
    }

    async deleteById(id: number): Promise<void> {
      throw new Error('Not implemented');
    }
  }
  ```

## Implementatie TransactionService

In de vorige oefening hebben we de `TransactionService` aangemaakt met de nodige methoden. We gaan nu een aantal van deze methoden implementeren om te tonen hoe we de relaties in Drizzle kunnen gebruiken.

### getAll

Als eerst voorbeeld vullen we de methode `getAll` in de `TransactionService` aan:

```ts
// src/transactions/transaction.service.ts
// ...
import {
  type DatabaseProvider,
  InjectDrizzle,
} from '../drizzle/drizzle.provider';

export class TransactionService {
  // 👇 1
  constructor(
    @InjectDrizzle()
    private readonly db: DatabaseProvider,
  ) {}

  async getAll(): Promise<TransactionListResponseDto> {
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

Importeer de `DrizzleModule` in de `TransactionModule` om de Drizzle provider te kunnen gebruiken:

```ts
import { Module } from '@nestjs/common';
import { TransactionController } from './transaction.controller';
import { TransactionService } from './transaction.service';
import { DrizzleModule } from '../drizzle/drizzle.module'; // 👈

@Module({
  imports: [DrizzleModule], // 👈
  controllers: [TransactionController],
  providers: [TransactionService],
  exports: [TransactionService],
})
export class TransactionModule {}
```

Injecteer de `TransactionService` en roep deze methode in de `TransactionController` aan:

```ts
// src/transactions/transaction.controller.ts
import { TransactionService } from './transaction.service';

@Controller('transactions')
export class TransactionController {
  constructor(private transactionService: TransactionService) {} // 👈

  @Get()
  async getAllTransactions(): Promise<TransactionListResponseDto> {
    return this.transactionService.getAll(); // 👈
  }
}
```

### Oefening - getById

Vul de methode `getById` in de `TransactionService` aan. Hierbij willen we de transaction ophalen samen met de bijhorende user en place.

Roep deze methode in de `TransactionController` aan.

- Oplossing +

  Vul de methode `getById` in de `TransactionService` aan:

  ```ts
  // src/transactions/transaction.service.ts
  import { Injectable, NotFoundException } from '@nestjs/common';
  import { eq } from 'drizzle-orm';
  import { transactions } from '../drizzle/schema';

  async getById(id: number): Promise<TransactionResponseDto> {
    const transaction = await this.db.query.transactions.findFirst({
      columns: {
        id: true,
        amount: true,
        date: true,
      },
      where: eq(transactions.id, id),
      with: {
        place: true,
        user: true,
      },
    });

    if (!transaction) {
      throw new NotFoundException(`No transaction with this id exists`);
    }

    return transaction;
  }
  ```

  Roep deze methode in de `TransactionController` aan:

  ```ts
  // src/transactions/transaction.controller.ts
  @Get(':id')
  async getTransactionById(
    @Param('id') id: string,
  ): Promise<TransactionResponseDto> {
    return this.transactionService.getById(Number(id)); // 👈
  }
  ```

### create

Vul de methode `create` in de `TransactionService` aan. Hierbij willen we een nieuwe transaction aanmaken en deze nieuwe transactie vervolgens teruggeven.

```ts
// src/transactions/transaction.service.ts
async create(dto: CreateTransactionRequestDto): Promise<TransactionResponseDto> {
  const [newTransaction] = await this.db
    .insert(transactions)
    .values({
      ...dto,
      date: new Date(dto.date),
    })
    .$returningId();

  return this.getById(newTransaction.id);
}
```

Voorlopig moeten we de `date` kolom manueel omzetten naar een `Date` object. Wanneer we invoervalidatie toevoegen kunnen we dit automatisch laten doen.

Merk op dat je in MySQL de `$returningId()` functie moet gebruiken om de id van de nieuw aangemaakte rij op te halen. Je hebt geen mogelijkheid om de volledige transactie terug te krijgen. PostgreSQL heeft wel een `$returning()` functie waarmee je de volledige rij kan terugkrijgen. Daarom roepen we hierna de `getById` methode aan om de volledige transactie op te halen en terug te geven.

Roep deze methode in de `TransactionController` aan:

```ts
// src/transactions/transaction.controller.ts
@Post()
async createTransaction(
  @Body() createTransactionDto: CreateTransactionRequestDto,
): Promise<TransactionResponseDto> {
  return this.transactionService.create(createTransactionDto);
}
```

### deleteById

Als laatste voorbeeld implementeren we de `deleteById` methode in de `TransactionService`:

```ts
// src/transactions/transaction.service.ts

async deleteById(id: number): Promise<void> {
  const [result] = await this.db
    .delete(transactions)
    .where(eq(transactions.id, id));

  if (result.affectedRows === 0) {
    throw new NotFoundException('No transaction with this id exists');
  }
}
```

Roep deze methode in de `TransactionController` aan:

```ts
// src/transactions/transaction.controller.ts

@Delete(':id')
@HttpCode(HttpStatus.NO_CONTENT)
async deleteTransaction(
  @Param('id') id: string,
): Promise<void> {
  return this.transactionService.deleteById(Number(id));
}
```

### Oefening - updateById

Vul de methode `updateById` in de `TransactionService` aan. Hierbij willen we een bestaande transactie bijwerken en deze bijgewerkte transactie vervolgens teruggeven.

Roep deze methode in de `TransactionController` aan.

- Oplossing +

  Vul de methode `updateById` in de `TransactionService` aan:

  ```ts
  // src/transactions/transaction.service.ts
  // ...
  import { eq, and } from 'drizzle-orm';

  async updateById(
    id: number,
    { amount, date, placeId, userId }: UpdateTransactionRequestDto,
  ): Promise<TransactionResponseDto> {
    await this.db
      .update(transactions)
      .set({
        amount,
        date: new Date(date),
        placeId,
      })
      .where(and(eq(transactions.id, id), eq(transactions.userId, userId)));

    return this.getById(id);
  }
  ```

  Roep deze methode in de `TransactionController` aan:

  ```ts
  // src/transactions/transaction.controller.ts
  @Put(':id')
  async updateTransaction(
    @Param('id') id: string,
    @Body() updateTransactionDto: UpdateTransactionRequestDto,
  ): Promise<TransactionResponseDto> {
    return this.transactionService.updateById(
      Number(id),
      updateTransactionDto,
    );
  }
  ```

## Favorite places

We gaan nu de `PlaceService` uitbreiden met een methode om de favoriete places van een user op te halen.

### Best practices tussentabellen

De favoriete places worden bewaard in een tussentabel tussen user en place. Bij het gebruik van tussentabellen in een REST API moet je rekening houden met een aantal best practices. Hier worden door studenten, en in bedrijven, heel wat fouten tegen gemaakt. Hou bijgevolg steeds rekening met deze twee best practices:

- Maak nooit een service voor de tussentabel. Bevraag deze altijd via één van de entiteiten, in ons geval de user of de place.
  - In ons geval mogen we dus geen service `UserFavoritePlacesService` voorzien.
- Maak nooit een controller voor de tussentabel. Voorzie altijd routes in de controller van één van de entiteiten, in ons geval opnieuw de user en de place.
  - In ons geval mogen we dus geen route `/api/userfavoriteplaces` voorzien.

!> Let goed op het correct gebruik van tussentabellen! Er worden typisch heel wat fouten tegen gemaakt in de examenopdracht.

### Implementatie

```ts
// src/place/place.service.ts
import { userFavoritePlaces } from '../drizzle/schema';

async getFavoritePlacesByUserId(userId: number): Promise<PlaceResponseDto[]> {
  const favoritePlaces = await this.db.query.userFavoritePlaces.findMany({
    where: eq(userFavoritePlaces.userId, userId),
    with: { place: true },
  });
  return favoritePlaces.map((fav) => fav.place);
}
```

Om de favoriete places van een user op te halen, maken we gebruik van de tussentabel `user_favorite_places`. We filteren op `userId` en laden de bijbehorende place met `with: { place: true }`. Vervolgens mappen we de resultaten om enkel de places terug te geven.

Maak vervolgens een `UserModule` met bijbehorende `UserController` aan:

```bash
pnpm nest g module user
pnpm nest g controller user --no-spec
```

Definieer in de `UserController` een route om de favoriete places van een user op te halen:

```ts
// src/user/user.controller.ts
import { Controller, Get, Param } from '@nestjs/common';
import { PlaceService } from '../place/place.service';
import { PlaceResponseDto } from '../place/place.dto';

@Controller('users')
export class UserController {
  constructor(private placeService: PlaceService) {} // 👈 1

  // 👇 2
  @Get('/:id/favoriteplaces')
  async getFavoritePlaces(
    @Param('id') id: string,
  ): Promise<PlaceResponseDto[]> {
    return await this.placeService.getFavoritePlacesByUserId(Number(id));
  }
}
```

1. We injecteren de `PlaceService` in de constructor van de `UserController`.
2. We definiëren een `GET` route `/users/:id/favoriteplaces` om de favoriete places van een user op te halen.
3. We roepen de `getFavoritePlacesByUserId` methode van de `PlaceService` aan om de favoriete places op te halen.

Importeer de `PlaceModule` in de `UserModule` om de `PlaceService` te kunnen gebruiken

## Oefening - UserService

Definieer de overige endpoints in de `UserController`:

- `GET /users` - Haal alle users op
- `GET /users/:id` - Haal een user op basis van zijn id
- `POST /users` - Maak een nieuwe user aan
- `PUT /users/:id` - Werk een bestaande user bij
- `DELETE /users/:id` - Verwijder een user

Maak een `UserService` aan met de nodige methoden (getAll, getById, create, update, delete). Implementeer deze methoden. Voorzie ook de nodige DTO's.

Definieer de `UserService` en de `UserController` in de `UserModule`, exporteer enkel de service.

- Oplossing +

  De oplossing vind je in onze voorbeeldapplicatie in commit `d486627`.

> **Oplossing voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les5-opl b1ed447
> pnpm install
> pnpm db:migrate
> pnpm start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.
