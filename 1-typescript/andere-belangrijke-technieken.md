<!-- markdownlint-disable first-line-h1 -->

## Andere belangrijke technieken

### Spread operator

De spread operator (`...`) is een operator die je toelaat om een expressie uit te breiden. 
Je kan de spread operator gebruiken om bv. een array te maken met de elementen van een andere array, een object uit te breiden met de attributen van een ander object...

Laten we een voorbeeld voor arrays bekijken. 
Let hierbij op de types, deze zijn optioneel (omdat deze via type inference gekend zijn), maar zijn in dit voorbeeld bijgevoegd ter verduidelijking:

```typescript
const myArray: Array<number> = [1, 2, 3, 4, 5];
const myArray2: Array<number> = [6, 7, 8, 9, 10];

// alles in één array plaatsen met spread operator:
const theArray: Array<number> = [...myArray, ...myArray2];
console.log(theArray);

// bekijk het verschil zonder de spread operator:
const theArray2: Array<Array<number>> = [myArray, myArray2];
console.log(theArray2);
```

Met objecten kunnen we ook gebruik maken van de spread operator:

```typescript
type NameAndAge = {
  name: string;
  age: number;
};

type Birthday = {
  birthday: string;
};

const myObject: NameAndAge = {
  name: 'John',
  age: 42,
};
const myObject2: Birthday = {
  birthday: '01-01-1970',
};

// alles in één object plaatsen:
const theObject: NameAndAge & Birthday = {
  ...myObject,
  ...myObject2,
};
console.log(theObject);

// bekijk het verschil zonder de spread operator, het type dat hieruit komt is er nogmaals bij gedefinieerd ter verduidelijking:
type ZonderSpread = {
  myObject: NameAndAge;
  myObject2: Birthday;
}

const theObject2: ZonderSpread = {
  myObject,
  myObject2,
};
console.log(theObject2);
```

De spread operator kan ook handig zijn om argumenten door te geven aan een functie:

```javascript
const numbers = [1, 2, 3];
const multiply = (a, b, c) => {
  return a * b * c;
};

console.log(multiply(...numbers));
```

Uit bovenstaande voorbeelden zie je dat dit niet altijd even eenvoudig is, of dat je met of zonder spread operator niet exact hetzelfde resultaat krijgt.
Net daarom is Typescript een goede optie om dit te verhelpen, zodat we dankzij de typering al weten of we de juiste types krijgen.

### Destructuring

Destructuring is een techniek die je toelaat om een object of array te ontleden in variabelen. 
Je kan destructuring gebruiken om bv. een of meerdere keys uit een object te halen en deze op te slaan in variabelen. 
Je kan ook bv. het eerste element uit een array halen en de rest van de array opslaan in een variabele.

Laten we een voorbeeld bekijken:

```javascript
const address = {
  city: 'gent',
  street: 'coupure',
  number: 152,
};

// we halen de straat en het huisnummer uit het object en slaan ze op in variabelen
const { street, number } = address;

console.log(street);
console.log(number);

// je kan ook een element uit de array halen en de rest in een andere array plaatsen:
const numbers = [1, 2, 3, 4, 5];
const [first, ...rest] = numbers;
console.log(first);

// het wordt ook vaak gebruikt om één key uit een object te halen
const { city, ...addressWithoutCity } = address;

console.log(city);
console.log(addressWithoutCity);
```
