# AI statement

## Wat is toegestaan?

?> Voor dit olod hanteren we level 3 van de [AI Assessment Scale](https://arxiv.org/pdf/2412.09029). Probeer wel eerst zelf een oplossing te vinden met behulp van traditionele bronnen alvorens AI-tools te gebruiken, zie bv. <https://www.vaia.be/nl/blog/hoe-vervuilend-is-ai>.

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
- Je mag niet blindelings code kopiëren zonder te begrijpen wat die code doet

**Tijdens de evaluatie:**

- Je moet kunnen uitleggen hoe je code werkt
- Je moet kunnen aantonen dat je de gebruikte technologieën begrijpt
- Het vermelden van AI-hulp in je dossier wordt gewaardeerd, maar is niet verplicht

!> Opgelet, bij de verdediging van je project zullen de bovenstaande voorwaarden wel degelijk geëvalueerd worden.

## Copilot

Via het [GitHub Student Pack](https://education.github.com/pack) krijg je gratis toegang tot GitHub Copilot.
Je bent echter vrij te kiezen welke AI-tool je wenst te gebruiken.

## Algemeen advies

### Configureren AI

Wanneer je werkt met een AI-tool, kan je deze een beetje configureren naar je eigen voorkeur.
Dit doe je door de context van de AI te wijzigen.
Hoe je dit doet, zal je zelf moeten uitzoeken voor de AI-tool van jouw keuze.

Enkele voorbeelden van wat je in deze context zou kunnen plaatsen:

- Vertel de AI hoe je wilt dat hij de uitleg geeft (bv: spreek aan op expert (of juist niet) niveau, gebruik van de gepaste technische termen, ...)
- Bij vragen naar uitleg kan je de AI zeggen om analogiën te gebruiken, indien dit jou helpt om iets te begrijpen.
- Bij vragen naar uitleg is het een goed idee om de AI altijd referenties te laten meegeven, zodat je kan controleren of de uitleg juist is.

### Code generatie

Om de code generatie zo efficiënt mogelijk te laten verlopen, kan je best zorgen dat de AI-tool zoveel mogelijk kennis heeft over wat we net willen bereiken.
Daarom helpt het wanneer er reeds een codevoorbeeld aanwezig is in je project over wat je wilt bereiken.
Dit impliceert meteen al dat je de kennis zelf moet hebben, alvorens de AI-tool te gebruiken.
De AI blijft voor ons een tool om als ontwikkelaar sneller te werken, het is geen vervanging van de ontwikkelaar.

Bij code generatie heb je over het algemeen twee mogelijkheden:

1. In chat formaat vragen stellen, waarbij de AI code aanlevert, waarbij je dan zelf kan kijken wat goed is om toe te passen (eventueel met wijzigingen) in je codebase.
2. Als agent, waarbij je uitleg geeft aan de AI over welke functionaliteit je wilt dat de AI implementeert.

Bij het chat-formaat heb je het meeste controle over wat er precies gebeurt.
Hier kan je eerst uitleg lezen over wat de code net doet, eventueel iteratief de gegenereerde code wijzigen tot het voldoet aan je eisen.
Je kan ook eenvoudig de referenties controleren voordat iets toegevoegd wordt.

Bij het agent-formaat heb je typisch wat minder controle, maar er zijn wel enkele tips die we willen meegeven om de toch zoveel mogelijk controle te hebben:

- Commit altijd je code voordat je de AI agent laat genereren. Dit is nuttig omdat je dan altijd terug kan naar jouw code, van voor de AI wijzigingen doorvoerde. Bovendien kan je in de commit changes ook de kwaliteit van de gegenereerde code controleren.
- Je kan de modus van je agent instellen als auto of manual (auto is meestal de default). Bij manual zal per wijziging gevraagd worden of dit doorgevoerd mag worden of niet. Het kan interessant zijn om deze modus uit te proberen.
- Indien je de automatische tests van je code schrijft voordat je de AI erop los laat, dan kan je onmiddellijk het functionele gedrag van de gegenereerde code controleren.
