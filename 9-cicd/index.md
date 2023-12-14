# CI/CD

<!-- TODO: JWT secret ? -->

> **Startpunt voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-Web/webservices-budget.git
> cd webservices-budget
> yarn install
> yarn start
> ```

Dit hoofdstuk wordt gedeeld tussen de olods Front-end Web Development en Web Services. Onderstaande tabel geeft aan welke secties van toepassing zijn voor welk olod. In de secties waar één olod niet van toepassing is, wordt dit ook nog eens expliciet vermeld.

| Sectie                                                             | Front-end Web Development | Web Services             |
| ------------------------------------------------------------------ | ------------------------- | ------------------------ |
| [Continuous Integration/Delivery](#continuous-integrationdelivery) | :heavy_check_mark:        | :heavy_check_mark:       |
| [Nodige services](#nodige-services)                                | :heavy_check_mark:        | :heavy_check_mark:       |
| [Refactoring](#refactoring)                                        | :heavy_check_mark:        | :heavy_check_mark:       |
| [Render account aanmaken](#render-account-aanmaken)                | :heavy_check_mark:        | :heavy_check_mark:       |
| [Back-end online zetten](#back-end-online-zetten)                  | :heavy_multiplication_x:  | :heavy_check_mark:       |
| [Front-end online zetten](#front-end-online-zetten)                | :heavy_check_mark:        | :heavy_multiplication_x: |
| [Hosting remarks](#hosting-remarks)                                | :heavy_check_mark:        | :heavy_check_mark:       |

## Continuous Integration/Delivery

Vroeger werd software geleverd op cd-roms, of zelfs diskettes. De software werd dan op een cd-rom gebrand en naar de klant gestuurd. De klant installeerde de software op zijn computer en kon er vervolgens mee aan de slag. Als er een fout in de software zat, dan moest de software opnieuw gebrand worden en opnieuw naar de klant gestuurd worden. Dit was een tijdrovend proces. Daarom kwamen versies maar eens om de zoveel jaar uit. Een nieuwe versie bevatte dan een 'batch' aan nieuwe functionaliteiten.

Het werk van programmeurs samenbrengen in één werkende applicatie was dan altijd een gedoe. Op welbepaalde tijdstippen werden 'builds' gemaakt met een aantal nieuwe functionaliteiten. Deze builds werden vervolgens getest door een Quality Assurance (QA) team. Als er geen fouten in zaten, werden ze bewaard. Als er toch fouten in zaten, dan moesten de programmeurs opnieuw aan de slag om de fouten te herstellen. Dit was een tijdrovend proces.

Wanneer de deadline van een nieuwe beta versie dichterbij kwam, werd de ontwikkeling van nieuwe features bevroren. Vanaf dan werden enkel nog bugfixes toegevoegd.

Dit proces is niet meer van deze tijd. De klant verwacht dat er regelmatig nieuwe functionaliteiten worden toegevoegd. De klant verwacht ook dat fouten snel worden opgelost. Daarom is het belangrijk dat er regelmatig nieuwe versies van de software worden uitgebracht. Dit proces wordt **Continuous Integration/Continuous Delivery (CI/CD)** genoemd.

Het internet heeft ervoor gezorgd dat updates heel snel kunnen uitrollen. Voor webapplicaties gaat het zelfs zo ver dat men daar niet spreekt over versies. Niemand zal ooit zeggen: "Ik draai nog versie 7 van Facebook, nog geen tijd gehad om naar versie 8 te upgraden.".

Het verschil tussen CI en CD is dat CI het proces is waarbij de code van verschillende programmeurs samen wordt gebracht in één werkende applicatie. CD is het proces waarbij de applicatie wordt uitgerold naar de klant. In deze cursus wordt CI/CD als één geheel beschouwd.

Snel bleek dat de manier om software snel in een stabiele staat te krijgen, was om ervoor te zorgen dat de software **altijd** stabiel was. Het streven wordt om in git (of een ander versiebeheersysteem) altijd een stabiele branch te hebben. Deze branch kan bij wijze van spreken op elk moment uitgerold worden naar de klant. Dit is de **master of main branch**.

### Feature branch

Als iedereen door elkaar commit op deze branch, lukt dat nooit natuurlijk. Er is dus een andere git-strategie nodig.

![Feature branch](./images/9_1_git_branches_merge.png ':size=50%')

Een mogelijke methode is werken met **feature branches**. Het idee hierachter is dat de main branch altijd stabiel is. Als je aan een feature (of bugfix) start, creëer je een nieuwe branch. Je doet daar al je commits tot het werk af is, voegt testen toe, en merget uiteindelijk alles terug naar de main. Tussendoor kan je zelfs je feature branch rebasen met de main branch, om zo de nieuwste wijzigingen te hebben voor je de merge doet. Herhaal dit proces voor elke feature.

### CI/CD pipeline

Nog een stap verder is het automatiseren van het proces. Dit wordt gedaan met een **CI/CD pipeline**. Dit is een geautomatiseerd proces dat de code van de feature branch automatisch test en uitrolt naar de klant. Als er een fout in de code zit, wordt de uitrol naar de klant niet gedaan en krijgt bijvoorbeeld de programmeur hiervan een melding. Als de testen slagen, wordt de code uitgerold naar de klant (of bv. naar een deel van de gebruikers).

Het hele concept van CI/CD valt buiten de scope van dit olod. We proberen jullie wel de essentie mee te geven.

## Nodige services

Om de back-end en front-end online te zetten, zijn er een aantal services nodig:

- [Render](https://render.com/)
- [MySQL databank in het VIC](https://phpmyadmin-frontendweb.vichogent.be/) (= Virtual IT Company van HOGENT)

### Render

Er bestaan heel wat software- en cloudoplossingen om CI/CD toe te passen. Vaak zijn deze oplossingen betalend want een paar virtuele machines opstarten om tests te draaien van een beetje serieuze applicaties is niet gratis natuurlijk.

[Heroku](https://www.heroku.com/) had een gratis versie die eenvoudig te gebruiken was, maar die is, jammer genoeg, [verdwenen sinds 28 november 2022](https://dev.to/lukeecart/more-heroku-changes-that-will-definitely-affect-you-10o8).

Daarom maken we vanaf nu gebruik van een all-in-one oplossing, nl. [Render](https://render.com/). De Render omgeving is gratis (tot een bepaalde limiet uiteraard) en biedt meteen een oplossing voor zowel back-end als front-end. Het is ontzettend eenvoudig - een beetje klikken, invullen en klaar.

### MySQL databank in het VIC

Als we onze back-end online willen zetten, hebben we een MySQL databank nodig. Op [Render](https://render.com/) kan je gratis een PostgreSQL databank opstarten, maar wij gebruik MySQL (naar analogie met het olod Databases I). *Feel free to switch, but you're on your own then.*

Er bestaan heel wat gratis MySQL services online maar eigenlijk geen enkele degelijke waar je geen kredietkaart voor nodig hebt, ofwel zien ze er sketchy uit of zijn ze vaak down.

Daarom hosten we zelf een MySQL databank in het VIC (Virtual IT Company van HOGENT). Jullie krijgen (of kregen) een mail met de inloggegevens van jouw persoonlijke MySQL databank. **Let op: er wordt maar één databank per persoon voorzien!**

**Dus je moet zelf geen MySQL databank aanmaken!** Droppen van de databank is niet mogelijk vanuit de phpMyAdmin-interface, wel vanuit code. Dat laatste kunnen we in MySQL niet verhinderen, de permissies zijn niet zo specifiek in te stellen. Wil je terug een lege databank? Drop dan simpelweg alle tabellen manueel.

We zijn geen gigantisch datacenter, dus we kunnen niet garanderen dat de databank altijd online zal zijn of snel zal reageren. We doen ons best om de databank zo goed mogelijk online te houden.

Bij problemen met de databank kan je altijd terecht bij [Thomas Aelbrecht](mailto:thomas.aelbrecht@hogent.be).

## Refactoring

Deze sectie is verdeeld in een stuk voor de [back-end](#back-end) en een stuk voor de front-end. De back-end sectie is enkel van toepassing voor het olod Web Services. De [front-end](#front-end) sectie is enkel van toepassing voor het olod Front-end Web Development.

### Back-end

We moeten eerst een paar kleine aanpassingen doen aan onze code zodat deze werkt in onze productie-omgeving. Wij starten onze server altijd op poort 9000, maar op Render kan je de poort niet zomaar kiezen (je bent niet alleen op de server). Render kiest zelf een poort die het beschikbaar heeft, geeft die door aan je proces, en verwacht dan dat je je daaraan bindt.

Pas daarom de code van de `start` functie uit `src/createServer.js` aan zodat de poort uit configuratie gelezen wordt:

```js
return {
  getApp() {
    return app;
  },

  start() {
    return new Promise((resolve) => {
      const port = config.get('port'); // 👈
      app.listen(port); // 👈
      logger.info(`🚀 Server listening on http://localhost:${port}`); // 👈
      resolve();
    });
  },
};
```

Controleer vervolgens of je de juiste configuratievariabelen vanuit environment variables kan invullen. Controleer of het bestand `config/custom-environment-variables.js` minstens onderstaande inhoud heeft:

```js
module.exports = {
  env: 'NODE_ENV',
  port: 'PORT',
  database: {
    host: 'DATABASE_HOST',
    port: 'DATABASE_PORT',
    name: 'DATABASE_NAME',
    username: 'DATABASE_USERNAME',
    password: 'DATABASE_PASSWORD',
  },
  auth: {
    jwt: {
      secret: 'AUTH_JWT_SECRET',
    },
  },
};
```

Voeg vervolgens poort 9000 toe aan de development-configuratie (in `config/development.js`). Herhaal dit voor de productie- en test-configuratie.

```js
module.exports = {
  // ...
  port: 9000,
  // ...
};
```

Het laatste moeten ervoor zorgen dat Render beschikt over de juiste versies van Node.js en Yarn. Voeg onderstaand fragment toe onderaan jouw `package.json`. Voeg eventueel komma's toe om een correct JSON-syntax te krijgen. Uiteraard laat je de buitenste accolades weg!

```json
{
  "engines": {
    "npm": ">=9.8.0",
    "node": ">=20.6.0",
    "yarn": ">=1.22.0"
  }
}
```

Nu zijn we klaar om onze back-end online te zetten.

### Front-end

Ook hier moeten we ervoor zorgen dat Render beschikt over de juiste versies van Node.js en Yarn. Voeg onderstaand fragment toe onderaan jouw `package.json`. Voeg eventueel komma's toe om een correct JSON-syntax te krijgen. Uiteraard laat je de buitenste accolades weg!

```json
{
  "engines": {
    "npm": ">=9.8.0",
    "node": ">=20.6.0",
    "yarn": ">=1.22.0"
  }
}
```

## Render account aanmaken

De volgende stap is het aanmaken van een Render account. Ga naar [Render](https://render.com/) en klik op "SIGN IN" rechtsboven.

![Render account aanmaken](./images/9_2_render_homepage.png ':size=80%')

Kies voor "GitHub" als authenticatiemethode en volg de stappen van de wizard. Als je niet voor GitHub kiest, heb je geen toegang tot jouw repositories in onze classroom. Na het aanmaken van je account krijg je een verificatiemail, klik op de link.

![Render aanmelden met GitHub](./images/9_3_sign_in_with_github.png ':size=80%')

Na verificatie van je account kom je terecht op je dashboard.

![Render dashboard](./images/9_4_render_dashboard.png ':size=80%')

## Back-end online zetten

> **Let op!** Deze sectie is **niet** van toepassing voor het olod Front-end Web Development.

We zetten eerst de back-end online, klik op "New Web Service".

![Render new web service](./images/9_5_new_web_service.png ':size=80%')

Kies op het volgende scherm voor "Build and deploy from a Git repository" en klik op "Next".

![Render choose Git](./images/9_6_web_service_choose_github.png ':size=80%')

We koppelen onze GitHub repository aan Render. Klik op "Connect account" bij GitHub.

![Render connect account](./images/9_7_connect_github_account.png ':size=80%')

Kies de juiste GitHub organisatie en volg de stappen. Normaal moet elke repository onder de organisatie "Web-IV" toegang hebben tot Render.

![Render pick organization](./images/9_8_pick_organization.png ':size=80%')

Zoek nu jouw **eigen** back-end repository op en klik op "Connect".

![Render search back-end repo](./images/9_9_search_backend_repo.png ':size=80%')

Kies een unieke naam voor je service (hint: je repository-naam is uniek) en "Frankfurt" als regio. De rest zou normaal correct ingevuld moeten zijn, **controleer dit voor jouw situatie**.

Merk op: we gebruiken `yarn` als build commando, we moeten nl. enkel onze dependencies installeren en niets builden.

![Render back-end settings part 1](./images/9_10_backend_settings_part_1.png ':size=80%')

Laat het startcommando staan op `node src/index.js`. Het type plan zou correct ingesteld moeten zijn (gratis).
**Nog niets aanmaken, er komt nog een belangrijke stap!**

Merk op: we maken geen script voor ons commando in productie. Soms worden foutcodes van het proces niet goed opgevangen door bv. `npm` of `yarn`, daarom gebruiken we `node` rechtstreeks.

![Render back-end settings part 2](./images/9_11_backend_settings_part_2.png ':size=80%')

Vul onder de instance types de nodige environment variabelen in. Check je mail voor de databank URL en de nodige credentials. Als je authenticatie en autorisatie hebt, moet je deze environment variabelen ook nog toevoegen.

> Hint: voor de variabele `AUTH_JWT_SECRET` kan je een random string gebruiken. Klik op "Generate" om een random string te laten genereren door Render.

![Render back-end settings part 3](./images/9_12_backend_settings_part_3.png ':size=80%')

Optioneel kan je een "Health Check Path" invullen. Dit is een URL die je kan gebruiken om te controleren of je service nog online is, bij ons is dit /api/health/ping.

![Render back-end settings part 4](./images/9_13_backend_settings_part_4.png ':size=80%')

Klik vervolgens op "Create Web Service" en wacht geduldig af (het gratis plan kan trager zijn). Als alles goed is gegaan, zou je nu een werkende backend moeten hebben. De URL van jouw back-end vind je linksboven.

![Back-end is online](./images/9_14_backend_online.png ':size=80%')

**Lees eerst de logs alvorens de lectoren te contacteren!** Krijg je het niet werkende? Maak een issue op jouw repository en tag jouw lector. Voeg een kopie van je logs toe, anders kunnen we niet helpen.

![Read the logs](https://imgs.xkcd.com/comics/rtfm.png ':size=30%')

## Front-end online zetten

> **Let op!** Deze sectie is **niet** van toepassing voor het olod Web Services.

Het is tijd om onze frontend online te zetten. Onze frontend is (na het builden) niet meer dan een statische website met wat HTML, JS, CSS... Veel hebben we hiervoor dus niet nodig.

Open het Render dashboard en klik rechtsboven op "New" en "Static Site".

![Render new web service](./images/9_15_new_static_site.png ':size=80%')

> **Let op!** Sla de volgende twee stappen over als je de back-end al online hebt gezet.

We koppelen onze GitHub repository aan Render. Klik op "Connect account" bij GitHub.

![Render connect account](./images/9_7_connect_github_account.png ':size=80%')

Kies de juiste GitHub organisatie en volg de stappen. Normaal moet elke repository onder de organisatie "Web-IV" toegang hebben tot Render.

![Render pick organization](./images/9_8_pick_organization.png ':size=80%')

> Ga hier dus verder als je de back-end al online hebt gezet.

Zoek nu jouw **eigen** frontend repository op en klik op "Connect"

![Render search front-end repo](./images/9_16_search_frontend_repo.png ':size=80%')

Kies een unieke naam voor je statische website (hint: je repository-naam is uniek). Vul `dist` in bij de "Publish directory". De rest zou normaal correct ingevuld moeten zijn, controleer dit voor jouw situatie.

Merk op: we gebruiken `yarn; yarn build` als build commando. We installeren dus eerst onze dependencies en bouwen vervolgens onze applicatie.

![Render front-end settings part 1](./images/9_17_frontend_settings_part_1.png ':size=80%')

We moeten onze frontend nog vertellen waar onze backend draait. Dit doen we door een environment variabele in te stellen. Klik op "Advanced" en vul de nodige environment variable in. De URL van je backend vind je op het Render dashboard van jouw backend. Vergeet niet `/api` toe te voegen aan het einde van de URL, tenzij je dit anders aangepakt hebt in jouw applicatie.

Klik vervolgens op "Create Static Site" en wacht geduldig af (het gratis plan kan trager zijn).

![Render front-end settings part 2](./images/9_18_frontend_settings_part_2.png ':size=80%')

Als alles goed is gegaan, zou je nu een werkende frontend moeten hebben. De URL van jouw frontend vind je linksboven.

![Front-end is online](./images/9_19_frontend_online.png ':size=80%')

### CORS probleem

Je kan nu alvast naar jouw frontend gaan maar je zal merken dat er nog een probleem is - open de console. Je krijgt een CORS error, dit moeten we gaan fixen in de backend!

![CORS error](./images/9_20_frontend_cors.png ':size=80%')

CORS kan je enkel oplossen door in de backend de juiste headers te zetten. We hadden reeds ons CORS package geconfigureerd en moeten enkel de URL aanpassen in het bestand `config/production.js`. Vervang een reeds ingevulde URL door jouw eigen frontend URL.

> Merk dus op dat je een CORS-probleem niet kan oplossen in de frontend of als je geen toegang hebt tot de backend!

```js
module.exports = {
  // ...
  cors: {
    origins: ['https://frontendweb-budget.onrender.com'], // 👈
    maxAge: 3 * 60 * 60, // 3h in seconds
  },
  // ...
};
```

Commit en push deze wijziging. Wacht tot de backend opnieuw online is en herlaad de frontend. De CORS error zou nu weg moeten zijn.

### 404 probleem

Probeer nu op jouw frontend rechtstreeks naar een URL verschillend van `/` te gaan. In ons voorbeeld gaan we naar `/transactions`. Je zal merken dat je een 404 krijgt. Dit moeten we oplossen in de frontend!

![404 error](./images/9_21_frontend_not_found.png ':size=80%')

Ga naar het Render dashboard van jouw frontend en klik op "Redirects/Rewrites". Voeg een nieuwe Rewrite-regel toe zoals op onderstaande afbeelding. Klik vervolgens op "Save Changes". Je kan meteen testen of het werkt! Deze regel zorgt ervoor dat alle requests naar de frontend die niet naar / gaan, als antwoord de index.html van de frontend krijgen. [Lees meer over het verschil tussen redirects en rewrites](https://render.com/docs/redirects-rewrites).

![Front-end rewrite](./images/9_22_frontend_rewrite.png ':size=80%')

## Hosting remarks

Dit was maar een (eenvoudig) voorbeeld om je applicatie online te zetten. Onze hoofdbekommernis was bovendien om alles 100% gratis te kunnen regelen, wat niet altijd het eenvoudigst of handigst is.

Hier testen we onze applicatie ook niet voor we deze online zetten. We merken het dus niet op als onze applicatie een bug heeft die door de testen opgevangen zou worden.

Als je ooit echte applicaties online wil zetten, kijk dan eerst eens rond. Er zijn veel opties, en vaak helemaal niet duur meer maar zelden helemaal gratis. Vaak zal de CI/CD pipeline veel meer omvatten dan louter builden en online plaatsen.

Op Render wordt ook de complexiteit van de CI/CD pipeline niet getoond. Je moet slechts een paar veldjes invullen en Render doet alle magie voor jou. Dit is natuurlijk niet realistisch. Als je ooit een echte applicatie online zet, zal je zelf een CI/CD pipeline moeten opzetten. Dit is een hele klus en je zal er veel tijd in moeten steken. Het is echter wel de moeite waard, want het zal je veel tijd besparen in de toekomst.
