# Algemene info

## Situering

Dit olod behoort tot de keuzepakketten `Development` en `AI & Data Engineer`, zoals je hieronder kan zien:

![Dit olod in de keuzepakketten](./images/MT_olods.png ':size=70%')

Indien je in het keuzepakket `Development` zit, dan volg je waarschijnlijk Front-end Web Development gelijktijdig met dit olod. Indien je in het keuzepakket `AI & Data Engineer` zit, dan volg je enkel dit olod.

## Wat gaan we doen?

Concreet maken we een back-end met JavaScript, meer specifiek TypeScript. Er zijn ontzettend veel frameworks en libraries om een back-end te maken, elk met hun eigen voor- en nadelen.

Wij hebben gekozen voor [NestJS](https://nestjs.com/). Waarom? NestJS is een modern framework dat gebouwd is met en voor TypeScript. Het is geïnspireerd door Angular (vooral qua structuur) en maakt gebruik van de nieuwste JavaScript features. Het is modulair opgebouwd, wat het makkelijk maakt om te schalen. Daarnaast heeft het een grote community en veel ingebouwde functionaliteiten zoals dependency injection, wat de ontwikkeling versnelt. Je kan relatief snel een robuuste en onderhoudbare back-end opzetten met NestJS. NestJS staat ook op plaats 2 in de [State of JS 2024 Backend Frameworks](https://2024.stateofjs.com/en-US/other-tools/#backend_frameworks), net onder Express. Wat is nu toevallig? NestJS gebruikt standaard Express onder de motorkap, twee vliegen in één klap dus!

## Wat gaan jullie doen?

Programmeren leer je enkel door het te doen, niet door onze cursus te lezen. Je zal bijgevolg merken dat in het cursusmateriaal enkel het absolute minimum staat.

Voor dit olod is er een [examenopdracht](0-intro/examenopdracht.md). Kort gezegd moet je een Node.js back-end maken tegen week 13. De voorwaarden van deze back-end en de examenvorm staan duidelijk in de opdracht. De bijbehorende front-end maak je, indien van toepassing, in het olod Front-end Web Development.

De Chamilo-cursus voor dit olod zal weinig bevatten. Hierin komen enkel de belangrijke aankondigingen, een link naar deze cursus en een uploadmodule voor de examenopdracht. Op de Chamilo-cursus zal je ook een link naar de GitHub-classroom zien. Zonder repository in deze classroom kunnen wij niet aan je code en kan je hierop dus niet geëvalueerd worden.

### Deadline

> Week 13: vrijdag 19 december 2025 om 23u59

Je weet de deadline, plan je werk goed in! Wacht niet tot de laatste paar weken om te starten, dan zal je gegarandeerd in tijdsnood komen. Tijdens de lessen is ook voldoende tijd om aan de applicatie te werken, maak hier gebruik van!

### Voorbeelden

Naar goeie traditie schrijven we hier enkele voorbeelden van jullie voorgangers. Imponeer ons en mogelijks komt jouw idee hier te staan:

- Auto-verhuur
- Stockbeheer voor het IT-lab
- Chat-applicatie (met WebSockets)
- Beheer van verzamelingen (zeldzame strips, antiek...)
- Websites om te zoeken/luisteren naar podcasts
- Quiz-applicatie
- Website voor een vereniging of het bedrijf van een vriend(in), familielid...

## Cursusmateriaal?

Het cursusmateriaal wordt op GitHub gehost: <https://HOGENT-frontendweb.github.io/webservices-cursus>.

Er is een voorbeeldapplicatie (stap per stap opgebouwd, zoals in de cursus): <https://github.com/HOGENT-frontendweb/webservices-budget>.

De bijhorende front-end is te vinden op: <https://github.com/HOGENT-frontendweb/frontendweb-budget>.

Vanaf dit academiejaar worden de voorbeeldapplicatie en cursus van dit olod stelselmatig omgevormd naar NestJS. Een deel van de hoofdstukken is al omgezet, maar nog niet alles. We geven duidelijk aan wanneer een hoofdstuk nog niet omgezet is (`WIP` naast de titel). Wees dus niet verrast als een hoofdstuk nog Koa gebruikt of er plots helemaal anders uitziet.

> Suggesties voor verbeteringen of aanpassingen van schrijffouten zijn altijd welkom! Maak hiervoor een issue of pull request op de GitHub-repository van de cursus: <https://github.com/HOGENT-frontendweb/webservices-cursus>.

## Planning

Deze planning is een richtlijn en kan nog wijzigen in functie van verlofdagen.

| Week    | Inhoud                                         |
| ------- | ---------------------------------------------- |
| week 1  | Inleiding, TypeScript                          |
| week 2  | TypeScript, REST API intro                     |
| week 3  | REST API intro + bouwen                        |
| week 4  | REST API bouwen                                |
| week 5  | Datalaag en places                             |
| week 6  | Relaties                                       |
| week 7  | Validatie en foutafhandeling                   |
| week 8  | Authenticatie / autorisatie                    |
| week 9  | Authenticatie / autorisatie + API documentatie |
| week 10 | Testen                                         |
| week 11 | CI/CD (= online zetten)                        |
| week 12 | (geen nieuwe theorie, aan de opdracht werken)  |

## Help, ik zit vast!

Heb je vragen over de opdracht of loop je vast tijdens de ontwikkeling? Lees de foutboodschappen, copy-paste ze in Google (of een AI tool). Vaak 'helpen' we studenten door de fout te copy-pasten en de eerste link in Google te kopiëren.

Als dat niets oplevert, kan je op twee manieren hulp krijgen:

**Tijdens de les:**

- Stel je vraag rechtstreeks tijdens de lessen
- We plannen bewust tijd in om vragen te beantwoorden en hulp te bieden

**Buiten de les:**

- Maak een GitHub issue aan in jouw repository
  - **Let op:** dit is niet een bestand in de map `.github/ISSUE_TEMPLATE` aanpassen, deze laat je gewoon staan!
  - Meer info over het aanmaken van een GitHub issue: <https://docs.github.com/en/issues/tracking-your-work-with-issues/creating-an-issue>
- Koppel jouw lector aan het issue als assignee
- Gebruik het voorziene template dat automatisch wordt geladen
- Geef voldoende context en details over je probleem
- Om elke student evenveel te kunnen helpen, mag je maximaal 3 issues openen

**Belangrijk:** Technische vragen via e-mail worden niet beantwoord. Gebruik altijd de bovenstaande kanalen voor de beste en snelste hulp.

## Mag ik AI gebruiken?

?> Voor dit olod hanteren we level 3 van de [AI Assessment Scale](https://arxiv.org/pdf/2412.09029). Probeer wel eerst zelf een oplossing te vinden m.b.v. traditionele bronnen alvorens AI tools te gebruiken, zie bv. <https://www.vaia.be/nl/blog/hoe-vervuilend-is-ai>.

**Wat mag je met AI tools:**

- Code genereren en laten uitleggen
- Documentatie schrijven (dossier, README)
- Testdata genereren
- Concepten laten uitleggen die je niet begrijpt
- Brainstormen over ideeën voor je project
- Debugging hulp en foutboodschappen laten uitleggen

**Belangrijke voorwaarden:**

- Je moet alle gegenereerde code grondig begrijpen
- Je bent volledig verantwoordelijk voor de kwaliteit en correctheid
- Je moet de code kunnen uitleggen tijdens de demo (bv. je extra technologie)
- Je mag niet blindelings code kopiëren zonder te begrijpen wat het doet

**Tijdens de evaluatie:**

- Je moet kunnen uitleggen hoe je code werkt
- Je moet kunnen aantonen dat je de gebruikte technologieën begrijpt
- AI-hulp vermelden in je dossier wordt gewaardeerd maar is niet verplicht
