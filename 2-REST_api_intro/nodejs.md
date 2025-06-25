<!-- markdownlint-disable first-line-h1 -->

## Node.js

We willen natuurlijk niet gewoon bestaande API's aanspreken maar zelf zo'n API server maken. Een web server is op zich geen magie. Het is gewoon een programma dat luistert op een bepaalde poort, HTTP requests leest, verwerkt en voorziet van een antwoord. Aangezien HTTP requests altijd hetzelfde zijn, schrijft niemand een webserver compleet van nul (behalve als interessante oefening eens). Je kan in elke programmeertaal een server schrijven, wij kiezen JavaScript en dus [Node.js](https://nodejs.org/en).

**Node.js** is server-side JavaScript, het kwam uit in 2009. Het is een single-threaded, open source, platformonafhankelijke runtime-omgeving gebouwd bovenop v8, de JavaScript engine van Chrome (werd open source in 2008). Meer info op <https://kinsta.com/nl/kennisbank/wat-is-node-js/>.

[**npm**](https://www.npmjs.com/) is het package ecosysteem van Node.js. Het is het grootste ecosysteem van alle open source bibliotheken ter wereld, met meer dan 1 miljoen pakketten en het groeit nog steeds. npm is gratis te gebruiken en duizenden open source ontwikkelaars dragen er dagelijks aan bij.

Voor het bouwen van web API's wordt er meestal een framework gebruikt en geen 'naakte' Node.js. [Express](https://github.com/expressjs/express) is waarschijnlijk de meest gekende en meest gebruikte, was een paar jaar dood maar kreeg recent een nieuwe release. Er zijn echter nog andere frameworks zoals [Koa](https://koajs.com/), [Fastify](https://www.fastify.io/), [NestJS](https://nestjs.com/) en [Hapi](https://hapi.dev/). In deze cursus gebruiken we [NestJS](https://nestjs.com/) wat bovenop Express gebouwd is en bovendien heel wat leuke features en handigheden ingebouwd heeft.

?> Tegenwoordig bestaan ook andere JavaScript runtimes zoals [Deno](https://deno.land/) en [Bun](https://bun.sh/), maar Node.js is nog steeds [de meest gebruikte](https://2024.stateofjs.com/en-US/other-tools/#runtimes).

### pnpm

Een goeie IT'er werkt met package managers, zowel op diens besturingssysteem als in een programmeertaal. Ook Node.js heeft een package manager, namelijk [npm](https://www.npmjs.com/). Deze is echter niet de snelste en heeft een aantal nadelen. Zo downloadt npm alle dependencies steeds naar elk project.

Daarom gebruiken we [pnpm](https://pnpm.io/), een alternatieve package manager die sneller is en minder schijfruimte gebruikt. pnpm maakt gebruik van een centrale cache voor alle packages, waardoor het sneller is en minder schijfruimte gebruikt. Het is compatibel met npm en kan eenvoudig geïnstalleerd worden. Als je de software reeds hebt geïnstalleerd, heb je pnpm al op je systeem staan.
