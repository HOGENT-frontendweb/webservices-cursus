<!-- markdownlint-disable first-line-h1 -->
<small>
  Een aantal hoofdstukken zullen sterk aangepast worden t.o.v. vorig jaar. Deze niet-afgewerkte hoofdstukken worden aangeduid met een "Work In Progress" label: WIP. Deze zullen zeker nog wijzigen, het is dus niet de bedoeling dat je deze hoofdstukken reeds doorneemt.
</small>

- [0. Algemene info](./0-intro/situering.md)
- [0. Software](./0-intro/software.md)
- [1. JavaScript (WIP)](./1-javascript/index.md)
- [2. REST API (WIP)](./2-REST/index.md)
- [3. REST API (WIP)](./3-REST2/index.md)
- [4. Datalaag (WIP)](./4-datalaag/index.md)
- [5. Testing (WIP)](https://hogent-web.github.io/webservices-slides/5-testing.html?presentation=false)
- [6. Validatie en foutafhandeling (WIP)](https://hogent-web.github.io/webservices-slides/6-validation.html?presentation=false)
- [7. Authenticatie & autorisatie (WIP)](./7-authenticatie/index.md)
- [8. Testen: authenticatie & autorisatie (WIP)](./8-auth_testing/index.md)
- [9. CI/CD (WIP)](https://hogent-web.github.io/webservices-slides/9-cicd.html?presentation=false)
- [10. Linting en Swagger (optioneel + WIP)](https://hogent-web.github.io/webservices-slides/10-swagger.html?presentation=false)

## packages

```bash
~/webservices-budget$ yarn add knex
~/webservices-budget$ yarn add mysql2
```

We gaan de packages [**knex**](https://www.npmjs.com/package/knex) en [**mysql2**](https://www.npmjs.com/package/mysql2) gebruiken.

- [**knex**](https://www.npmjs.com/package/knex) is een querybuilder en vormt onze interface naar de databank
- [**mysql2**](https://www.npmjs.com/package/mysql2) is een MySQL client voor NodeJS, gefocust op performantie én met ondersteuning voor async/await

### databank configuratie

Eerst moeten we onze configuratie uitbreiden met de gegevens van onze databank

`src/config/development.js`
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

We splitsen deze zo klein mogelijk op. Pas de instellingen aan jouw lokale instellingen aan of voorzie environment variables in de `custom-environment-variables.js` en `.env` bestanden

## connectie met de databank

we maken een aparte module voor onze datalaag (index.js). Maak een `data` folder en een nieuw bestand `index.js`.

```js
const config = require('config');

const NODE_ENV = config.get('env');
const isDevelopment = NODE_ENV === 'development';

const DATABASE_CLIENT = config.get('database.client');
const DATABASE_NAME = config.get('database.name');
const DATABASE_HOST = config.get('database.host');
const DATABASE_PORT = config.get('database.port');
const DATABASE_USERNAME = config.get('database.username');
const DATABASE_PASSWORD = config.get('database.password');
```
