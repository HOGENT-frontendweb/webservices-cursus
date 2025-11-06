# Testen: authenticatie en autorisatie (WIP)

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les8 42e1886
> yarn install
> yarn prisma migrate dev
> yarn start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.

In dit hoofdstuk zullen we ervoor zorgen dat onze testen terug slagen. We zullen hiervoor authenticatie en autorisatie toevoegen aan alle testen.

## Jest

Allereerst passen we een aantal dingen aan in Jest. We willen een betere output van de coverage en voorzien een aantal helpers om de testen te vereenvoudigen.

### Configuratie

Om betere coverage uitvoer te krijgen, passen we nog een aantal parameters aan in `jest.config.ts`:

```ts
// jest.config.ts
{
  // ...
  collectCoverageFrom: [
    './src/service/**/*.ts',
    './src/rest/**/*.ts',
  ],
  coverageDirectory: '__tests__/coverage'
  // ...
}
```

- `collectCoverageFrom`: mappen waarvan we coverage willen zien. Hier enkel van de service en rest mappen - de overige mappen zijn niet zo belangrijk. Je kan dit aanpassen naar eigen wensen.
- `coverageDirectory`: map waar de coverage opgeslagen moet worden. Standaard komt dit in de root van je project terecht, we verplaatsen dit naar de map `__tests__`.
  - Deze map mag niet op GitHub komen, deze wordt automatisch gegenereerd.

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
```

1. Definieer en exporteer hierin een functie `withServer`. Deze heeft als taak om de juiste lifecycle hooks van Jest aan te roepen om de server starten/stoppen.
2. Maak een variabele om de server bij te houden (binnen de functie).
3. En maak een nieuwe server in de `beforeAll`.
4. We voegen ook meteen een gewone gebruiker en een admin toe aan de databank. Dit is handig voor de testen.
   - Hier voeg je best enkel testdata toe die je in **elke** test suite nodig hebt. Testdata die je enkel in één test (suite) nodig hebt, voeg je best toe in de test (suite) zelf.
5. Nu hebben we nog een probleem: hoe krijgen we de instantie van supertest uit de functie (we kunnen geen return doen in `beforeAll`).
   - Oplossing: geef een soort `setter`-functie mee aan de `withServer` functie en roep deze aan met de instantie van supertest als parameter.
6. We verwijderen alle data uit de databank in de `afterAll`. Dit is belangrijk om te voorkomen dat test suites elkaar beïnvloeden.
   - Je kan ook argumenteren om enkel de aangemaakte gebruikers te verwijderen. Op die manier moet elke test (suite) de eigen data verwijderen.
7. We sluiten de server in de `afterAll`.

### Login helper

Vervolgens definiëren we een helper-functie om de toegevoegde gewone gebruiker aan te melden. Maak een bestand `__tests__/helper/login.ts`:

```ts
// __tests__/helpers/login.ts
import type supertest from 'supertest';

// 👇 1
export const login = async (supertest: supertest.Agent): Promise<string> => {
  // 👇 2
  const response = await supertest.post('/api/sessions').send({
    email: 'test.user@hogent.be',
    password: '12345678',
  });

  // 👇 3
  if (response.statusCode !== 200) {
    throw new Error(response.body.message || 'Unknown error occured');
  }

  // 👇 4
  return `Bearer ${response.body.token}`;
};
```

1. De functie `login` kunnen we gebruiken om aan te melden voor elke test. Deze functie krijgt de juiste instantie van supertest mee als argument.
2. We voeren het `POST /api/users/login` request uit met de juiste testdata. Herinner je: die wordt toegevoegd door de `withServer` functie.
3. Als het geen succesvol request was, dan gooien we een error. De error zal onze test(s) laten falen, in de meeste gevallen is dit een hele test suite.
4. We retourneren de correct geformatteerde `Authorization` header.

### Oefening 1 - Login admin helper

Definieer een helper genaamd `loginAdmin` die hetzelfde doet voor de administrator. Je kan er ook voor opteren om de `login` functie aan te passen zodat je parameters kan meegeven voor het e-mailadres en het wachtwoord.

- Oplossing +

  Voeg onderstaande code toe aan `__tests__/helpers/login.ts`:

  ```ts
  // __tests__/helpers/login.ts
  // ...
  export const loginAdmin = async (
    supertest: supertest.Agent,
  ): Promise<string> => {
    const response = await supertest.post('/api/sessions').send({
      email: 'admin.user@hogent.be',
      password: '12345678',
    });

    if (response.statusCode !== 200) {
      throw new Error(response.body.message || 'Unknown error occured');
    }

    return `Bearer ${response.body.token}`;
  };
  ```

### Test unauthorized

Als laatste voegen we een functie toe die de nagaat of voor een bepaalde URL de juiste statuscode geretourneerd wordt als de gebruiker niet is aangemeld of een ongeldig token wordt verstuurd. Aangezien deze testen voor elk van de endpoints dienen te gebeuren maken we hiervoor een aparte functie aan in `__tests__/helpers/testAuthHeader.ts`:

```ts
// __tests__/helpers/testAuthHeader.ts
import type supertest from 'supertest';

