# Web Services Opdracht 2025 - 2026

## 1. De opdracht

Gedurende het semester maak je een API in Node.js. Als je ook het olod Front-end Web Development volgt, zal de API dienen als back-end voor de applicatie die je daar maakt. Indien je het olod Front-end Web Development niet volgt, maak je gewoon een API.

Je bent volledig vrij om te kiezen welke API je ontwikkelt. Indien je twijfelt over jouw idee, mag je tijdens de les altijd overleggen met je lector of achteraf via een GitHub issue op jouw repository.

Alle code moet in een GitHub classroom repository terechtkomen (zie Chamilo voor een link naar de classroom). Enkel de `main` branch van deze repository zal geëvalueerd worden. Er wordt automatisch een template van de `README.md` aangemaakt als je de opdracht accepteert, vul deze correct in. Je gebruikt dezelfde repository voor zowel Web Services als Front-end Web Development.

Het is belangrijk dat de applicatie significant verschilt van de voorbeeldapplicatie die tijdens de les gemaakt wordt.

Daarnaast verwachten we dat je een dossier met uitleg over je app indient op Chamilo. Een template voor dit dossier (`dossier.md`) vind je ook in jouw repository en dien je te gebruiken. **Je dient het dossier in als pdf!**

## 2. Ontvankelijkheidscriteria

Alvorens we jouw project evalueren, controleren we of het voldoet aan een aantal ontvankelijkheidscriteria. Indien deze niet voldaan zijn, krijg je een score van 0/20. Deze criteria zijn:

