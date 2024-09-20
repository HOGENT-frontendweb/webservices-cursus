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

Een goeie regel is: gebruik een `interface` tot je een `type` nodig hebt (bron: [orta](https://x.com/orta/status/1356129195835973632?s=20))

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

<!-- markdownlint-disable-next-line -->

- Antwoord +

  `value` is beschikbaar in de hele functie, dus op de plaatsen 1, 2, 3 en 4. Dit wordt **hoisting** genoemd.

Het wordt aangeraden om `let` en `const` te gebruiken, omdat dit de scope van de variabele beperkt tot het blok waarin ze gedeclareerd is. `let` wordt gebruikt voor variabelen die van waarde kunnen veranderen, `const` voor variabelen die een constante waarde hebben.

Welke waarde zal er geprint worden in onderstaande code?

<div data-runkit>

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

</div>

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

De OO features van TypeScript worden intensief gebruikt in bv. Angular, een front-end framework. In de olods Web Services en Front-end Web Development zal er echter enkel gebruik gemaakt worden van interfaces.

Je kan hier dus ook keywords als `extends` en `implements` gebruiken om respectievelijk te erven van een klasse/interface of een interface te implementeren.

Je kan aan de constructor van een klasse `private`, `public`, `protected` argumenten meegeven. Dit is syntactic sugar voor het aanmaken van properties met dezelfde naam en het toekennen van de argumenten aan de properties (zie `Persoon2` hierboven).