// 👇 1
export default function testAuthHeader(
  requestFactory: () => supertest.Test,
): void {
  // 👇 2
  it('should 401 when no authorization token provided', async () => {
    const response = await requestFactory();

    expect(response.statusCode).toBe(401);
    expect(response.body.code).toBe('UNAUTHORIZED');
    expect(response.body.message).toBe('You need to be signed in');
  });

  // 👇 3
  it('should 401 when invalid authorization token provided', async () => {
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

Als eerste zullen we ervoor zorgen dat de testen voor onze transacties terug slagen. Pas hiervoor `__tests__/rest/transactions.spec.ts` aan:

```ts
// __tests__/rest/transactions.spec.ts
// ...
// import createServer from '../../src/createServer'; // 👈 2
// import type { Server } from '../../src/createServer'; // 👈 2
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
  let request: supertest.Agent;
  let authHeader: string; // 👈 3

  // 👇 2
  withServer((r) => (request = r));

  beforeAll(async () => {
    /* 👇 2
    server = await createServer();
    request = supertest(server.getApp().callback());
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

    it('it should 200 and return all transactions', async () => {
      // 👇 4
      const response = await request.get(url).set('Authorization', authHeader);

      // expects hier
    });

    testAuthHeader(() => request.get(url)); // 👈 5
  });
  // ...
});
```

1. Verwijder alle dummy data van users. Verwijder ook alle code die gebruikers toevoegt of verwijdert.
2. Gebruik de nieuwe `withServer` helper om de server te starten. Stel via de `setter` de variabele `request` in. Vergeet de imports niet op te ruimen. Deze functie moet voor de `beforeAll` hook komen. Verwijder ook de `createServer` en `Server` import, en de `server` variabele.
3. Gebruik nu de `login` helper om aan te melden. De `login` header houden we bij voor later.
4. Voeg aan elk request deze login header toe.
5. Voeg ook de testen toe die controleren of de juiste statuscode geretourneerd wordt als een gebruiker niet geauthenticeerd of geautoriseerd is.
6. Pas de PUT en POST requests aan: het `userId` moet niet langer worden opgegeven. Het `userId` van de aangemelde gebruiker wordt gebruikt.

Je kan enkel de testen voor de transacties uitvoeren door het volgende commando uit te voeren:

```bash
yarn test "./__tests__/rest/transactions.spec.ts"
```

?> Probeer test per test te doen slagen i.p.v. allemaal tegelijk. Dit maakt het makkelijker om fouten te vinden. Je kan gebruik maken van [`describe.only`](https://jestjs.io/docs/api#describeonlyname-fn) of [`it.only`](https://jestjs.io/docs/api#testonlyname-fn-timeout) gebruiken om enkel bepaalde test suites of testen uit te voeren. Dit geldt wel enkel binnen het huidige testbestand. Daarom is het handig om nu slechts één testbestand uit te voeren.

### Auth delay

Soms merk je misschien dat de testen falen omdat de maximale duur van een Jest hook (5 seconden) overschreden wordt. Dit kan gebeuren omdat de `auth.maxDelay` instelling in `config/testing.ts` nog te hoog ingesteld staat. Pas deze aan naar `0`, tijdens de testen is geen vertraging nodig.

### Oefening 2 - Testen afwerken

Herhaal hetzelfde voor alle andere testen van places en users:

- Voeg de login header toe.
- Pas de requests, indien nodig, aan.
- Test voor elke URL of de juiste statuscode geretourneerd wordt als een gebruiker niet geauthenticeerd of geautoriseerd is.
- Let bij er de testen van gebruikers op dat je de gebruikers die je nodig hebt om aan te melden niet verwijdert.

Vergeet ook niet om testen toe te voegen voor de `POST /api/sessions`.

Pas vervolgens de testen voor de transacties aan:

- `GET /api/transactions`: splits deze in twee:
  - retourneert alle transacties in het geval van een admin
  - in het andere geval enkel de transacties van de aangemelde gebruiker
- `GET /api/transactions/:id`: splits deze in twee:
  - retourneert eender welke transactie in het geval van een admin
  - in het andere geval enkel als de transactie van de aangemelde gebruiker

> **Oplossing voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les8-opl ade4ff4
> yarn install
> yarn prisma migrate dev
> yarn start:dev
> ```
>
> Vergeet geen `.env` aan te maken! Bekijk de [README](https://github.com/HOGENT-frontendweb/webservices-budget?tab=readme-ov-file#webservices-budget) voor meer informatie.
