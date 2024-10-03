# Authenticatie en autorisatie

<!-- TODO: startpunt en oplossing toevoegen -->

## Jest

### Configuratie

Om betere coverage uitvoer te krijgen, passen we nog een aantal parameters aan in `jest.config.ts`:

```ts
// jest.config.ts
{
  // ...
  collectCoverageFrom: [
    './src/repository/**/*.ts',
    './src/service/**/*.ts',
    './src/rest/**/*.ts',
  ],
  coverageDirectory: '__tests__/coverage'
  // ...
}
```

- `collectCoverageFrom`: mappen waarvan we coverage willen zien. Hier enkel van de service en rest mappen - de rest is niet zo belangrijk. Je kan dit aanpassen naar eigen wensen.
- `coverageDirectory`: map waar de coverage opgeslagen moet worden. Standaard komt dit in de root van je project terecht, we verplaatsen dit naar de map `__tests__`.

### Refactoring

Als eerste abstraheren we het starten en stoppen van de server zodat dit eenvoudig herbruikbaar is in de verschillende test suites. Maak een bestand `withServer.ts` in een nieuwe map `helpers`:

```ts
// __tests__/helpers/withServer.ts
import supertest from 'supertest'; // 👈 1
import type { Server } from '../../src/createServer'; // 👈 2
import createServer from '../../src/createServer'; // 👈 3
import { prisma } from '../../src/data'; // 👈 4
import { hashPassword } from '../../src/core/password'; // 👈 4
import Role from '../../src/core/roles'; // 👈 4

// 👇 1
export default function withServer(setter: (s: supertest.Agent) => void): void {
  let server: Server; // 👈 2

  beforeAll(async () => {
    server = await createServer(); // 👈 3

    // 👇 4
    const passwordHash = await hashPassword('12345678');
    await prisma.user.createMany({
      data: [
        {
          id: 1,
          name: 'Test User',
          email: 'test.user@hogent.be',
          password_hash: passwordHash,
          roles: JSON.stringify([Role.USER]),
        },
        {
          id: 2,
          name: 'Admin User',
          email: 'admin.user@hogent.be',
          password_hash: passwordHash,
          roles: JSON.stringify([Role.ADMIN, Role.USER]),
        },
      ],
    });

    // 👇 5
    setter(supertest(server.getApp().callback()));
  });

  afterAll(async () => {
    // 👇 6
    await prisma.transaction.deleteMany();
    await prisma.user.deleteMany();
    await prisma.place.deleteMany();

    // 👇 7
    await server.stop();
  });
}

// 👇 6
const login = async (supertest) => {
  // 👇 7
  const response = await supertest.post('/api/users/login').send({
    email: 'test.user@hogent.be',
    password: '12345678',
  });

  // 👇 8
  if (response.statusCode !== 200) {
    throw new Error(response.body.message || 'Unknown error occured');
  }

  return `Bearer ${response.body.token}`; // 👈 9
};

const withServer = (setter) => {
  // 👈 4
  let server;

  beforeAll(async () => {
    server = await createServer();

    setter({
      knex: getKnex(),
      supertest: supertest(server.getApp().callback()),
    });
  });

  afterAll(async () => {
    await server.stop();
  });
};

module.exports = {
  login,
  withServer,
}; // 👈 1 en 6
```

1. Definieer en exporteer hierin een functie `withServer`. Deze heeft als taak om de juiste lifecycle hooks van Jest aan te roepen om de server starten/stoppen.
2. Maak een variabele om de server bij te houden (binnen de functie).
3. En maak een nieuwe server in de `beforeAll`.
4. We voegen ook meteen een gewone gebruiker en een admin toe aan de databank. Dit is handig voor de testen.
5. Nu hebben we nog een probleem: hoe krijgen we de instantie van supertest uit de functie (we kunnen geen return doen in `beforeAll`). Oplossing: geef een soort `setter`-functie mee aan de `withServer` functie en roep deze aan met de instantie van supertest als parameter.
6. We verwijderen de gebruikers uit de databank na de testen.
7. We sluiten de server in de `afterAll`.

### Login helper

Vervolgens definiëren we een helper-functie om de toegevoegde gewone gebruiker aan te melden. Maak een bestand `__tests__/helper/login.ts`:

```ts
// __tests__/helpers/login.ts
import type supertest from 'supertest';

export const login = async (supertest: supertest.Agent): Promise<string> => {
  const response = await supertest.post('/api/users/login').send({
    email: 'test.user@hogent.be',
    password: '12345678',
  });

  if (response.statusCode !== 200) {
    throw new Error(response.body.message || 'Unknown error occured');
  }

  return `Bearer ${response.body.token}`;
};
```

1. De functie `login` kunnen we gebruiken om aan te melden voor elke test. Deze functie krijgt de juiste instantie van supertest mee als argument.
2. We voeren het `POST /api/users/login` request uit met de juiste testdata. Herinner je: die wordt toegevoegd door de `withServer` functie.
3. Als het geen succesvol request was, dan gooien we een error. De error zal onze test(s) laten falen, in de meeste gevallen is dit een hele test suite.
4. We retourneren de correct geformatteerde `Authorization` header.

### Oefening 1 - Login admin helper

