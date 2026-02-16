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

## Hoe commit ik best?

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
