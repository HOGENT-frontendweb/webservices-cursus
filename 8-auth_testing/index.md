# Authenticatie en autorisatie

> **Startpunt voorbeeldapplicatie**
>
> Het volstaat om uit te checken op de `authenticatie` branch en op commit `4fc1d12`
>
> ```bash
> git clone https://github.com/HOGENT-Web/webservices-budget.git
> cd webservices-budget
> git checkout -b les8 4fc1d12
> yarn install
> yarn start
> ```

## Jest

### Configuratie

Om betere coverage uitvoer te krijgen, passen we nog een aantal parameters aan in `jest.config.js`:

```js
collectCoverageFrom: [
  './src/repository/**/*.js',
  './src/service/**/*.js',
  './src/rest/**/*.js',
],
coverageDirectory: '__tests__/coverage'
```

- `collectCoverageFrom`: mappen waarvan we coverage willen zien. Hier enkel van de repository, service en rest mappen - de rest is niet zo belangrijk.
- `coverageDirectory`: map waar de coverage opgeslagen moet worden. Standaard komt dit in de root van je project terecht, we verplaatsen dit naar de map `__tests__`.

### Globale setup

Voor elk van onze testen moeten we aangemeld zijn, dus dan zou het handig zijn als we altijd een paar users beschikbaar hebben in de databank. Daarvoor hebben we **global setup** nodig. Dit wordt uitgevoerd alvorens één test suite uitgevoerd wordt, dit is dus perfect voor het toevoegen van test data zoals gebruikers om aan te melden.

Maak een bestand `__tests__/global.setup.js` met volgende inhoud:

<!-- cSpell: disable -->
```js
const config = require('config'); // 👈 2
const { initializeLogger } = require('../src/core/logging'); // 👈 2
const Role = require('../src/core/roles'); // 👈 4
const { initializeData, getKnex, tables } = require('../src/data'); // 👈 3 en 4

// 👇 1
module.exports = async () => {
  // Create a database connection
  initializeLogger(config.get('log.level'), config.get('log.disabled')); // 👈 2
  await initializeData(); // 👈 3

  // Insert a test user with password 12345678
  const knex = getKnex(); // 👈 3

  // 👇 4
  await knex(tables.user).insert([
    {
      id: 1,
      name: 'Test User',
      email: 'test.user@hogent.be',
      password_hash:
        '$argon2id$v=19$m=2048,t=2,p=1$NF6PFLTgSYpDSex0iFeFQQ$Rz5ouoM9q3EH40hrq67BC3Ajsu/ohaHnkKBLunELLzU',
      roles: JSON.stringify([Role.USER]),
    },
    {
      id: 2,
      name: 'Admin User',
      email: 'admin.user@hogent.be',
      password_hash:
        '$argon2id$v=19$m=2048,t=2,p=1$NF6PFLTgSYpDSex0iFeFQQ$Rz5ouoM9q3EH40hrq67BC3Ajsu/ohaHnkKBLunELLzU',
      roles: JSON.stringify([Role.ADMIN, Role.USER]),
    },
  ]);
};
```
<!-- cSpell: enable -->

1. Maak een bestand `global.setup.js` in de `__tests__` map. We moeten een async functie, die de globale setup bevat, exporteren.
2. We moeten eerst de logging initialiseren want op dit punt hebben we nog geen server.
3. Dan maken we een connectie met de databank en halen we onze instantie van Knex op.
4. Vervolgens voegen we twee gebruikers toe: een gewone gebruiker en een admin. Beiden met wachtwoord `12345678`.
5. Als laatste stellen we `globalSetup` van `jest.config.js` in met het pad naar dit bestand: `./__tests__/global.setup.js`. Haal dit property uit commentaar!

### Globale teardown

We moeten nu ook de geopende databank-connectie sluiten, anders zal Jest nooit afsluiten aangezien er nog een resource in gebruik is.

Maak een bestand `__tests__/global.teardown.js`:

```js
const { shutdownData, getKnex, tables } = require('../src/data'); // 👈 2 en 3

// 👇 1
module.exports = async () => {
  // Remove any leftover data
  await getKnex()(tables.transaction).delete(); // 👈 2
  await getKnex()(tables.user).delete(); // 👈 2
  await getKnex()(tables.place).delete(); // 👈 2

  // Close database connection
  await shutdownData(); // 👈 3
};
```

1. We exporteren opnieuw een functie die onze globale teardown (of "opruimcode") bevat.
2. We verwijderen alle data uit de tabellen, moest die er nog zijn. Dit voorkomt dat de testen nadien falen door niet opgeruimde data van bepaalde test suites.
3. Sluit de databank-connectie.
4. Als laatste stellen we `globalTeardown` van `jest.config.js` in met het pad naar dit bestand: `./__tests__/global.teardown.js`. Haal dit property uit commentaar!

### Refactoring

Als laatste abstraheren we het starten en stoppen van de server zodat we dit eenvoudig herbruikbaar is in de verschillende test suites. Maak een bestand `supertest.setup.js` in de map `__tests__`:

```js
const supertest = require('supertest'); // 👈 4
const createServer = require('../src/createServer'); // 👈 3
const { getKnex } = require('../src/data'); // 👈 4

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

// 👇 1
const withServer = (setter) => { // 👈 4
  let server; // 👈 2

  beforeAll(async () => {
    server = await createServer(); // 👈 3

    // 👇 4
    setter({
      knex: getKnex(),
      supertest: supertest(server.getApp().callback()),
    });
  });

  afterAll(async () => {
    await server.stop(); // 👈 5
  });
};

module.exports = {
  login,
  withServer,
}; // 👈 1 en 6
```

