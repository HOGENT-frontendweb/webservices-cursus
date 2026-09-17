# Web Services Opdracht 2026 - 2027

## 1. De opdracht

Gedurende het semester maak je een API in Node.js. Als je ook het olod Front-end Web Development volgt, zal de API dienen als back-end voor de applicatie die je daar maakt. Indien je het olod Front-end Web Development niet volgt, maak je gewoon een API.

Je bent volledig vrij om te kiezen welke API je ontwikkelt. Indien je twijfelt over jouw idee, mag je tijdens de les altijd overleggen met je lector of achteraf via een GitHub issue op jouw repository.

?> Er wordt enkel feedback gegeven op ideeën tijdens semester 1. Indien je een idee hebt dat je graag wil bespreken, doe dit dan tijdig.

De examenopdracht wordt uitgevoerd in teams van twee. Beide teamleden dragen bij aan alle onderdelen van de applicatie en zijn verantwoordelijk voor het volledige eindresultaat. Zie [sectie 4](#4-groepswerk) voor meer informatie.

Alle code moet in een GitHub repository terecht komen, die je aanmaakt vertrekkende van een template. Enkel de `main` branch van deze repository zal geëvalueerd worden. De template bevat een `README.md` en een `dossier.md` bestand. Vul deze correct in. Je gebruikt dezelfde repository voor zowel Web Services als Front-end Web Development. Check zeker onze [appendix over Git & GitHub](../appendices/2-github/index.md) als je hiermee nog niet vertrouwd bent.

Het is belangrijk dat de applicatie significant verschilt van de voorbeeldapplicatie die tijdens de les gemaakt wordt.

Daarnaast verwachten we dat je een dossier met uitleg over je app indient op Orion. Een template voor dit dossier (`dossier.md`) vind je ook in jouw repository en dien je te gebruiken. **Je dient het dossier in als pdf!**

## 2. Ontvankelijkheidscriteria

Alvorens we jouw project evalueren, controleren we of het voldoet aan een aantal ontvankelijkheidscriteria.

!> Als niet voldaan is aan de ontvankelijkheidscriteria, krijg je de score "Afwezig" (conform het DOER).

Deze criteria zijn:

- Het dossier is volledig en tijdig ingediend (zie [sectie 5](#5-dossier-vereisten) voor de vereisten)
- Je werkt in groep van 2. Elke student heeft minstens twee feature branches waarin een volledige feature werd uitgewerkt. Voor elke feature branch werd minstens één pull request aangemaakt. De student voert minstens 10 kleine, betekenisvolle commits uit tijdens de ontwikkeling van de feature. Op elke pull request werd inhoudelijke feedback gegeven door de medestudent(zie [sectie 4](#4-groepswerk) en [sectie Feature Branch workflow](https://hogent-frontendweb.github.io/webservices-cursus/#/appendices/2-github/index?id=feature-branch-workflow)).
- De applicatie is gemaakt in NodeJS en TypeScript met NestJS als web framework
- De applicatie draait online op vichogent
- De applicatie start zonder problemen op a.d.h.v. de instructies in de README en gebruikt hiervoor Docker
- De applicatie wijkt voldoende af van de voorbeeldapplicatie
- node_modules, .env, productiecredentials... werden niet gepushed op GitHub
- Er is een extra technologie gebruikt (zie [sectie 7](#7-voorbeelden-van-extra-s) voor voorbeelden) en beschreven in het dossier.
- Er werden een aantal niet-triviale en werkende integratietesten gemaakt (naast de testen voor user), waarvan de code coverage toegevoegd is aan het dossier.
- Het databankschema is voldoende complex en correct. Het bestaat uit minstens 3 tabellen (naast de user tabel) die verbonden zijn met elkaar en bevat minstens 1 veel-op-veel relatie. De tabellen bevatten meerdere kolommen (naast het id).
- Er is degelijke autorisatie/authenticatie op alle routes.

## 3. Evaluatiecriteria

Jouw project wordt beoordeeld op verschillende onderdelen en criteria, met elk hun eigen gewicht. Op Orion vind je de evaluatiekaart met alle onderdelen/criteria en hun gewicht. Hieronder vind je een overzicht van de criteria per onderdeel.

### Datalaag

- voldoende complex en correct: minstens 3 tabellen (naast de user tabel) verbonden met elkaar, minstens 1 veel-op-veel relaties, tabellen bevatten meerdere kolommen (naast het id)
- één module beheert de connectie + connectie wordt gesloten bij sluiten server
- heeft migraties - indien van toepassing
- heeft seeds

### Repositorylaag

- definieert één repository per entiteit - indien van toepassing
- mapt OO-rijke data naar relationele tabellen en vice versa - indien van toepassing
- er worden kindrelaties opgevraagd (m.b.v. JOINs) - indien van toepassing

### Servicelaag met een zekere complexiteit

- bevat alle domeinlogica
- er wordt gerelateerde data uit meerdere tabellen opgevraagd
- bevat geen services voor entiteiten die geen zin hebben zonder hun ouder (bv. tussentabellen)
- bevat geen SQL-queries of databank-gerelateerde code

### REST-laag

- meerdere routes met invoervalidatie
- meerdere entiteiten met alle CRUD-operaties
- degelijke foutboodschappen
- volgt de conventies van een RESTful API
- bevat geen domeinlogica
- geen API calls voor entiteiten die geen zin hebben zonder hun ouder (bv. tussentabellen)
- degelijke autorisatie/authenticatie op alle routes

### Algemeen

- er is een minimum aan logging en configuratie voorzien
- een aantal niet-triviale én werkende integratietesten (min. 1 entiteit in REST-laag >= 90% coverage, naast de user testen)
- de api is gedocumenteerd
- node_modules, .env, productiecredentials... werden niet gepushed op GitHub
- minstens één extra technologie
- maakt gebruik van de laatste ES-features (async/await, object destructuring, spread operator...)
- de applicatie start zonder problemen op a.d.h.v. 1 commando zoals vermeld in de README
- de API draait online
- duidelijke en volledige README.md
- duidelijk en volledig dossier

### Demo bij de mondelinge verdediging

- de student toont een werkende REST API in NodeJS
- de student kan het ERD tonen en design keuzes hierin toelichten
- de student kan het project probleemloos opstarten
- de student toont aan dat alle testen slagen
- de student voert een aantal succesvolle API calls naar keuze van de lector uit

### Mondelinge verdediging

- de student kan de vragen van de lector gedetailleerd beantwoorden a.d.h.v. de geschreven code, en toont zo aan dat hij/zij de behandelde theoretische concepten begrijpt en kan toepassen
- de student kan de gemaakte design keuzes verdedigen

## 4. Groepswerk

Voor de examenopdracht werk je in groepen van twee. Indien je ook Frontendweb Development volgt, volg je de instructies van dat vak om een groep in te schrijven en de ANS opdracht in te vullen.Indien je enkel Web Services volgt, volg je de instructies hieronder.

### groep inschrijving

Schrijf je in Orion in het vak Webservices in voor een groep van twee studenten. Indien je nog geen medestudent hebt gevonden, schrijf je dan in bij de groep 'Op zoek naar medestudent'. De lector zal na afloop van de inschrijvingsperiode de studenten uit deze groep samenbrengen tot projectgroepen van twee.

De deadline voor het vormen van groepen is **vrijdag 2 oktober 2026 om 23.59 uur (einde van week 2)**.

!> Studenten die na deze deadline nog niet ingeschreven zijn in een groep, moeten zelf op zoek gaan naar een medestudent om samen een projectgroep te vormen.

### ANS-opdracht

Zodra je bent ingeschreven in een groep, dienen beide groepsleden de ANS-opdracht in te vullen en in te dienen. Ga hiervoor naar [ANS](https://ans.app/), log in met je studenten account en vul de opdracht 'Inschrijven voor examenopdracht' in.

In deze opdracht vermeld je:

- het groepsnummer (zoals vermeld in Orion);
- je naam en voornaam
- de URL van de GitHub-repository die je hebt aangemaakt op basis van de aangeboden template (zie [sectie 9](#9-aanmaken-van-de-repository));
- je publieke SSH-sleutel (niet de private sleutel) (zie [sectie 10](#10-aanmaken-van-de-ssh-sleutel)).

Beide studenten moeten de ANS-opdracht afzonderlijk indienen.

De deadline voor deze opdracht is **vrijdag 9 oktober 2026 om 23.59 uur (einde van week 3)**. Deze gegevens hebben we nodig voor het aanmaken van de VPS op het VIC en je toegang tot deze server te geven.

!>Indien je de ANS-opdracht niet indient, dien je zelf [contact op te nemen met het VIC](https://vichogent.be/nl/hosting) en sta je zelf in voor de correcte aanmaak van de VPS.

### Repository en individuele bijdrage

Je maakt per groep één repository aan (zie [sectie 9](#9-aanmaken-van-de-repository)) en werkt samen aan dezelfde codebase. Volg de instructies in [Sectie 2](#2-ontvankelijkheidscriteria) om de repository correct aan te maken. De repository wordt gedeeld met beide studenten en de lectoren. De repository is privé, maar de lectoren hebben toegang tot de code.

Om de individuele bijdrage te kunnen beoordelen, wordt gewerkt volgens de **Feature Branch Workflow**. Elke ontwikkeltaak, inclusief bugfixes, wordt door één student uitgevoerd in een afzonderlijke feature branch en via een Pull Request (PR) geïntegreerd in de `main`-branch. De student die de taak uitvoert, maakt (minstens 10) kleine, betekenisvolle commits en is verantwoordelijk voor het maken van de PR en het beantwoorden van eventuele vragen van de medestudent. De medestudent is verantwoordelijk voor het reviewen van de PR en het geven van inhoudelijke feedback. De medestudent mag ook suggesties doen voor verbeteringen, maar mag geen code toevoegen aan de feature branch van de andere student.

De Pull Request moet voldoende informatie bevatten om de uitgevoerde werkzaamheden te kunnen beoordelen. Hieruit moet duidelijk blijven:

- welke functionaliteit/bugfix werd ontwikkeld;
- welke onderdelen door de student werden geïmplementeerd;
- welke technische keuzes werden gemaakt;
- hoe de functionaliteit werd getest.

Elke student implementeert minstens één volledige feature van begin tot einde. Dit betekent dat de student verantwoordelijk is voor de volledige implementatie van deze functionaliteit, inclusief:

- CRUD endpoints
- de bijhorende datalaag
- de bijhorende servicelaag
- authenticatie en autorisatie indien van toepassing
- validatie en foutafhandeling
- API documentatie
- de bijhorende testen

Hoewel het project in groep wordt uitgevoerd, wordt van elke student verwacht dat die een substantiële en aantoonbare individuele bijdrage levert aan het eindresultaat. Deze bijdrage moet zichtbaar zijn in de commits, feature branches, Pull Requests en gegeven feedback op Pull Requests van medestudenten.

Na de deadline wordt de activiteit in de repository geanalyseerd. Daarbij wordt onder meer gekeken naar het aantal en de kwaliteit van de commits, het gebruik van feature branches, de inhoud van de Pull Requests en de bijdrage aan het reviewproces. Wanneer onvoldoende kan worden aangetoond welke bijdrage een student heeft geleverd, kan dit leiden tot een lagere individuele score.

## 5. Dossier vereisten

Het dossier is een belangrijk onderdeel van de examenopdracht. Je dient dit dossier in als pdf in de **opdrachten module van Orion** en dit ten laatste op **18 december 2026**.

Zorg dat de `dossier.md` van je repository aangevuld is, alle vereisten staan in het document.

In dit document staan lijnen die starten met een >, dit zijn instructies. Verwijder deze lijnen voor je het dossier indient!

Dien enkel een pdf in op Orion, er zijn genoeg plugins voor VS Code om Markdown naar pdf om te zetten, zoals bv. <https://marketplace.visualstudio.com/items?itemName=yzane.markdown-pdf>.

!> Gebruik een degelijke opmaak in Markdown voor de README en het dossier! Zie [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) voor meer uitleg.

## 6. Verloop van de examenvorm

Bij dit vak dien je een project te maken en hierbij een **dossier** op te laden op Orion.
Indien je project voldoet aan de **ontvankelijkheidscriteria** zal je worden uitgenodigd voor een **mondelinge verdediging** .
Hierbij geef je een demonstratie van je project en je code.
Hierover zullen dan verdere vragen volgen.

### Demo vereisten

Tijdens het mondeling examen dien je te starten met een demo van jouw applicatie. Jullie verdelen zelf wie wat demonstreert, maar zorg ervoor dat beide personen evenveel aan bod komen. Deze demo moet voldoen aan de volgende vereisten:

- De demo mag maximaal 15 minuten duren (inclusief Front-end Web Development, indien van toepassing)
- De webcam moet aanstaan tijdens de demo zodat je gezicht zichtbaar is
- De demo moet minstens de volgende onderdelen bevatten/tonen:
  - **Context van de applicatie**: leg uit wat de applicatie doet, wat het doel is en waarom je dit onderwerp gekozen hebt
  - **Projectstructuur overlopen (optioneel)**:
    - Leg eventuele speciale ontwerpkeuzes uit (waarom bepaalde mappen/bestanden georganiseerd zijn zoals ze zijn)
    - Dit hoef je niet te doen als de projectstructuur identiek is aan de voorbeeldapplicatie
  - **Demo van de applicatie**:
    - Gebruik uitsluitend de online versie van je applicatie (geen localhost)
    - Indien je zowel Web Services als Front-end Web Development volgt:
      - Demonstreer de webservice door verschillende API endpoints uit te testen in Postman (GET, POST, PUT, DELETE operaties)
      - Toon je front-end applicatie en demonstreer dat deze responsive is door het scherm te verkleinen/vergroten of verschillende apparaatgroottes te simuleren
      - Demonstreer de werking van je front-end applicatie
    - Indien je enkel Web Services volgt:
      - Focus op het demonstreren van je API endpoints in Postman
      - Toon verschillende CRUD operaties voor je entiteiten
  - **Demo van de extra technologie**:
    - Toon de werking van de extra technologie in actie
    - Laat de code zien waar je de extra technologie geïmplementeerd hebt
    - Leg uit waarom je voor deze technologie gekozen hebt
    - Doe dit voor beide olods (Front-end Web Development en Web Services indien van toepassing)
  - **Testen demonstreren**:
    - Laat alle testen lopen via de command line
    - Toon dat ze succesvol slagen en toon het coverage report
  - **Code showcase**:
    - Toon een stukje code waar je bijzonder fier op bent
    - Leg uit waarom je dit goed vindt en wat het doet
    - Dit geldt voor beide olods (Front-end Web Development en Web Services indien van toepassing

### Mondelinge verdediging

Tijdens de mondelinge verdediging (15 minuten per applicatie) wordt per student nagegaan in welke mate de student inzicht heeft in de gerealiseerde applicatie en de behandelde leerinhouden. De student moet a.d.h.v. **de geschreven code** de gebruikte technieken, ontwerpkeuzes en implementaties kunnen verklaren en verantwoorden, de onderliggende theoretische concepten correct kunnen toelichten en kunnen aantonen hoe deze in de applicatie werden toegepast. Daarnaast moet de student kunnen aangeven hoe gevraagde wijzigingen of uitbreidingen aan de applicatie gerealiseerd kunnen worden.

De mondelinge verdediging dient tevens als validatie van de beoordeling op basis van de code-rubrics. De student moet kunnen aantonen, toelichten en verantwoorden hoe de criteria uit deze rubrics werden toegepast binnen de gerealiseerde applicatie en moet de gemaakte keuzes kunnen motiveren aan de hand van de ingediende code.

De vragen kunnen betrekking hebben op de code, de architectuur, de gebruikte technologieën, de behandelde theoretische concepten, de toegepaste best practices, de criteria uit de rubrics en de algemene werking van de applicatie.

## 7. Voorbeelden van extra’s

Je vindt misschien wel een interessante extra technologie in de [Node.js Toolbox](https://nodejstoolbox.com/). Een aantal veelgebruikte extra's zijn:

- Upload functionaliteit, maar let op:
  - In [hoofdstuk 9](../9-cicd/index.md) gebruiken we Render als hosting provider. In de gratis versie heb je geen lokale opslag. Zorg er daarom voor dat je de uploads niet lokaal opslaat, maar gebruik een externe opslagservice zoals [AWS S3](https://aws.amazon.com/s3/) of [Cloudinary](https://cloudinary.com/).
- Passport.js voor authenticatie
- Package voor invoervalidatie
- Real time toepassing (sockets...)
- Ander ORM voor de databank
- Ander type databank (document based, column oriented...), maar let op:
  - wisselen van MySQL naar bv. PostgreSQL is geen extra. Dit blijft nog steeds hetzelfde type databank.
  - niet elk project is hiervoor geschikt!
- ... (eigen inbreng, verras ons)

Bij het toevoegen van een extra technologie is het belangrijk dat deze ook echt gebruikt wordt in de applicatie. Een package toevoegen die je niet gebruikt, is ook niet-ontvankelijk. Houd ook rekening met de best practices die we in de les gezien hebben bij het implementeren van de extra technologie.

?> Jouw project moet gebruik maken van NestJS als web framework. Andere frameworks zijn niet toegelaten.

## 8. Evaluatie

Je wordt beoordeeld op basis van een portfolio dat je samenstelt gedurende het semester en de mondelinge verdediging. Dit portfolio bestaat uit:

- De code van je applicatie
- Moet te vinden zijn in je repository op de `main` branch
- Het ingevulde dossier, als pdf ingediend op Orion

Zorg ervoor dat jouw applicatie aan alle ontvankelijkheidscriteria voldoet op het moment van de deadline. Indien dit niet het geval is, krijg je een score 'AFWEZIG".

**De deadline voor het portfolio is het einde van week 13 (vrijdag 18 december 2026, 23u59).**

In de rubrics gepubliceerd op Orion vind je een overzicht van de criteria waarop je beoordeeld wordt. Zorg ervoor dat je deze criteria goed begrijpt en dat je project hieraan voldoet.

In de **2e zit** mag je gewoon verder werken aan je huidig project, de opdracht wijzigt niet. De deadline is 22 augustus 2027, 23u59.

Veel succes!

## 9. Aanmaken van de repository

- Via de GitHub website, navigeer naar [de template-repository op GitHub](https://github.com/HOGENT-frontendweb/frontendweb-webservices-project-template-2627)
- Klik rechtsboven op de groene knop `Use this template` en kies `Create a new repository`.
- Selecteer de Owner (jouw account).
- Geef je nieuwe repository een Repository name : `groepsnummer-frontendweb-webservices-2627`.
- Kies voor een `Private` repository.
- Klik op `Create repository from template`. GitHub maakt nu een exacte kopie voor je aan zonder de commit-geschiedenis van de template.
- Voeg je medestudent toe als Collaborator aan de repository. Ga hiervoor naar Settings > Collaborators > Add people. Je medestudent krijgt een uitnodiging via e-mail en moet deze accepteren.
- Voeg ook de lectoren toe als Collaborators aan de repository met read rechten. Ga hiervoor naar Settings > Collaborators > Add people. De lectoren krijgen een uitnodiging via e-mail en moeten deze accepteren. Voeg de volgende lectoren toe:
  - Andreas De Witte: @dreeki
  - Karine Samyn: @ksa607
  - Pieter Vander Vennet: @pietervdvn

## 10. Aanmaken van de SSH-sleutel

Elke student maakt een SSH-sleutel aan.

- Open je terminal of command line.
- Voer het commando `ssh-keygen -t ed25519` in.
- Volg de instructies om de sleutel te genereren. Je zal een naam voor de sleutel moeten opgeven en een passphrase (wachtwoord) instellen. Je kan de standaardnaam gebruiken (`id_ed25519`) en een passphrase instellen of leeg laten.
- De sleutel wordt gegenereerd in de map `~/.ssh/` met de naam `id_ed25519` (private) en `id_ed25519.pub` (public).

De publieke sleutel deel je mee in de ANS opdracht. De lectoren gebruiken deze sleutel om je toegang te geven tot een VPS (Virtual Private Server) op het VIC. De private sleutel blijft privé en mag je niet delen! Je gebruikt deze private sleutel om in te loggen op het VIC.

Het opvragen van de publieke sleutel kan op verschillende manieren, afhankelijk van je besturingssysteem en terminal. Een veelgebruikte manier is het gebruik van het commando `cat` in de terminal:

```bash
cat ~/.ssh/id_ed25519.pub
```

Een voorbeeld van een publieke sleutel is als volgt:
`ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAA6JxFA0rcaXAEFJKf8ifSCvjzTnn2qsYuLEI0GVqP jan.janssens@hogent.be`
