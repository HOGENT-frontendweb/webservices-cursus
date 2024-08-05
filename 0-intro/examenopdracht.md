# Web Services Opdracht 2024 - 2025

## 1. De opdracht

Gedurende het semester maak je een API in Node.js. Als je ook het olod Front-end Web Development volgt, zal de API dienen als back-end voor de applicatie die je daar maakt. Indien je het olod Front-end Web Development niet volgt, maak je gewoon een API.

Je bent volledig vrij om te kiezen welke API je ontwikkelt. Indien je twijfelt over jouw idee, mag je altijd eerst met je lector overleggen tijdens de les of een GitHub issue aanmaken.

Alle code moet in een GitHub classroom repository terecht komen (zie Chamilo voor een link naar de classroom). Enkel de `main` branch van deze repository zal geëvalueerd worden. Er wordt automatisch een template van de `README.md` aangemaakt als je de opdracht accepteert, vul deze correct in. Je gebruikt dezelfde repository voor zowel Web Services als Front-end Web Development.

Het is belangrijk dat de applicatie significant verschilt van de voorbeeldapplicatie die tijdens de les gemaakt wordt.

Daarnaast verwachten we dat je een dossier met uitleg over je app indient op Chamilo. Een template voor dit dossier (`dossier.md`) wordt ook aangeleverd als je de opdracht accepteert en dien je te gebruiken. **Je dient het dossier in als PDF!**

## 2. Minimumvereisten

- Een werkende REST API in Node.js
- Domeinlaag met een zekere complexiteit
  - Minstens 2 een-op-veel of veel-op-veel relaties
  - Als je het in één databanktabel kan voorstellen is het te simpel
- Onderliggende databank
- Best practices toepassen
  - invoervalidatie
  - degelijke foutboodschappen bij falende HTTP requests
  - logging
  - gelaagde applicatie
  - ...
- Meerdere routes met invoervalidatie
- Degelijke autorisatie & authenticatie op alle routes
- Gebruik de laatste ES-features (async/await, object destructuring, spread operator...) - dus geen callbacks, then/catch...
- Regelmatige commits in git (één of een paar commits helemaal op het einde wordt niet aanvaard)
- Een aantal niet triviale én werkende integratietesten, de routes van minstens één controller moeten minimaal 80% test coverage hebben
- Correct ingevulde README met een degelijke opmaak in Markdown (zie [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet))
- Een volledig en tijdig ingediend dossier (zie [sectie 3](#3-dossier-vereisten) voor de vereisten)
- De API draait online
- Minimum één extra technologie die we niet gezien hebben in de les (zie [sectie 4](#4-voorbeelden-van-extras) voor voorbeelden)

## 3. Dossier vereisten

Zorg dat de `dossier.md` van je repository aangevuld is, alle vereisten staan in het document.

In dit document staan lijnen die starten met een >, dit zijn instructies. Verwijder deze lijnen voor je het dossier indient!

Dien enkel een PDF in op Chamilo, er zijn genoeg plugins voor VS Code om Markdown naar PDF om te zetten, zoals bv. <https://marketplace.visualstudio.com/items?itemName=yzane.markdown-pdf>.

## 4. Voorbeelden van extra’s

- Ander ORM voor de databank
- Ander type databank (document based, column oriënted…)
  - Let op: niet elk project is hiervoor geschikt
- Ander web framework (Express, Fastify, NestJS...)
  - Let op: nog steeds met het toepassen van de nodige best practices, aangepast aan het framework
- Ander package voor API documentation
- Package voor invoervalidatie
- Real time toepassing (sockets...)
- API in TypeScript i.p.v. JavaScript
- ... (eigen inbreng, verras ons)

## 5. Vragen

Als je vragen of hulp nodig hebt: maak altijd een GitHub issue aan en tag je lector. Gebruik het voorziene template voor het GitHub issue. Uiteraard kan je dit ook gewoon na de les vragen.

Mails worden niet beantwoord.

## 6. Evaluatie

Je wordt beoordeeld op basis van een portfolio dat je samenstelt gedurende het semester. Dit portfolio bestaat uit:

- De code van je applicatie
  - Moet te vinden zijn in de GitHub classroom repository op de `main` branch
- Het ingevulde dossier, als PDF ingediend op Chamilo
- Een ingevulde rubrics (evaluatiekaart) die je kan vinden op Chamilo, en ook ingediend op Chamilo
- Een demo van je applicatie via een Panopto-opname
  - De demo mag maximaal 15 minuten duren
  - De webcam moet aanstaan tijdens de demo
  - Je deelt de demo via Panopto met jouw lector(en)
  - Dit is geen commerciële presentatie, maar een technische demo
  - De demo moet minstens de volgende zaken bevatten/tonen:
    - Context van de applicatie (= wat doet de applicatie? wat is het doel?)
    - Projectstructuur overlopen (mappenstructuur, speciale ontwerpkeuzes...)
    - Demo van de applicatie (gebruik de online versie)
    - Demo van de extra technologie + werking/implementatie
    - Testen laten lopen
    - Toon een stukje code waar je fier op bent en leg uit

**De deadline voor het portfolio is het einde van week 13 (vrijdag 20 december 2024, 23u59).**

Alle code zal een jaar later (januari 2026) verwijderd worden uit de GitHub classroom. Als je je applicatie wenst te behouden, zorg dan dat je ook naar een privé repository pusht.

Veel succes!
