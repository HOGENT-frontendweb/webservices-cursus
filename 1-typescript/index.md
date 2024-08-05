# TypeScript

Jullie hebben reeds kennis gemaakt met JavaScript in het olod Web Development II. Dit hoofdstuk heeft als doel om jullie kennis van JavaScript te herhalen, te verdiepen en TypeScript te introduceren.

Laten we eens vragen aan ChatGPT wat TypeScript is:

![TypeScript volgens ChatGPT](./images/typescript_chatgpt.png)

TypeScript is heel simpel gezegd: "JavaScript met types". Het is een superset van JavaScript, wat wil zeggen dat elke JavaScript code ook TypeScript code is. TypeScript voegt enkel types toe aan JavaScript. Onderstaande functie is dus perfect geldige TypeScript code:

```typescript
function add(a, b) {
  return a + b;
}
```

Types geef je aan door na de naam van de variabele een dubbele punt te zetten, gevolgd door de naam van het type. Hetzelfde geldt voor het type van de returnwaarde van een functie.

Met types wordt dit dus:

```typescript
function add(a: number, b: number): number {
  return a + b;
}
```

Deze types worden enkel gebruikt tijdens het schrijven van de code en worden verwijderd tijdens het uitvoeren van de code. TypeScript moet vertaald worden naar JavaScript om uitgevoerd te kunnen worden, dit wordt **transpiling** genoemd.

TypeScript is ontwikkeld door Microsoft en is open-source. Het is een populaire taal in de wereld van web development (zie <https://2023.stateofjs.com/en-US/usage/#js_ts_balance>). TypeScript wordt tegenwoordig meer gebruikt dan pure JavaScript omwille van de types, ES6+ features en soms OO features (als je hiervan houdt). Natuurlijk maakt TypeScript code soms complexer en langer, maar dit weegt niet op tegen de voordelen.

Het vervolg van dit hoofdstuk zal bestaan uit een herhaling van JavaScript en een introductie tot TypeScript. We zullen de belangrijkste basisconcepten en -mogelijkheden van TypeScript overlopen. Daarnast zullen we ook enkele belangrijke concepten van functioneel programmeren in JavaScript/TypeScript overlopen.

Een volledig overzicht van de mogelijkheden van TypeScript kan je vinden in de [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html).

[Basis types](basis-types.md ':include')

[Complexe types](complexe-types.md ':include')

[Functioneel programmeren](functioneel-programmeren.md ':include')

[Async code](async-code.md ':include')

[Array functions](array-functions.md ':include')

## Diverse handigheidjes

JavaScript heeft ook diverse kleine handigheidjes, we vullen deze lijst stelselmatig verder aan als we op iets nieuw stuiten.

### Shorthand object initializer

Bij het aanmaken van objecten moet je steeds `key: value` geven per attribuut in het object. Maar wat als de attributen (en de waarde) uit een variabele komen én de naam van het attribuut is gelijk aan de naam van de variabele? Dan kan je gebruik maken van een verkorte syntax:

<div data-runkit>

```javascript
const name = 'John';
const age = 42;

// dit schrijven (en zien) we niet graag:
const person = {
  name: name,
  age: age,
};

// het kan korter:
const person2 = {
  name,
  age,
};

// beide bevatten hetzelfde:
console.log(person);
console.log(person2);
```

</div>

## Oefeningen

### Oefening 1 - Je eigen project

Denk gedurende deze eerste les na over het onderwerp van de [examenopdracht](./0-intro/situering?id=wat-gaan-jullie-doen). De ervaring leert ons dat het enige tijd vergt om de leerstof van Web Services te verwerken en dat je tijdig moet beginnen aan de opdracht (maar dat is altijd, toch?).

Maak een nieuwe GitHub repository aan via de GitHub classroom link in de introductie van de Chamilo-cursus. Clone jouw GitHub repository uit de GitHub classroom:

```bash
git clone <JOUW_GIT_REPOSITORY_URL>
```

Vul alvast de `README.md` en `dossier.md` aan voor zover mogelijk:

- `README.md`:
  - Vul de titel en je naam, studentennummer en e-mailadres in.
- `dossier.md`:
  - Vul de titel in.
  - Duid aan welk(e) vak(ken) je volgt
  - Vul de link(s) naar de GitHub repository/repositories in.
  - De link naar de online versie kan je nu **nog niet** invullen! Laat deze placeholder gewoon staan.

Commit vervolgens deze wijzigingen:

```bash
git add .
git commit -m "✨ Initial commit ✨"
git push
```

Schrijf in het kort neer waarover de applicatie zal gaan, welke functionaliteiten er *mogelijks* in zullen zitten, welke entiteiten er zullen zijn, welke attributen deze zullen hebben... Je doet dit bij voorkeur in een Markdown-bestand (nee, we gebruiken Word *niet* meer hiervoor). Door in tekstvorm te werken, kan je dit bestand bijhouden in jouw eigen GitHub repository.

Vraag hulp/feedback aan je lector als je onzeker bent over je idee. Je kan dit doen tijdens de les of na de les via een issue op jouw GitHub repository (gebruik het template voor feedback).

### Oefening 2 - TypeScript

Probeer om zoveel mogelijk TypeScript oefeningen te maken vanop deze website: <https://exercism.org/tracks/typescript>. Meld aan met behulp van je GitHub account. Klik vervolgens op `Join the TypeScript Track` en kies ervoor om de online editor te gebruiken. Je kan ook de CLI installeren en de oefeningen lokaal maken, maar dat laten we even achterwege voor deze eerste les.

Als je al ervaring hebt met TypeScript, kan je de oefeningen op deze website proberen: <https://typescript-exercises.github.io/>. Deze oefeningen zijn al iets geavanceerder, probeer m.b.v. de documentatie onderaan elke oefening de oplossing te vinden.

### Oefening 3 - JS drills

Vervolgens loont het de moeite om een aantal JavaScript drill-oefeningen te maken. Tijdens dit olod leer je heel wat nieuws in Node.js, we kunnen niet blijven stilstaan bij basis JavaScript-syntax en -functionaliteiten.

Clone de repository <https://github.com/HOGENT-Web/webservices-ch1-exercise> en lees de instructies in de README. De oplossingen zijn te vinden op de branch [`solution`](https://github.com/HOGENT-Web/webservices-ch1-exercise/tree/solution).

> TODO: TS exercises

## Must read/watch

- [Statements vs. expressions](https://www.joshwcomeau.com/javascript/statements-vs-expressions/)
- [100+ JavaScript Concepts you Need to Know (Fireship)](https://www.youtube.com/watch?v=lkIFF4maKMU)
- [JavaScript for the Haters (Fireship)](https://www.youtube.com/watch?v=aXOChLn5ZdQ)
- [JS Is Weird](https://jsisweird.com/)
