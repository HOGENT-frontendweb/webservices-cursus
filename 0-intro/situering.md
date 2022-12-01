# Algemene info

## Situering

Waarschijnlijk weet je wel tot welk keuzepakket dit vak behoort, maar we bevinden ons voor de duidelijkheid binnen het keuzepakket `Development`:

![Keuzepakketen](./images/MT_development.png ':size=70%')

En meer bepaald hier:

![Dit vak in de keuzepakketen](./images/MT_olods.png ':size=70%')

## Wat gaan we doen?

Concreet gaan we een backend maken met JavaScript. Er zijn ontzettend veel frameworks en libraries om een backend te maken, elk met hun eigen voor- en nadelen.

Wij hebben gekozen voor Koa. Waarom? Het is van de makers van het populaire Express. Jammer genoeg wachten we al jaren op versie 5 van Express en heeft die nog steeds geen native ondersteuning voor async/await. Koa heeft dit wel en bevat standaard niks. Daarom is dit een goeie library om met niets te starten en enkele de nodige dingen toe te voegen.

## Wat gaan jullie doen?

Programmeren leer je enkel door het te doen, niet door onze slides of cursus te lezen. Je zal bijgevolg merken dat in het cursusmateriaal enkel het absolute minimum staat.

Voor dit vak is er een examen-opdracht: [opdracht op Chamilo](https://chamilo.hogent.be/index.php?go=CourseViewer&application=Chamilo%5CApplication%5CWeblcms&course=53234&tool=Document&browser=Table&tool_action=Viewer&publication=2046581). Kort gezegd moet je een NodeJS backend maken tegen week 13. De voorwaarden van deze backend staat duidelijk in de opdracht. De bijbehorende fronend maak je in het vak Front-end Web Development.

Het examen van dit vak is mondeling. Je doet een demo van je applicatie. Dit is geen commerciële presentatie maar simpelweg tonen wat de app kan (en/of wat niet). Daarna beantwoord je enkele vragen die polsen naar je kennis van NodeJS.

De Chamilo-cursus vind je [hier](https://chamilo.hogent.be/index.php?application=Chamilo%5CApplication%5CWeblcms&go=CourseViewer&course=53234). Hierin komen alle belangrijke aankondigingen, een link naar de cursus en een uploadmodule voor de examen-opdracht. Op de cursus zal je ook een link naar de GitHub-classroom zien verschijnen. Zonder repository in deze classroom kunnen wij niet aan je code en kan je hierop dus niet geëvalueerd worden.

### Deadline

> Week 13: vrijdag 23 december om 23u59

Je weet de deadline, plan je werk goed in! Wacht niet tot de laatste paar weken om te starten, dan zal je gegarandeerd in tijdsnood komen. Tijdens de lessen is ook voldoende tijd om aan de applicatie te werken, maak hier gebruik van!

### Voorbeelden

Naar goeie traditie schrijven we hier enkele voorbeelden van jullie voorgangers. Impressioneer ons en mogelijks komt jouw idee hier te staan:

- Auto-verhuur
- Stockbeheer voor het IT-lab
- Chat-applicatie (met WebSockets)
- Beheer van verzamelingen (zeldzame strips, antiek...)
- Websites om te zoeken/luisteren naar podcasts
- Website voor een vereniging of het bedrijf van een vriend(in), familielid...

## Slides?

Het cursusmateriaal wordt op GitHub gehost: <https://hogent-web.github.io/webservices-cursus>.

Er is een voorbeeldapplicatie (stap per stap opgebouwd, zoals in de cursus): <https://github.com/hogent-web/webservices-budget>

De bijhorende frontend is te vinden op: <https://github.com/hogent-web/frontendweb-budget>

Het is de eerste keer dat we met een documentatie-stijl cursus werken, er wordt dus nog aan gesleuteld. Grotendeels worden de slides van vorig jaar hergebruikt in afwachting van een hoofdstuk in deze documentatie.

## Planning

| Week    | Inhoud                                        |
| ------- | --------------------------------------------- |
| week 1  | Inleiding, Javascript                         |
| week 2  | REST, uitleg / voorbeelden                    |
| week 3  | REST API voor onze voorbeeldapp starten       |
| week 4  | REST API voor onze voorbeeldapp starten       |
| week 5  | datalaag en CRUD                              |
| week 6  | datalaag en CRUD                              |
| week 7  | (geen nieuwe theorie, aan de opdracht werken) |
| week 8  | swagger, testen, linter                       |
| week 9  | authenticatie / authorisatie met Auth0        |
| week 10 | CI/CD, online zetten                          |
| week 11 | (geen nieuwe theorie, aan de opdracht werken) |
| week 12 | gastles (?)                                   |

## Help, ik zit vast?

Lees de foutboodschappen, copy paste ze in Google. Vaak 'helpen' we studenten door de fout te copy-pasten en de eerste link in Google te kopiëren.

### Het werkt niet maar geen error te zien?

- eerst en vooral stappen vinden die het probleem reproduceren
- dan het probleem proberen te isoleren (databank? backend? frontend?)
- gebruik een debugger, log statements; denk even na
- nog geen idee? Stel je vraag op StackOverflow!

### Nog altijd vast?

- mail je link naar de StackOverflow-vraag naar ons
- als je met je vraag niet op StackOverflow terecht kan:
  - maak een **GitHub-issue** waar het probleem goed uitgelegd staat
  - vermeld NAAM, KLAS en eventueel een gif die het probleem demonstreert
  - hang jouw lector aan dit issue (als assignee en/of getagd)
  - je krijgt van ons een reactie op dit issue
- debuggen via mail wordt niet gedaan