Definieer een helper genaamd `loginAdmin` die hetzelfde doet voor de administrator. Je kan er ook voor opteren om de `login` functie aan te passen zodat je een parameter kan meegeven voor de email en het wachtwoord.

- Oplossing +

  Voeg onderstaande code toe aan `__tests__/helpers/login.ts`:

  ```ts
  // __tests__/helpers/login.ts
  // ...
  export const loginAdmin = async (
    supertest: supertest.Agent,
  ): Promise<string> => {
    const response = await supertest.post('/api/users/login').send({
      email: 'admin.user@hogent.be',
      password: '12345678',
    });

    if (response.statusCode !== 200) {
      throw new Error(response.body.message || 'Unknown error occured');
    }

    return `Bearer ${response.body.token}`;
  };
  ```

## Test: unauthorized

We voegen een functie toe die de nagaat of voor een bepaalde URL de juiste statuscode geretourneerd wordt als de gebruiker niet is aangemeld of een ongeldig token wordt verstuurd. Aangezien deze testen voor elk van de endpoints dienen te gebeuren maken we hiervoor een aparte module aan in `__tests__/helpers/testAuthHeader.ts`:

```ts
// __tests__/helpers/testAuthHeader.ts
import type supertest from 'supertest';

// 👇 1
export default function testAuthHeader(requestFactory: () => supertest.Test) {
  // 👇 2
  test('it should 401 when no authorization token provided', async () => {
    const response = await requestFactory();

    expect(response.statusCode).toBe(401);
    expect(response.body.code).toBe('UNAUTHORIZED');
    expect(response.body.message).toBe('You need to be signed in');
  });

  // 👇 3
  test('it should 401 when invalid authorization token provided', async () => {
    const response = await requestFactory().set(
      'Authorization',
      'INVALID TOKEN',
    );

    expect(response.statusCode).toBe(401);
    expect(response.body.code).toBe('UNAUTHORIZED');
    expect(response.body.message).toBe('Invalid authentication token');
  });
}
```

1. De functie heeft één parameter, nl. een `requestFactory`. Deze factory functie moet het request voor een bepaalde HTTP methode en URL creëren. Op die manier kunnen we onze testen voor eender welk request gebruiken, het is de taak van de factory om het juiste request te maken.
2. De eerste test controleert het retourneren van een statuscode 401 als de gebruiker niet is aangemeld en hierdoor niet gemachtigd is om het endpoint te bevragen.
3. De tweede test controleert het retourneren van een statuscode 401 als een ongeldig token wordt meegestuurd en de gebruiker hierdoor niet gemachtigd is om het endpoint te bevragen.

## Transaction testen

We zullen ervoor zorgen dat de testen voor onze transacties terug slagen. Pas hiervoor `__tests__/rest/transactions.spec.ts` aan:

```ts
// __tests__/rest/transactions.spec.ts
// ...
import withServer from '../helpers/withServer'; // 👈 2
import { login } from '../helpers/login'; // 👈 3
import testAuthHeader from '../helpers/testAuthHeader'; // 👈 5

// ...
const data = {
  // ...
  // 👇 1
  // users: [
  //   {
  //     id: 1,
  //     name: 'Test User',
  //   },
  // ],
};

const dataToDelete = {
  // ...
  // users: [1]  👈 1
};

describe('Transactions', () => {
  // ...
  let authHeader: string; // 👈 3

  // 👇 2
  withServer((r) => (request = r));

  beforeAll(async () => {
    /* 👇 2
    server = await createServer();
    request = supertest(server.getApp().callback());
    knex = getKnex();
    */
    authHeader = await login(request); // 👈 3
  });

  /* 👇 2
  afterAll(async () => {
    await server.stop();
  });
  */

  // ...

  describe('GET /api/transactions', () => {
    // ...

    test('it should 200 and return all transactions', async () => {
      // 👇 4
      const response = await request.get(url).set('Authorization', authHeader);

      // expects hier
    });
  });
  // ...

  testAuthHeader(() => request.get(url)); // 👈 5
});
```

1. Verwijder alle dummy data van users. Verwijder ook alle code die met Knex gebruikers toevoegt of verwijdert.
2. Gebruik de nieuwe `withServer` helper om de server te starten. Stel via de `setter` de variabele `request` in. Vergeet de imports niet op te ruimen.
3. Gebruik nu de `login` helper om aan te melden. De `login` header houden we bij voor later.
4. Voeg aan elk request deze login header toe.
5. Voeg ook de testen toe die controleren of de juiste statuscode geretourneerd wordt als een gebruiker niet geauthenticeerd of geautoriseerd is. Voeg dit toe aan elke test suite van de verschillende endpoints.

### Oefening 2 - Testen afwerken

Herhaal hetzelfde voor alle andere testen van transactions, places en users:

- Voeg de login header toe.
- Pas de requests, indien nodig, aan. Bij sommige hoef je bv. het `userId` niet meer mee te geven.
- Test voor elke URL of de juiste statuscode geretourneerd wordt als een gebruiker niet geauthenticeerd of geautoriseerd is.
- Let bij er de testen van gebruikers op dat je de gebruikers die je nodig hebt om aan te melden niet verwijdert.

<br/>

- Oplossing +

  TODO: voorbeeldoplossing toevoegen
