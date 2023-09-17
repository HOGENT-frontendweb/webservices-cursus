# Testen: authenticatie & autorisatie

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-Web/webservices-budget.git
> cd webservices-budget
> git checkout -b les8 827fd06
> yarn install
> yarn start
> ```

Momenteel moet je voor elke API call in onze budget applicatie aangemeld zijn. Onze testen gaan er nog steeds van uit dat je niet aangemeld moet zijn en dus zullen deze een voor een falen.

Onze testen doen slagen is eenvoudig: aanmelden voor we het request uitvoeren en de token meegeven in de `Authorization` header. Daarom moeten we enkel weten hoe we moeten aanmelden via code. Daarvoor baseren we ons op een React-voorbeeld voor Auth0 in combinatie met Cypress (<https://github.com/charklewis/auth0-cypress/blob/master/cypress/support/commands.js>). We hebben enkel de API-call informatie nodig, verder hebben we niets nodig. Probeer eerst zelf een oplossing te bedenken, volg daarna de stappen in de oplossing hieronder. Een hint: je moet manueel een gebruiker (specifiek voor de testen) aanmaken in Auth0 (zie ook <https://auth0.com/blog/end-to-end-testing-with-cypress-and-auth0/>).

## Refactoring

Momenteel bevatten onze beide testbestanden identiek dezelfde `beforeAll` en `afterAll`. Dit kan beter! Neem een kijkje in het bestand `__tests__/helpers.js`.

```js
const supertest = require('supertest');
const createServer = require('../src/createServer');
const { getKnex } = require('../src/data');

const withServer = (setter) => {
  let server;

  beforeAll(async () => {
    server = await createServer();

    setter({
      knex: getKnex(),
      request: supertest(server.getApp().callback()),
    });
  });

  afterAll(async () => {
    // Cleanup resources!
    await server.stop();
  });
};

module.exports = {
  withServer,
};
```

Daar werd een helper-functie `withServer` gemaakt die identiek deze code bevat: aanmaken van de server en opruimen van de server. Na het aanmaken wordt een setter-functie aangeroepen met als doel dat elke test suite toegang krijgt tot o.a. supertest en Knex.

Kopieer deze code naar jouw project en pas elke test suite als volgt aan:

```js
describe('Transactions', () => {
  let request;
  let knex;

  withServer(({ knex: k, request: r, authHeader: a }) => {
    knex = k;
    request = r;
  });

  // ...
});
```

We roepen hier `withServer` aan alsof het ook een functie uit de Jest library is. We geven deze helper een functie mee die vervolgens de nodige dingen bijhoudt in de test suite, zoals bijvoorbeeld een instantie van supertest.

## Testgebruiker

> Je kan dezelfde gebruiker nemen als bij Front-end Web Development. Je hoeft dit dus niet opnieuw te doen indien je reeds een testgebruiker hebt.

Om via Cypress te kunnen aanmelden gaan we een testgebruiker aanmaken in het [Auth0 Dashboard](https://manage.auth0.com/). Ga hiervoor naar User Management > Users en klik op `Create User`. Kies onderstaande instellingen:

- Email: <e2e-testing@budgetapp.be>
- Password: kies zelf een wachtwoord
- Repeat Password: (zou duidelijk moeten zijn)
- Connection: Username-Password-Authentication

![Create a testuser](./images/1-create_testuser.png ':size=60%')

Na het aanmaken van de gebruiker opent het detailscherm.

![View user details](./images/2-userdetails.png ':size=60%')

Klik hier op `Edit` onder het e-mailadres van de testgebruiker. Klik onder het e-mailveld op `Set email as verified`.

![Verify email](./images/3-verify_email.png ':size=60%')

Zorg ervoor dat deze gebruiker de rol `boekhouder` toegekend krijgt.

![Verify email](./images/4-assign_role.png ':size=60%')

Vervolgens ga je naar de settings van jouw applicatie in het Auth0 Dashboard. Daar open je de Advanced Settings en ga je naar het tabblad Grant Types. Daar selecteer je `Password`. Vergeet de wijzigingen niet op te slaan.

![Allow password grant](./images/5-password_grant.png ':size=60%')

Als laatste moeten we username-password-authentication instellen als de default directory voor Auth0:

- Ga naar het [Auth0 Dashboard](https://manage.auth0.com/).
- Open Settings in het linkermenu
- Ga naar API Authorization Settings
- Vul `Username-Password-Authentication` bij Default Directory
- Sla de wijzigingen op

## Aanmelden voor elke test

Voeg een nieuwe helper-functie toe aan `__tests__/helpers.js`:

```js
// andere imports
const axios = require('axios'); // 👈 1
const config = require('config'); // 👈 1

