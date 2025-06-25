<!-- markdownlint-disable first-line-h1 -->

## REST - Een uitgewerkt voorbeeld

Doorheen de jaren merken we dat vaak dezelfde fouten gemaakt worden bij het ontwerpen van API's voor de examenopdracht. In deze sectie werken we een extra voorbeeld uit, dit staat los van de applicatie die we later in de cursus zullen maken. Het dient louter als voorbeeld voor de veelgemaakte fouten.

In dit extra voorbeeld maken we een applicatie waarmee hobbykoks recepten kunnen opslaan en delen met elkaar. Koks kunnen daarbij recepten van andere koks opslaan om bv. later eens uit te proberen.

### Entiteiten

We hebben drie entiteiten met volgende attributen:

- User
  - firstName
  - lastName
  - address
- Recipe
  - name
- Ingredient
  - name
  - amount
  - unit

### Relaties

We onderscheiden volgende relaties:

- Een gebruiker heeft meerdere opgeslagen recepten (niet verplicht om er te hebben)
- Een recept wordt toegevoegd door één gebruiker, een gebruiker kan meerdere recepten toevoegen
- Een recept heeft meerdere ingrediënten
- Een ingrediënt hoort maar bij één recept

### Veelgemaakte fouten

Door de jaren heen merkten we een aantal terugkomende fouten in het ontwerp van applicaties die gemaakt werden voor onze examenopdracht. We sommen ze hier even op:

- Geen tussentabel voor een veel-op-veel relatie
  - Zie cursus Databases I
- Geen foreign key voor een een-op-veel relatie
  - Zie cursus Databases I
- Samengestelde sleutels i.p.v. een uniek id
  - Eerder praktische afwijking van de cursus Databases I
  - Samengestelde sleutels zijn niet fout, maar in sommige gevallen onhandig in URLs van de API calls
- Adres/locatie als string in een tabel
  - Dit is in principe geen fout, maar het maakt het wel lastiger om queries uit te voeren op het adres
- ERD niet voldoende om doel van de applicatie te verwezenlijken
  - Dit is puur een ontwerpfout
  - Denk vooraf goed na over de functionaliteiten van je applicatie en wat je daarvoor nodig hebt in de databank
- Geen API call definities
  - Dit is ook een ontwerpfout, maar eerder op het niveau van documentatie
  - Denk vooraf goed na over de functionaliteiten van je applicatie en welke API calls je daarvoor nodig hebt
- GET all request geeft alle relaties van een entiteit terug
  - Dit is vaak onnodig en kan de databank onnodig belasten
  - In sommige gevallen is het wel nuttig, het hangt allemaal af van de verwachtingen van de client
  - Aangezien je zelf de client ontwerpt in Front-end Web Development, kan je dit zelf bepalen o.b.v. wat je toont in bijvoorbeeld lijsten of tabellen van die entiteit

### ERD met veelgemaakte fouten

Onderstaand ERD zou een oplossing zijn voor onze receptenapplicatie, vol met bovenstaande veelgemaakte fouten:

![Oplossing met FME](https://kroki.io/erd/svg/eNqLDkpNzixIjeXSykvMTeXiivbMSy9KTclMzSuBiSXm5pfmlXCV5mWWAOVDi1OLgDKZKVxpmUXFJX4gFTmJUEZiSkpRanExFxdIlYKhrq6WAsR8LggFEUJYAVGnhaQOAI2aLp8=)

- Broncode +

  Onderstaande code werd hiervoor gebruikt:

  ```erd
  [Recipe]
  *name

  [Ingredient]
  *name
  amount
  unit

  [User]
  *id
  firstName
  lastName
  address

  User 1--* Recipe
  Recipe 1--* Ingredient
  User *--* Recipe
  ```

Wat is er fout aan dit ERD?

### ERD

Een mogelijke oplossing ziet eruit als volgt:

![Oplossing ERD](https://kroki.io/erd/svg/eNpNjjEOwjAMRXefonOqDL0CTF0YQEwVQ2g-KFKTVI6DxO1pSAWZ_GU9P__pjNmtuJFyloLxoH5mGIE9vImmMTwZ1iFIQxgfcxDKwQn1_L0f7QZfE7hiD8dJToVdzB6SMCAUsr-DaY1JzHKMFjQ7KZ8u5gX7K9PnzbVJVeMv-m7QWnUVozrq6l-04RonNblTWg-75AMGd1SG)

- Broncode +

  Onderstaande code werd gebruikt voor de oplossing:

  ```erd
  [Recipe]
  *id
  name
  +createdBy

  [Ingredient]
  *id
  name
  amount
  unit
  +recipeId

  [User]
  *id
  firstName
  lastName
  street
  number
  postalCode
  city

  [SavedRecipe]
  *+userId
  *+recipeId

  User 1--* Recipe
  Recipe 1--* Ingredient
  User 1--* SavedRecipe
  SavedRecipe *--1 Recipe
  ```

Je merkt nog een samengestelde sleutel in SavedRecipe. Het kan wel nuttig zijn om geen samengestelde sleutels te gebruiken, dat is persoonlijke voorkeur. In dat geval bevat de tabel SavedRecipe ook een id, naast de `userId` en `recipeId`.

Qua invoer via de API calls heeft dit weinig invloed. Een gebruiker zal altijd aangemeld zijn en dus kennen we altijd het `userId`, het `recipeId` wordt meegegeven via de API call.

De code voor het opslaan van een recept kan wel complexer worden. Met samengestelde sleutels zal de databank een fout gooien als je tweemaal hetzelfde recept wil opslaan. Je moet vervolgens zelf deze error parsen, dat kan lastig zijn afhankelijk van de gekozen databank en/of client library. Zonder samengestelde sleutels moet je zelf checken of een recept al dan niet dubbel opgeslagen wordt.

Algemene regel: laat zoveel mogelijk door je databank afhandelen. Deze zijn hiervoor geoptimaliseerd en doen dergelijke checks razendsnel (en sparen extra queries).

### API calls

Hieronder lijsten we de vereiste functionaliteiten van de applicatie op. Denk even na (niet meteen verder scrollen/kijken) en definieer de nodige API calls (volgens de REST principes) om deze functionaliteiten te implementeren.

- Een gebruiker moet alle recepten kunnen bekijken.
- Een gebruiker moet een recept in detail kunnen bekijken (met zijn ingrediënten dus).
- Een gebruiker moet een recept kunnen toevoegen/aanpassen/verwijderen.
- Een gebruiker moet de ingrediënten van een recept kunnen bekijken.
- Een gebruiker moet een ingredient van een recept kunnen toevoegen/aanpassen/verwijderen.
- Een gebruiker moet zijn opgeslagen recepten kunnen bekijken.

#### Recipe

- `GET /api/recipes`: alle recepten zonder ingrediënten, evt. met de gebruiker die het recept toegevoegd heeft
- `GET /api/recipes/:id`: één recept met ingrediënten én de gebruiker die het recept toegevoegd heeft
- `POST /api/recipes`: recept toevoegen met/zonder zijn ingrediënten
  - Of je de ingrediënten in dezelfde call toevoegt of in een aparte call is een ontwerpbeslissing
  - Dat hangt vaak af van de opbouw van de front-end, kijk wat het handigst is voor jouw geval
- `PUT /api/recipes/:id`: recept aanpassen
- `DELETE /api/recipes/:id`: recept verwijderen
- `GET /api/recipes/:recipeId/ingredients`: alle ingrediënten van een recept ophalen
- `POST /api/recipes/:recipeId/ingredients`: een ingrediënt toevoegen aan een recept
- `PUT /api/recipes/:recipeId/ingredients/:id`: een ingrediënt van een recept aanpassen
- `DELETE /api/recipes/:recipeId/ingredients/:id`: een ingrediënt van een recept verwijderen

#### User

- `GET /api/users/:id/recipes`: opgeslagen recepten opvragen
  - Soms wordt ook `GET /api/users/me/recipes` gedaan als je toch aangemeld moet zijn, het id van de gebruiker zit nl. in de token (hierover later meer)

Lees ook de [REST API Design Best Practices for Sub and Nested Resources](https://www.moesif.com/blog/technical/api-design/REST-API-Design-Best-Practices-for-Sub-and-Nested-Resources/).