1. Definieer en exporteer hierin een functie `withServer`. Deze heeft als taak om de juiste lifecycle hooks van Jest aan te roepen om de server starten/stoppen.
2. Maak een variabele om de server bij te houden (binnen de functie).
3. En maak een nieuwe server in de `beforeAll`. Nu hebben we nog een probleem: hoe krijgen we de instantie van Knex en supertest uit de functie (we kunnen geen return doen in `beforeAll`).
4. Geef een soort `setter`-functie mee aan de `withServer` functie en roep deze aan met de juiste instanties.
5. We sluiten de server in de `afterAll`.
6. Als laatste schrijven we nog een helper-functie `login` waarmee we kunnen aanmelden voor elke test. Deze functie krijgt de juiste instantie van supertest mee als argument.
7. We voeren het `POST /api/users/login` request uit met de juiste testdata. Herinner je: die wordt toegevoegd door de `global.setup.js`.
8. Als het geen succesvol request was, dan gooien we een error. De error zal onze test(s) laten falen, in de meeste gevallen is dit een hele test suite.
9. We retourneren de correct geformatteerde `Authorization` header.

### Oefening 1 - Login admin helper

Definieer een helper genaamd `loginAdmin` die hetzelfde doet voor de admin user.

<!-- markdownlint-disable-next-line -->
+ Oplossing +

  Voeg onderstaande code toe aan `__tests__/supertest.setup.js`:

  ```js
  // ...
  const loginAdmin = async (supertest) => {
    const response = await supertest.post('/api/users/login').send({
      email: 'admin.user@hogent.be',
      password: '12345678',
    });

    if (response.statusCode !== 200) {
      throw new Error(response.body.message || 'Unknown error occured');
    }

    return `Bearer ${response.body.token}`;
  };
  // ...
  module.exports = {
    // ...
    loginAdmin,
  };
  ```

## Test: unauthorized

We voegen een module toe die de nagaat of voor een bepaalde URL de juiste statuscode geretourneerd wordt als de gebruiker niet is aangemeld of een ongeldig token wordt verstuurd. Aangezien deze testen voor elk van de endpoints dienen te gebeuren maken we hiervoor een aparte module aan in `__tests__/common/auth.js`:

```js
// 👇 1
const testAuthHeader = (requestFactory) => {
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
      'INVALID TOKEN'
    );

    expect(response.statusCode).toBe(401);
    expect(response.body.code).toBe('UNAUTHORIZED');
    expect(response.body.message).toBe('Invalid authentication token');
  });
};

module.exports = {
  testAuthHeader,
};
```

1. De functie heeft 1 parameter, nl. een `requestFactory`. Deze factory functie moet het request voor een bepaalde HTTP methode en URL creëren. Op die manier kunnen we onze test voor eender welk request gebruiken, het is de taak van de factory om het juiste request te maken.
2. De eerste test controleert het retourneren van een statuscode 401 als de gebruiker niet is aangemeld en hierdoor niet gemachtigd is om het endpoint te bevragen.
3. De tweede test controleert het retourneren van een statuscode 401 als een ongeldig token wordt meegestuurd en de gebruiker hierdoor niet gemachtigd is om het endpoint te bevragen.

## Transaction testen

We zullen ervoor zorgen dat de testen voor onze transacties terug slagen. Pas hiervoor `__tests__/rest/transactions.spec.js` aan:

```js
// ...
const { withServer, login } = require('../supertest.setup'); // 👈 2 en 3
const { testAuthHeader } = require('../common/auth'); // 👈 5

// ...
const data = {
  // ...
  // 👇 1
  /*
  users: [{
    id: '7f28c5f9-d711-4cd6-ac15-d13d71abff80',
    name: 'Test User'
  }]
  */
};

const dataToDelete = {
  // ...
  //users: ['7f28c5f9-d711-4cd6-ac15-d13d71abff80']  👈 1
};

describe('Transactions', () => {
  // let server; 👈 2
  let request, knex, authHeader; // 👈 3

  // 👇 2
  withServer(({
    supertest,
    knex: k,
  }) => {
    request = supertest;
    knex = k;
  });

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
      const response = await request.get(url)
        .set('Authorization', authHeader); // 👈 4

      // expects hier
    });
  });
  // ...

  testAuthHeader(() => request.get(url));// 👈 5
});
```

1. Verwijder alle dummy data van users. Verwijder ook alle code die met Knex gebruikers toevoegt of verwijdert.
2. Gebruik de nieuwe `withServer` helper om de server te starten. Stel via de `setter` knex en request in. Vergeet de imports niet op te ruimen.
3. Gebruik nu de `login` helper om aan te melden. De `login` header houden we bij voor later.
4. Voeg aan elk request deze login header toe.
5. Voeg ook de testen toe die controleren of de juiste statuscode geretourneerd wordt als een gebruiker niet geauthenticeerd of geautoriseerd is. Voeg dit toe aan elke test suite van de verschillende endpoints.

### Oefening 2 - Testen afwerken

Herhaal hetzelfde voor alle andere testen van transactions, places en users:

- Voeg de login header toe.
- Pas de requests, indien nodig, aan, bv. bij sommige hoef je het `userId` niet meer mee te geven.
- Test voor elke URL of de juiste statuscode geretourneerd wordt als een gebruiker niet geauthenticeerd of geautoriseerd is.
- Let bij de testen van gebruikers op dat je de gebruikers die je nodig hebt om aan te melden niet verwijdert.

<!-- markdownlint-disable-next-line -->
+ Oplossing +

  Een voorbeeldoplossing is te vinden op <https://github.com/HOGENT-Web/webservices-budget> in de branch `authenticatie`

  ```bash
  git clone https://github.com/HOGENT-Web/webservices-budget.git
  git checkout -b authenticatie-testen origin/authenticatie
  yarn install
  yarn start
  ```
