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
TODO: doen we dit?
Om betere coverage uitvoer te krijgen, passen we nog een aantal parameters aan in `jest.config.ts`:

```ts
// jest.config.ts
{
  // ...
   collectCoverageFrom: [
    './src/**/*.controller.ts',
    './src/**/*.service.ts',
  ],
  coverageDirectory: '__tests__/coverage'
  // ...
}
```

- `collectCoverageFrom`: mappen waarvan we coverage willen zien. Hier enkel van de service en controllers - de overige zijn niet zo belangrijk. Je kan dit aanpassen naar eigen wensen.
- `coverageDirectory`: map waar de coverage opgeslagen moet worden. Standaard komt dit in de root van je project terecht, we verplaatsen dit naar de map `__tests__`.
  - Deze map mag niet op GitHub komen, deze wordt automatisch gegenereerd.

### Login helper

Vervolgens definiëren we een helper-functie om de admin en een gewone gebruiker aan te melden. Maak een bestand `test/helper/login.ts`:

```ts
// test/helpers/login.ts
import { INestApplication } from '@nestjs/common';
import { AuthService } from '../../src/auth/auth.service';

export const login = async (app: INestApplication): Promise<string> => {
  const authService = app.get(AuthService);
  const token = await authService.login({
    email: 'test.user@hogent.be',
    password: '12345678',
  });

  if (!token) {
    throw new Error('No token received');
  }

  return token;
};

export const loginAdmin = async (app: INestApplication): Promise<string> => {
  const authService = app.get(AuthService);
  const token = await authService.login({
    email: 'admin.user@hogent.be',
    password: '12345678',
  });

  if (!token) {
    throw new Error('No token received');
  }

  return token;
};
```
De methode `login` meldt een gewone gebruiker aan
1. Vraag een instantie van AuthService op
2. De functie `login` kunnen we gebruiken om aan te melden voor elke test. Retourneer het token
3. Als het geen succesvol request was, dan gooien we een error. De error zal onze test(s) laten falen, in de meeste gevallen is dit een hele test suite.
4. We retourneren het token
5. We doen hetzelfde voor de admin


### Test unauthorized

We voegen een functie toe die de nagaat of voor een bepaalde URL de juiste statuscode geretourneerd wordt als de gebruiker niet is aangemeld of een ongeldig token wordt verstuurd. Aangezien deze testen voor elk van de endpoints dienen te gebeuren maken we hiervoor een aparte functie aan in `test/helpers/testAuthHeader.ts`:

```ts
// test/helpers/testAuthHeader.ts
import type supertest from 'supertest';

// 👇 1
export default function testAuthHeader(
  requestFactory: () => supertest.Test,
): void {
  // 👇 2
  it('should respond with 401 when not authenticated', async () => {
    const response = await requestFactory();

    expect(response.statusCode).toBe(401);
    expect(response.body.message).toBe('You need to be signed in');
  });

  // 👇 3
  it('should respond with 401 with a malformed token', async () => {
    const response = await requestFactory().set(
      'Authorization',
      'Bearer INVALID TOKEN',
    );

    expect(response.statusCode).toBe(401);
    expect(response.body.message).toBe('Invalid authentication token');
  });
}
```

1. De functie heeft één parameter, nl. een `requestFactory`. Deze factory functie moet het request voor een bepaalde HTTP methode en URL creëren. Op die manier kunnen we onze testen voor eender welk request gebruiken, het is de taak van de factory om het juiste request te maken.
2. De eerste test controleert het retourneren van een statuscode 401 als de gebruiker niet is aangemeld en hierdoor niet gemachtigd is om het endpoint te bevragen.
3. De tweede test controleert het retourneren van een statuscode 401 als een ongeldig token wordt meegestuurd en de gebruiker hierdoor niet gemachtigd is om het endpoint te bevragen.

## Places testen

Als eerste zullen we ervoor zorgen dat de testen voor onze places terug slagen. Pas hiervoor `test/places.e2e-spec.ts` aan:

```ts
// test/places.e2e-spec.ts
...
import { login } from './helpers/login';// 👈 1
import testAuthHeader from './helpers/testAuthHeader';// 👈 1

describe('Places', () => {
  let app: INestApplication;
  let drizzle: DatabaseProvider;
  let userAuthToken: string;// 👈 2

  const url = '/places';

  beforeAll(async () => {
    app = await createTestApp();
    ...
    userAuthToken = await login(app);// 👈 2
  });
  ...
  describe('GET /api/places', () => {
    it('should 200 and return all places', async () => {
      // 👇 3
      const response = await request(app.getHttpServer())
        .get(url)
        .set('Authorization', `Bearer ${userAuthToken}`);

        ...
    });

    testAuthHeader(() => request(app.getHttpServer())
      .get(url));// 👈 4
  });

  // ...
});
```

1. Importeer de helper functies
2. Gebruik nu de `login` helper om aan te melden. De `login` header houden we bij voor later.
3. Voeg aan elk request deze login header toe.
4. Voeg ook de testen toe die controleren of de juiste statuscode geretourneerd wordt als een gebruiker niet geauthenticeerd of geautoriseerd is.


Je kan enkel de testen voor de places uitvoeren door het volgende commando uit te voeren:
w in te drukken en te zoeken op places of
```bash
yarn test "./test/places.e2e-spec.ts"
```

?> Probeer test per test te doen slagen i.p.v. allemaal tegelijk. Dit maakt het makkelijker om fouten te vinden. Je kan gebruik maken van [`describe.only`](https://jestjs.io/docs/api#describeonlyname-fn) of [`it.only`](https://jestjs.io/docs/api#testonlyname-fn-timeout) gebruiken om enkel bepaalde test suites of testen uit te voeren. Dit geldt wel enkel binnen het huidige testbestand. Daarom is het handig om nu slechts één testbestand uit te voeren.


### TODO : Auth delay

Soms merk je misschien dat de testen falen omdat de maximale duur van een Jest hook (5 seconden) overschreden wordt. Dit kan gebeuren omdat de `auth.maxDelay` instelling in `config/testing.ts` nog te hoog ingesteld staat. Pas deze aan naar `0`, tijdens de testen is geen vertraging nodig.

### Oefening 2 - Testen afwerken

Herhaal hetzelfde voor alle andere testen van Transactions en users:

- Voeg de login header toe.
- Pas de requests, indien nodig, aan.
- Test voor elke URL of de juiste statuscode geretourneerd wordt als een gebruiker niet geauthenticeerd of geautoriseerd is.
Let op bij de testen voor transacties, bij de PUT en POST requests: het `userId` moet niet langer worden opgegeven. Het `userId` van de aangemelde gebruiker wordt gebruikt.
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
