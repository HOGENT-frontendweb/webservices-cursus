<!-- markdownlint-disable first-line-h1 -->

## Types

TypeScript kent een aantal basistypes:

- `number`
- `string`
- `boolean`
- `null`
- `undefined`
- ...

Met enkel speciale:

- `void`: geeft niets terug (`null` of `undefined` zijn dan wel weer mogelijk)
- `any`: eender welke waarde, van eender welk type (niet aanbevolen)
- `never`: geeft nooit iets terug
  - bij `void` kan je nog `return;` doen, bij `never` niet

```typescript
function testVreemd(): void {
  return;
}

function test(): never {
  return; // <-- compile error
}
```

Er zijn ook enkele types voor de OO-mensen onder ons:

- `class`
- `interface`
- `enum`
- `type` (minst OO van allemaal)

`interface` en `type` zijn het meest nuttig om te onthouden. Ze lijken op elkaar, maar hebben enkele verschillen: <https://react-typescript-cheatsheet.netlify.app/docs/basic/getting-started/basic_type_example#useful-table-for-types-vs-interfaces>

Een goeie regel is: gebruik een `interface` tot je een `type` nodig hebt.

### Voorbeeld van een interface

Stel dat we een interface willen maken voor de basis wiskundige operaties (som, aftrekken, vermenigvuldigen, delen).
Hierbij weten we dat we tweemaal een `number` als input willen, en dat we een `number` als output willen.

Dit zouden we zowel als interface als type kunnen maken, zoals te zien is in het onderstaande voorbeeld.
Hierbij is ook meteen duidelijk dat de syntax van de interface en het type zeer gelijkaardig zijn, mits enkele kleine verschillen.

Hierbij zien we dat de ronde haakjes aangeven dat a en b de parameters zijn van het type `number`. 
De functie zelf zal dan een `number` teruggeven.

```typescript
interface BinaryOperationInterface {
  (a: number, b: number): number;
}

type BinaryOperationType = (a: number, b: number) => number;
```

Deze kunnen we vervolgens gebruiken om functies te definiëren. 
Let op, wanneer we gebruik maken van het keyword `function`, moeten we nog steeds de parameters en het return type opgeven.

```typescript
function sum(a: number, b: number): number {
  return a + b;
}
```

Wanneer we nu deze functie als een variabele willen gebruiken, dan kunnen we wel het volledige nut van de interface of het type gebruiken.
Hierbij beschrijven we dus wat het type van de variabele is, waarbij we ons gedefinieerd type/interface gebruiken. 
Vervolgens zetten we het "="-teken, waarbij we de parameters nogmaals moeten herhalen, en de implementatie van de functie volgt.
Hierdoor zal typescript afdwingen dat we dezelfde parameters en return type gebruiken als in de interface/type.

```typescript
const sum: BinaryOperationInterface = (a: number, b: number) => {
  return a + b;
}
```

### Gevorderd voorbeeld

Stel dat we nu zouden willen zorgen dat we eenvoudig reeksen van getallen kunnen vermenigvuldigen, zodat we bijvoorbeeld de tafel van twee, of de tafel van drie, kunnen berekenen.
Daarvoor willen we een vermenigvuldig-functie maken, waarbij we moeten zeggen dat we een getal willen vermenigvuldigen met een andere getal, maar we willen niet telkens de 2 (of 3) opnieuw moeten opgeven.
Hiervoor willen we dus een functie, die een andere functie teruggeeft.
Het onderstaande voorbeeld heeft dus als beschrijving dat we een functie hebben met één parameter (waarbij wij dus willen opgeven dat we willen vermenigvuldigen met 2), en een andere functie als return type, zodat we kunnen meegeven waarmee we willen vermenigvuldigen.

```typescript
type MultiplyFunction = (a: number) => (b: number) => number;
```

Dit kunnen we dan als volgt gebruiken om de tafel van twee te berekenen:

```typescript
const multiply: MultiplyFunction = (a: number) => (b: number) => {
  return a * b;
};

const multiplyByTwo = multiply(2);

for (let i = 0; i < 10; i++) {
  console.log(multiplyByTwo(i));
}
```

Op een volledig analoge manier kunnen we ook de tafel van drie berekenen.

**Deze techniek heet currying.**

## var, let, const

In TypeScript kan je variabelen declareren met `var`, `let` of `const`. `let` en `const` zijn block-scoped, `var` is function-scoped. Dit wil zeggen dat een `var`-variabele overal in de functie beschikbaar is, terwijl een `let`-variabele enkel beschikbaar is in het blok waarin ze gedeclareerd is (bv. binnen een `if` statement).

Waar is de variabele `value` beschikbaar in onderstaande code?

```typescript
function getValue() {
  // 1
  if (condition) {
    var value = 'yes';
    // 2
    return value;
  } else {
    // 3
    return null;
  }
  // 4
}
```

- Antwoord +

  `value` is beschikbaar in de hele functie, dus op de plaatsen 1, 2, 3 en 4. Dit wordt **hoisting** genoemd.

Het wordt aangeraden om `let` en `const` te gebruiken, omdat dit de scope van de variabele beperkt tot het blok waarin ze gedeclareerd is. `let` wordt gebruikt voor variabelen die van waarde kunnen veranderen, `const` voor variabelen die een constante waarde hebben.

Welke waarde zal er geprint worden in onderstaande code?