// 👇 2
const fetchAccessToken = async () => {
  const response = await axios.post(
    config.get('auth.tokenUrl'),
    {
      grant_type: 'password',
      username: config.get('auth.testUser.username'),
      password: config.get('auth.testUser.password'),
      audience: config.get('auth.audience'),
      scope: 'openid profile email offline_access',
      client_id: config.get('auth.clientId'),
      client_secret: config.get('auth.clientSecret'),
    },
    {
      headers: { 'Accept-Encoding': 'gzip,deflate,compress' }, // 👈 5
    }
  );

  return response.data.access_token;
};

const withServer = (setter) => {
  let server;

  beforeAll(async () => {
    server = await createServer();
    const token = await fetchAccessToken(); // 👈 4

    setter({
      knex: getKnex(),
      request: supertest(server.getApp().callback()),
      authHeader: `Bearer ${token}`, // 👈 4
    });
  });

  afterAll(async () => {
    // Cleanup resources!
    await server.stop();
  });
};

module.exports = {
  fetchAccessToken, // 👈 3
  withServer,
};
```

1. We importeren `axios` en `config`.
2. We definiëren een functie die een access token kan ophalen bij Auth0. Deze doet een HTTP POST op {JOUW DOMEIN}/oauth/token en meldt aan met de aangemaakte testgebruiker. Je kan deze functie eventueel aanpassen zodat je de username en het wachtwoord meekrijgt als parameter.
3. Exporteer deze functie voor eventueel later gebruik.
4. Pas de `withServer` functie aan zodat deze telkens een access token aanvraagt en de HTTP header doorgeeft aan de setter.
5. Mogelijks krijg je een onduidelijke foutboodschap als je laatste versie van axios (momenteel v1.2.1) gebruikt, dit is een fix (zie <https://github.com/axios/axios/issues/5346>).

Om dit te doen werken, moeten we onze configuratie in `config/custom-environment-variables.js` aanpassen. Zo kunnen we alle nodige instellingen meegeven via het environment en hoeven we deze niet te committen naar GitHub. Je mag zeker je username, password en client secret niet pushen.

```js
module.exports = {
  // ...
  auth: {
    // ...
    tokenUrl: 'AUTH_TOKEN_URL',
    clientId: 'AUTH_CLIENT_ID',
    clientSecret: 'AUTH_CLIENT_SECRET',
    testUser: {
      userId: 'AUTH_TEST_USER_USER_ID',
      username: 'AUTH_TEST_USER_USERNAME',
      password: 'AUTH_TEST_USER_PASSWORD',
    },
  },
};
```

Vervolgens voeg je volgende settings toe aan de `.env.test`:

```.env
AUTH_TEST_USER_USER_ID={YOUR TEST USER AUTH0 ID}
AUTH_TEST_USER_USERNAME={YOUR TEST USER USERNAME}
AUTH_TEST_USER_PASSWORD={YOUR TEST USER PASSWORD}
AUTH_TOKEN_URL={YOUR DOMAIN}/oauth/token
AUTH_CLIENT_ID={YOUR CLIENT ID}
AUTH_CLIENT_SECRET={YOUR CLIENT SECRET}
```

Sla nu deze `authHeader` op in elke testsuite, zoals bijvoorbeeld voor de transactions:

```js
describe('Transactions', () => {
  let request;
  let knex;
  let authHeader; // 👈

  withServer(({ knex: k, request: r, authHeader: a }) => {
    knex = k;
    request = r;
    authHeader = a; // 👈
  });

  // ...
});
```

Vervolgens voeg je deze HTTP header toe aan elk request (waar nodig), bijvoorbeeld:

```js
describe('GET /api/transactions', () => {
  // ..

  test('it should 200 and return all transactions', async () => {
    const response = await request.get(url).set('Authorization', authHeader); // 👈

    // ..
  });
});
```

Pas ook de testdata aan zodat gewerkt wordt met de Auth0 testgebruiker:

```js
const data = {
  // ...
  users: [
    {
      id: 1,
      name: config.get('auth.testUser.username'), // 👈
      auth0id: config.get('auth.testUser.userId'), // 👈
    },
  ],
};
```

Zoek nu alle checks die hard gecodeerd checken op de naam van de gebruiker. Vervang deze door `data.users[0].name`.

## Oefening

Zorg ervoor dat alle testen van transactions en places terug slagen.

## Oplossing

Zoals altijd is een oplossing te vinden in onze [voorbeeldapplicatie](https://github.com/HOGENT-Web/webservices-budget), deze keer op de branch `feature/auth0`.
