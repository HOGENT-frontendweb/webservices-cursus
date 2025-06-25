<!-- markdownlint-disable first-line-h1 -->

## Oefening - Je eigen project

In de vorige les heb je nagedacht over het onderwerp van je examenopdracht. Nu gaan we deze ideeën verder uitwerken tot een concrete API.

### Stap 1: Database ontwerp (ERD)

Ontwerp de database voor je project door een Entity Relationship Diagram (ERD) te maken:

1. Ga naar <https://kroki.io> en gebruik de ERD syntax van <https://github.com/BurntSushi/erd>
2. Denk goed na over:
   - Welke entiteiten je nodig hebt
   - Hoe deze entiteiten met elkaar gerelateerd zijn
   - Hoe je deze relaties wegwerkt in een relationele database
3. Voeg je ERD toe aan je projectdossier (in het bestand `dossier.md`)

### Stap 2: API endpoints definiëren

Maak een markdown document waarin je alle API endpoints van je webservice beschrijft:

1. **URL structuur**: Schrijf de volledige URLs van alle API calls neer
2. **Input/Output**: Beschrijf kort wat elke endpoint verwacht als invoer en wat het teruggeeft
3. **HTTP methoden**: Gebruik de juiste HTTP methoden (GET, POST, PUT, DELETE)
4. **Best practices**: Pas de REST principes toe die je in dit hoofdstuk geleerd hebt

> **Tip**: Gebruik de API calls van het [uitgewerkte voorbeeld](#rest-een-uitgewerkt-voorbeeld) als referentie.

### Stap 3: Feedback vragen

Zodra je een eerste versie van je ERD hebt:

1. **Tijdens de les (bij voorkeur)**: Vraag feedback aan je lector
2. **Na de les**: Maak een issue aan op je GitHub repository
   - Gebruik het feedback template
   - Voeg een afbeelding van je ERD bij
   - Voeg je lector toe als assignee (anders krijgt deze geen melding)

### Stap 4: NestJS project aanmaken

Maak nu je webservice aan:

1. **Projectnaam**: Kies een duidelijke naam met suffix zoals `-webservice` of `-api`
2. **Locatie**: Maak het project aan in de root van je GitHub repository
3. **Setup**: Volg de NestJS setup stappen zoals eerder beschreven

### Stap 5: Git configuratie

Omdat NestJS automatisch een git repository aanmaakt, moet je dit aanpassen:

1. **Verwijder** de (verborgen) `.git` map in je webservice directory:
2. **Controleer** de `.gitignore` om ervoor te zorgen dat `node_modules` niet wordt geüpload
3. **Upload** je webservice naar je GitHub repository

### Stap 6: Documentatie bijwerken

Werk de `README.md` in de root van je repository bij met instructies om de dependencies te installeren en de server te starten.

Verwijder de `README.md` in je webservice map - de `README.md` in de root is voldoende.