```javascript
function getValueWithVar() {
  var value = 5;
  if (true) {
    var value = 6;
  }
  console.log(`In getValueWithVar: ${value}`);
}

function getValueWithLet() {
  let value = 5;
  if (true) {
    let value = 6;
  }
  console.log(`In getValueWithLet: ${value}`);
}

getValueWithVar();
getValueWithLet();
```

## Type inference

Het is niet altijd verplicht om elke variabele, functie... te voorzien van een type. TypeScript is slim genoeg om het type af te leiden uit de context, dit heet **type inference**. Met het keyword `typeof` kan je het type van een variabele opvragen, maar dat geeft niet altijd nuttige info (zie variabele `f` hieronder).

```typescript
let a = 1;
let b = 'hello';
let c = true;
let d = null;
let e = undefined;
let f = [1, 2, 3];
let g = { a: 1, b: 2, c: 3 };

console.log('Type of a:', typeof a); // number
console.log('Type of b:', typeof b); // string
console.log('Type of c:', typeof c); // boolean
console.log('Type of d:', typeof d); // object - nja, null is niet echt een object
console.log('Type of e:', typeof e); // undefined
console.log('Type of f:', typeof f); // object - eigenlijk is dit number[]
console.log('Type of g:', typeof g); // object - eigenlijk willen we hier ook een mooier type
```

Een andere waarde toekennen aan een variabele is ook een vorm van type inference. TypeScript laat hierbij niet toe dat je een waarde toekent die niet overeenkomt met het type van de variabele. Afhankelijk van de instellingen van de compiler zal dit een fout of een waarschuwing geven.

```typescript
a = 'test';

console.log('Type of a:', typeof a); // string
```

Je zou ook types kunnen toekennen aan de variabelen door gebruik te maken van de `:` operator. Dit is niet verplicht, maar kan wel handig zijn om de code leesbaarder te maken.

```typescript
let getal: number = 1;
let tekst: string = 'hello';
// ...
```

Het is wel mogelijk om een variable meerdere types te laten aannemen. Dit kan door een `|` te gebruiken tussen de types.

```typescript
let getalOfTekst: number | string = 1;

// en dan later:
getalOfTekst = 'hello';
```

Je kan het zelfs nog wat complexer maken:

```typescript
let x = [1, 'hello', null];
// het type van x is (number | string | null)[]
```

In de documentatie van TypeScript kan je ook lezen dat type inference in de omgekeerde richting ook werkt, dit heet **contextual typing**. Zie hiervoor <https://www.typescriptlang.org/docs/handbook/type-inference.html#contextual-typing>

Je kan ook gedetailleerde types maken voor bijvoorbeeld objecten. Dit kan door gebruik te maken van de `{}` operator. Je kan hiervoor ook een **type alias** maken door gebruik te maken van het `type` keyword.

```typescript
const obj1: { a: number; b: string } = { a: 1, b: 'hello' };

// of
type MyObject = { a: number; b: string }; // of een interface
const obj2: MyObject = { a: 1, b: 'hello' };
```

Er zijn ook programmeurs die meer houden van een OO-aanpak. Daarvoor voorziet TypeScript ook een aantal keywords:

- `class`: om een klasse te maken
- `interface`: om een interface te maken
- `enum`: om een enum te maken

```typescript
enum Kleur {
  Rood,
  Groen,
  Blauw,
}

interface Kaart {
  naam: string;
  kleur: Kleur;
}

class Persoon {
  naam: string;

  constructor(naam: string) {
    this.naam = naam;
  }
}

// of korter:
class Persoon2 {
  constructor(public naam: string) {}
}
```

De OO features van TypeScript worden intensief gebruikt in bv. Angular, een front-end framework.

Je kan hier dus ook keywords als `extends` en `implements` gebruiken om respectievelijk te erven van een klasse/interface of een interface te implementeren.

Je kan aan de constructor van een klasse `private`, `public`, `protected` argumenten meegeven. Dit is syntactic sugar voor het aanmaken van properties met dezelfde naam en het toekennen van de argumenten aan de properties (zie `Persoon2` hierboven).

## Literals

Literals zijn een speciaal type in typescript. 
Hierbij kunnen we omschrijven dat slechts een bepaald aantal specifieke waarden zijn toegestaan.
Het meest voorkomende voorbeeld is het type `string`.
Een voorbeeld hiervan is het veld `state` in het volgende voorbeeld.

Ditzelfde voorbeeld wordt verderop opnieuw gebruikt om aan te geven dat een status ofwel aan het laden, ofwel mislukt, ofwel succesvol is.
In dit voorbeeld tonen we aan dat bij het type `NetworkLoadingState` de waarde van het veld `state` altijd `loading` is. 

```typescript
type NetworkLoadingState = {
  state: 'loading';
};
type NetworkFailedState = {
  state: 'failed';
  code: number;
};
type NetworkSuccessState = {
  state: 'success';
  response: {
    title: string;
    duration: number;
    summary: string;
  };
};
```

### Sidenote Arrays

In de bovenstaande voorbeelden hebben we gezien dat we een array kunnen typeren met de volgende syntax:

```typescript
type GetallenArray = number[];
```

In typescript is er echter ook een specifiek type voor arrays:

```typescript
type GetallenArray = Array<number>;
```

Hierbij is er geen echte voorkeur over dewelke gebruikt wordt.