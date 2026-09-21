# Git & GitHub

Indien Git je onbekend is, kan je hier links en documentatie terugvinden om te leren hoe je Git kan gebruiken.

## Leren werken met Git

Onze basisgids vind je hier: <https://hogenttin.github.io/git-hogent-gids/>. Daar vind je per semester een oplijsting van de Git concepten die je zou moeten beheersen.

De informatie en tutorials hieronder bieden veel meer en uitgebreidere info rond het (correct) gebruiken van Git. Deze komen in verschillende vormen: tekst, video's, interactieve games, enz. Zo kan je de tutorials kiezen die jou het beste liggen.

Zorg ervoor dat je volgende commando's zeker begrijpt: `git clone`, `git pull`, `git add`, `git status`, `git commit`, `git push`, `git checkout`, `git branch`, `git merge` en `git log`.

We raden sterk aan om gebruik te maken van commando's in de terminal. GUI's of plugins voor Git kunnen handig zijn, maar ook leiden tot dataverlies indien je niet goed weet waar je mee bezig bent! Daarnaast is het niet altijd duidelijk welk commando of welke opties een GUI gebruikt. Leer eerst de basics en wat de commando's doen op de CLI, alvorens gebruik te maken van GUI's.

### Video's

- Korte introductie in verschillende Git concepten: <https://www.youtube.com/watch?v=HkdAHXoRtos>
  - Wil je meer geavanceerde tips? Kijk dan eens op <https://www.youtube.com/watch?v=ecK3EnyGD8o>
- Wat is het verschil tussen Git en GitHub? <https://www.youtube.com/watch?v=wpISo9TNjfU>
- Git voor absolute beginners: <https://www.youtube.com/watch?v=CvUiKWv2-C0>
- Git en GitHub voor beginners: <https://www.youtube.com/watch?v=tRZGeaHPoaw>
- <https://git-scm.com/videos>
- Gratis voor HOGENT-studenten: <https://www.linkedin.com/learning/git-essential-training-19417064/get-started-with-git?u=121303466>

### Blogs, docs en ander geschreven materiaal

- <https://www.gitkraken.com/learn/git/tutorials>
- <https://www.atlassian.com/git/tutorials/learn-git-with-bitbucket-cloud>
- <https://www.baeldung.com/ops/git-guide>
- <https://www.learnenough.com/git-tutorial/getting_started>
- Het Pro Git boek: <https://git-scm.com/book/en/v2>
  - Ook beschikbaar in het Nederlands: <https://git-scm.com/book/nl/v2>
  - Vooral hoofdstuk 1, 2 en 3 zijn belangrijk

### Games

- <https://learngitbranching.js.org/>
- <https://gitimmersion.com/>
- <https://ohmygit.org/>

### Config

Zoek je inspiratie voor jouw `.gitconfig`? Probeer dan eens volgende template:

```ini
[color]
    ui = always

[diff]
    colorMoved = default

[init]
    defaultBranch = main

[merge]
    conflictstyle = diff3

[push]
    default = simple

[user]
    name = Jouw Naam
    email = jouw.naam@student.hogent.be
```

Extra handige informatie voor `git-config`:

- <https://adaptivepatchwork.com/2012/03/01/mind-the-end-of-your-line/>

## Feature Branch Workflow

Om professioneel samen te werken aan het project gebruiken jullie de **Feature Branch Workflow**. Hierbij wordt elke nieuwe functionaliteit ontwikkeld in een aparte branch. Zo blijft de `main`-branch steeds een stabiele en werkende versie van de applicatie bevatten.

### Waarom gebruiken we deze workflow?

De Feature Branch Workflow biedt verschillende voordelen:

- Teamleden kunnen gelijktijdig aan hetzelfde project werken.
- Nieuwe functionaliteiten worden geïsoleerd ontwikkeld en getest.
- Conflicten worden sneller opgespoord en opgelost.
- De geschiedenis van het project blijft overzichtelijk.
- De workflow sluit aan bij de werkwijze die in professionele softwareteams wordt gebruikt.

### Stappenplan

### 1. Maak een feature branch

Voor elke nieuwe functionaliteit maak je een aparte branch vanuit de `main`-branch.

```bash
git checkout main
git pull origin main
git checkout -b feature/login
```

Gebruik duidelijke namen die beschrijven aan welke functionaliteit je werkt.

Voorbeelden:

```text
feature/login
feature/product-overview
feature/favorites
feature/profile
```

### 2. Ontwikkel en commit regelmatig

Werk de functionaliteit uit op je eigen branch en maak regelmatig commits.

```bash
git add .
git commit -m "Voegt loginformulier toe"
```