- Het dossier is volledig en tijdig ingediend (zie [sectie 4](#4-dossier-vereisten) voor de vereisten)
- Er werden voldoende (kleine) commits gemaakt
- De applicatie draait online
- De applicatie start zonder problemen op gebruik makend van de instructies in de README
- De applicatie wijkt voldoende af van de voorbeeldapplicatie
- De applicatie is gemaakt in NodeJS en TypeScript met NestJS als web framework
- node_modules, .env, productiecredentials... werden niet gepushed op GitHub
- Er is een extra technologie gebruikt (zie [sectie 6](#6-voorbeelden-van-extras) voor voorbeelden)
- Er werden een aantal niet-triviale en werkende integratietesten gemaakt (naast de testen voor user)
- De demo duurt niet langer dan 15 minuten (incl. Front-end Web Development indien van toepassing)

## 3. Evaluatiecriteria

Jouw project wordt beoordeeld op verschillende onderdelen en criteria, met elk hun eigen gewicht. Op Chamilo vind je de evaluatiekaart met alle onderdelen/criteria en hun gewicht. Hieronder vind je een overzicht van de criteria per onderdeel.

### Datalaag

- voldoende complex en correct (meer dan één tabel (naast de user tabel), tabellen bevatten meerdere kolommen, 2 een-op-veel of veel-op-veel relaties)
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
- een aantal niet-triviale én werkende integratietesten (min. 1 entiteit in REST-laag >= 90% coverage, naast de testen voor user)
- minstens één extra technologie die we niet gezien hebben in de les (zie [sectie 6](#6-voorbeelden-van-extras) voor voorbeelden)
- maakt gebruik van de laatste ES-features (async/await, object destructuring, spread operator...)
- duidelijke en volledige README.md

### Demo

- de student toont een werkende REST API in NodeJS
- de student overloopt de projectstructuur
- de student kan de API calls (CRUD operaties) voor 1 of meerdere entiteiten demonstreren
- de student toont de implementatie/werking van de extra technologie
- alle testen slagen
- de student toont een stukje code waar die fier op is

## 4. Dossier vereisten

Zorg dat de `dossier.md` van je repository aangevuld is, alle vereisten staan in het document.

In dit document staan lijnen die starten met een >, dit zijn instructies. Verwijder deze lijnen voor je het dossier indient!

Dien enkel een pdf in op Chamilo, er zijn genoeg plugins voor VS Code om Markdown naar pdf om te zetten, zoals bv. <https://marketplace.visualstudio.com/items?itemName=yzane.markdown-pdf>.

!> Gebruik een degelijke opmaak in Markdown voor de README en het dossier! Zie [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) voor meer uitleg.

## 5. Demo vereisten

Naast het dossier dien je ook een demo van jouw applicatie op te nemen en te delen via Panopto met jouw lector(en). Deze demo moet voldoen aan de volgende vereisten:

- De demo mag maximaal 15 minuten duren (inclusief Front-end Web Development, indien van toepassing)
- De webcam moet aanstaan tijdens de demo zodat je gezicht zichtbaar is
- Je deelt de demo via Panopto met jouw lector(en) - zorg ervoor dat de toegangsrechten correct ingesteld zijn
- Dit is geen commerciële presentatie, maar een technische demo gericht op de implementatie
- De demo moet opgenomen zijn vóór de deadline (vrijdag 20 december 2024, 23u59)
- De demo moet minstens de volgende onderdelen bevatten/tonen:
  - **Context van de applicatie**: leg uit wat de applicatie doet, wat het doel is en waarom je dit onderwerp gekozen hebt
  - **Projectstructuur overlopen**: overloop kort de mappenstructuur van je project en leg eventuele speciale ontwerpkeuzes uit (waarom bepaalde mappen/bestanden georganiseerd zijn zoals ze zijn)
  - **Demo van de applicatie**:
    - Gebruik de online versie (niet localhost)
    - Toon verschillende functionaliteiten van je API
    - Demonstreer de webservice in Postman door verschillende endpoints uit te testen
    - Toon dat jouw front-end responsive is (indien van toepassing)
  - **Demo van de extra technologie**:
    - Toon de werking van de extra technologie in actie
    - Laat de code zien waar je de extra technologie geïmplementeerd hebt
    - Leg uit waarom je voor deze technologie gekozen hebt
  - **Testen demonstreren**:
    - Laat alle testen lopen via de command line
    - Toon dat ze succesvol slagen
  - **Code showcase**:
    - Toon een stukje code waar je bijzonder fier op bent
    - Leg uit waarom je dit goed vindt en wat het doet
    - Dit geldt voor beide olods (Web Services en Front-end Web Development indien van toepassing)

## 6. Voorbeelden van extra’s

Je vindt misschien wel een interessante extra technologie in de [Node.js Toolbox](https://nodejstoolbox.com/). Een aantal veelgebruikte extra's zijn:

- Upload functionaliteit
- Passport.js voor authenticatie
- Package voor invoervalidatie
- Real time toepassing (sockets...)
- Ander ORM voor de databank
- Ander type databank (document based, column oriented...)
  - Let op: niet elk project is hiervoor geschikt!
- ... (eigen inbreng, verras ons)

Bij het toevoegen van een extra technologie is het belangrijk dat deze ook echt gebruikt wordt in de applicatie. Een package toevoegen die je niet gebruikt, is ook niet-ontvankelijk. Houd ook rekening met de best practices die we in de les gezien hebben bij het implementeren van de extra technologie.

?> Jouw project moet gebruik maken van NestJS als web framework. Andere frameworks zijn niet toegelaten.

## 7. Vragen

Als je vragen of hulp nodig hebt: maak altijd een GitHub issue aan en tag je lector. Gebruik het voorziene template voor het GitHub issue. Uiteraard kan je dit ook gewoon na de les vragen.

Mails worden niet beantwoord.

## 8. Evaluatie

Je wordt beoordeeld op basis van een portfolio dat je samenstelt gedurende het semester. Dit portfolio bestaat uit:

- De code van je applicatie
  - Moet te vinden zijn in de GitHub classroom repository op de `main` branch
- Het ingevulde dossier, als pdf ingediend op Chamilo
- Een demo van je applicatie via een Panopto-opname

Zorg ervoor dat jouw applicatie aan alle minimumvereisten voldoet op het moment van de deadline. We staan toe dat maximaal één minimumvereiste met een gewicht van 2, of twee minimumvereisten met een gewicht van 1, niet worden nageleefd. In alle andere gevallen wordt een score van 0 toegekend. Indien je op Chamilo geen dossier indient, dan krijg je de score AFW.

**De deadline voor het portfolio is het einde van week 13 (vrijdag 19 december 2025, 23u59).**

Alle code zal voor de start van het volgend academiejaar verwijderd worden uit de GitHub classroom. Als je je applicatie wenst te behouden, zorg dan dat je deze tijdig naar een privé repository pusht.

Veel succes!