Geef je commits een duidelijke beschrijving van de aangebrachte wijziging. (zie [Hoe commit ik best?](#11-hoe-commit-ik-best))

### 3. Push de branch naar GitHub

Publiceer je branch op GitHub.

```bash
git push -u origin feature/login
```

Zo kan je teamlid je werk bekijken en opvolgen.

### 4. Synchroniseer met main

Werk je feature branch bij met de laatste wijzigingen uit main. Doe dit regelmatig, zeker voordat je een Pull Request maakt. Zo voorkom je dat er conflicten ontstaan bij het mergen.

```bash
git checkout main
git pull origin main
git checkout feature/login
git merge main
```

### 5. Maak een Pull Request

Wanneer de functionaliteit klaar is, maak je op GitHub een **Pull Request (PR)** van je feature branch naar `main`. Een Pull Request is een verzoek om jouw wijzigingen toe te voegen aan de hoofdversie van het project. Je zegt eigenlijk tegen je team:
"Ik ben klaar met mijn werk. Kunnen jullie mijn code nakijken en goedkeuren voordat ze in main terechtkomt?"

In de Pull Request beschrijf je:

- welke functionaliteit werd toegevoegd;
- welke bestanden aangepast werden;
- hoe de functionaliteit getest kan worden;
- eventuele gekende beperkingen of aandachtspunten.

Zie  <https://docs.github.com/en/pull-requests/reference/pull-requests> voor meer info over Pull Requests.

### 6. Voer een code review uit

Voordat de wijzigingen worden samengevoegd, bekijkt het andere teamlid de code.

Tijdens een code review controleer je onder andere:

- of de functionaliteit correct werkt;
- of de code leesbaar en onderhoudbaar is;
- of de afgesproken coding standards gevolgd worden;
- of er geen onnodige duplicatie aanwezig is.

Indien nodig worden eerst verbeteringen aangebracht voordat de Pull Request wordt goedgekeurd. Zie [Code Review](#code-review) voor meer info over hoe je een code review uitvoert.

### 7. Merge naar main

Na goedkeuring kan de Pull Request worden gemerged.

De nieuwe functionaliteit maakt nu deel uit van de stabiele versie van de applicatie.

Controleer daarna steeds of je lokale versie van `main` up-to-date is:

```bash
git checkout main
git pull origin main
git merge feature/login
```

Een andere optie is een rebase te doen van je feature branch op main. In dit geval worden de commits van je feature branch herschikt op de laatste commit van main. Dit kan handig zijn om een lineaire geschiedenis te behouden.

### 7. Verwijder de feature branches niet!

Na het mergen mag je de feature branches **NIET** verwijderen zodat de lectoren de code kunnen nakijken. Indien je de feature branch lokaal wil verwijderen, kan dat met:

```bash
git branch -d feature/login
```

### Goede afspraken

- Werk **nooit rechtstreeks op de `main`-branch**.
- Maak voor elke nieuwe functionaliteit een aparte feature branch.
- Commit regelmatig met duidelijke commitberichten.
- Maak voor elke feature een Pull Request.
- Laat je code nakijken door je teamlid voordat deze wordt gemerged.
- Synchroniseer regelmatig met de laatste versie van `main`.
- Zorg ervoor dat de applicatie blijft werken voordat een Pull Request wordt goedgekeurd.

### Overzicht

```text
main
 │
 ├── feature/login
 │         │
 │         └── Pull Request ──► main
 │
 ├── feature/favorites
 │         │
 │         └── Pull Request ──► main
 │
 └── feature/profile
           │
           └── Pull Request ──► main
```

Met deze workflow blijft de `main`-branch steeds stabiel en kunnen beide teamleden onafhankelijk van elkaar aan nieuwe functionaliteiten werken zonder elkaars werk te verstoren.

## 11. Hoe commit ik best?

Een commit zou idealiter één logische wijziging bevatten. Commit dus niet alles in één keer op het einde van de dag, maar commit regelmatig na elke afgeronde stap. Enkele richtlijnen:

- **Klein en gefocust**: één commit = één reden om te wijzigen. Vermeng geen bugfix met een nieuwe feature in dezelfde commit.
- **Werkende toestand**: elke commit zou de code in een werkende toestand moeten achterlaten. Commit geen halfafgewerkte code.
- **Niet te klein**: het heeft weinig zin om elke typtfout als aparte commit te registreren. Groepeer gerelateerde kleine wijzigingen.

### Conventional Commits

Een goede commitboodschap maakt duidelijk *wat* er veranderd is en *waarom*. De [Conventional Commits](https://www.conventionalcommits.org/)-specificatie is een veelgebruikte standaard die een gestructureerd formaat oplegt:

```text
<type>(<scope>): <beschrijving>
```

De meest gebruikte types zijn:

| Type       | Gebruik                                    |
| ---------- | ------------------------------------------ |
| `feat`     | Een nieuwe feature                         |
| `fix`      | Een bugfix                                 |
| `refactor` | Herstructurering zonder gedragswijziging   |
| `test`     | Toevoegen of aanpassen van tests           |
| `docs`     | Documentatiewijzigingen                    |
| `chore`    | Onderhoudstaken (bv. dependencies updaten) |

Enkele voorbeelden:

```text
feat(auth): add JWT-based login endpoint
fix(places): return 404 when place is not found
refactor(users): extract password hashing to helper function
docs(readme): update setup instructions
```

De `scope` is optioneel maar helpt om snel te zien welk onderdeel van de codebase geraakt wordt.

Meer info vind je op <https://www.conventionalcommits.org/>.

## Code Review

Een code review is een gestructureerde controle van code die door een teamlid werd geschreven. Het doel is om fouten vroegtijdig op te sporen, de kwaliteit van de code te verbeteren en kennis binnen het team te delen.

Bij elke Pull Request voert je medestudent een code review uit voordat de wijzigingen naar `main` worden gemerged.

### Hoe voer je een code review uit?

#### 1. Open de Pull Request

Bekijk eerst de beschrijving van de Pull Request:

- Wat werd ontwikkeld?
- Welke functionaliteit werd toegevoegd of gewijzigd?
- Zijn er specifieke aandachtspunten?

Controleer of de wijzigingen overeenkomen met het doel van de feature.

#### 2. Test de functionaliteit

Controleer of de nieuwe functionaliteit correct werkt:

- Werkt alles zoals verwacht?
- Zijn er foutmeldingen?
- Werken bestaande functionaliteiten nog steeds?

#### 3. Bekijk de code

Lees de gewijzigde bestanden aandachtig en stel jezelf de volgende vragen:

#### Correctheid

- Werkt de code correct?
- Zijn alle randgevallen behandeld?
- Kan de code onverwachte fouten veroorzaken?

#### Leesbaarheid

- Zijn variabelen en functies duidelijk benoemd?
- Is de code overzichtelijk gestructureerd?
- Zijn complexe stukken voldoende gedocumenteerd?

#### Onderhoudbaarheid

- Kan een andere ontwikkelaar de code gemakkelijk begrijpen?
- Is er onnodige duplicatie aanwezig?
- Zijn componenten niet groter of complexer dan nodig?

#### Best Practices

Voor React-componenten kan je bijvoorbeeld letten op:

- Zijn componenten logisch opgebouwd?
- Wordt state correct gebruikt?
- Is de verantwoordelijkheid van componenten duidelijk afgebakend?
- Worden props correct gebruikt?

### 4. Geef constructieve feedback

Wanneer je een probleem opmerkt, formuleer je feedback op een respectvolle en constructieve manier.

**Goed voorbeeld:**

> Deze logica komt ook voor in component X. Misschien kunnen we hiervan een herbruikbare functie maken.

**Minder goed voorbeeld:**

> Dit is fout.

Leg bij voorkeur uit:

- wat het probleem is;
- waarom het een probleem is;
- hoe het eventueel verbeterd kan worden.

### 5. Keur de Pull Request goed of vraag wijzigingen

Na de review heb je drie mogelijkheden:

- **Approve**: de code voldoet aan de verwachtingen.
- **Comment**: je geeft opmerkingen zonder wijzigingen te eisen.
- **Request changes**: er moeten eerst nog aanpassingen gebeuren.

Pas wanneer alle gevraagde wijzigingen zijn uitgevoerd, mag de Pull Request worden gemerged.

### Checklist voor een code review

Voor je een Pull Request goedkeurt, controleer je of:

- [ ] De applicatie correct werkt.
- [ ] Er geen console-errors aanwezig zijn.
- [ ] De code leesbaar en onderhoudbaar is.
- [ ] Variabelen en functies duidelijke namen hebben.
- [ ] Er geen onnodige duplicatie aanwezig is.
- [ ] De best practices gevolgd worden.
- [ ] De code voldoet aan de afgesproken conventies.
- [ ] De Pull Request beperkt blijft tot één feature.

### Waarom is code review belangrijk?

Door elkaars code te reviewen:

- verhoog je de kwaliteit van het project
- leer je van elkaar
- ontdek je fouten sneller
- zorg je ervoor dat beide teamleden de volledige applicatie begrijpen

Code review is daarom een essentieel onderdeel van professionele softwareontwikkeling.
