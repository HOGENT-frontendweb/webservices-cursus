<!-- markdownlint-disable first-line-h1 -->

## Functioneel programmeren

Functies zijn first-class citizens in JavaScript. Dit wil zeggen dat je functies kan doorgeven als argument aan een andere functie, kan teruggeven als resultaat van een functie en kan opslaan in een variabele.

Tot nu toe heb je enkel object-georiënteerd geprogrammeerd. Dit is een totaal andere manier van programmeren. In object-georiënteerd programmeren staat een object centraal. Dit object heeft een aantal eigenschappen en methodes. In functioneel programmeren staat een functie centraal. Deze functie heeft een aantal argumenten en een resultaat. In vergelijking met OO programmeren, draait functioneel programmeren meer rond _wat_ je wil doen en niet _hoe_ je het wil doen.

JavaScript is niet helemaal functioneel. Je hebt nl. ook nog objecten en klassen, side effects (globale variabelen)... Maar je kan wel functioneel programmeren in JavaScript. In de olods Web Services en Front-end Web Development zal daarom uitsluitend functioneel geprogrammeerd worden. Je bent natuurlijk vrij om klassen te gebruiken, maar dit zal niet de focus van deze olods zijn.

De belangrijkste onderdelen van JavaScript om functioneel te programmeren zijn:

- functies als first-class citizens
- recursie
- arrow functies
- closures
- currying
- spread operator (en destructuring)

Hieronder zullen we deze onderdelen bespreken in JavaScript, maar je kan deze ook in TypeScript gebruiken.

### Functies als first-class citizens

Je kan in JavaScript op twee manieren een functie definiëren. De eerste functie gebruikt het keyword `function`, de tweede functie wordt een **arrow function** genoemd. Je kan beide functies uitvoeren en het resultaat opslaan in een variabele:

```javascript
function f(a) {
  return a * 2;
}

const g = (a) => {
  return a * 2;
};

const x = f(4);
const y = g(5);
console.log(x); // x = 8
console.log(y); // y = 10
```

Functies gedragen zich erg als objecten. Telkens een functie nodig is (omdat ze uitgevoerd wordt, of omdat ze aan een variabele toegewezen wordt) wordt er geheugen gealloceerd en een nieuw functie object toegewezen. Twee functies die er exact hetzelfde uitzien, zijn dus niet hetzelfde object:

```javascript
const g = (a) => {
  return a * 2;
};

const h = (a) => {
  return a * 2;
};
console.log(g === h);
```

Daarnaast is het ook mogelijk om functies door te geven als argument aan een andere functie:

```javascript
function greet(name, greetingFn) {
  console.log(greetingFn(name));
}

function sayHello(name) {
  return 'Hello ' + name + '!';
}

greet('John', sayHello);

// of meteen inline:
greet('John', function sayGoodbye(name) {
  return 'Goodbye ' + name + '!';
});
```

### Recursie

Recursie kennen we al: een functie roept zichzelf aan tot we in een of meerdere basisgevallen uitkomen. In JavaScript is het ook mogelijk om recursie te gebruiken. Laten we het typische voorbeeld van faculteit nemen als demonstratie:

```javascript
function faculteit(n) {
  if (n === 0) {
    return 1;
  }

  return n * faculteit(n - 1);
}

console.log(faculteit(5));
```

Met recursie kan je alles doen wat je met `while`- en `for`-lussen kan doen. Dat wil niet zeggen dat je nu alles met recursie moet doen, het is niet altijd de meest efficiënte oplossing. Maar het is wel een krachtig concept dat je zeker moet kennen.

### Closures

Een closure is een functie die een andere functie teruggeeft. De teruggegeven functie heeft toegang tot de lokale variabelen van de functie waarin ze gedefinieerd is. Dit is een krachtig concept dat je toelaat om bepaalde zaken te verbergen voor de buitenwereld, je zou het bijna kunnen vergelijken met private attributen in een klassen.

Laten we een voorbeeld bekijken:

```javascript
function createCounter() {
  let count = 0;
  return () => {
    count++;
    return count;
  };
}

const counter = createCounter();
console.log(counter());
console.log(counter());
console.log(counter());
```

Deze functie definieert een variabele `count` gelijk aan nul. Vervolgens geeft er een functie terug die dit getal verhoogt en teruggeeft. We kunnen de functie blijven aanroepen en krijgen telkens een hoger getal terug. Merk dus op dat de functie `counter` nog steeds toegang heeft tot de variabele `count`, ook al is de functie `createCounter` al lang uitgevoerd.

### Currying

Functies die een andere functie teruggeven worden vaak gebruikt en kunnen nuttig zijn. Soms weet je bepaalde argumenten nog niet op voorhand en wil je die later nog kunnen invullen. Dit kan met currying. Currying is een techniek waarbij je een functie kan aanroepen met een deel van de argumenten. De functie geeft dan een nieuwe functie terug die je kan aanroepen met de rest van de argumenten.

Laten we een voorbeeld bekijken:

```javascript
// we maken een functie die een functie teruggeeft
// deze functie vermenigvuldigt een getal met een ander getal dat we reeds hebben meegegeven
const multiplier = (a) => {
  return (b) => {
    return a * b;
  };
};

const double = multiplier(2);
const times5 = multiplier(5);

console.log(double(4));
console.log(times5(4));

// je kan ook meteen de functie aanroepen
console.log(multiplier(2)(4));
console.log(multiplier(5)(4));
```

### Arrow function

We hebben reeds gezien dat we functies op twee manieren kunnen definiëren. Een van die manieren is een arrow function. Hierbij maken we geen gebruik van het `function` keyword, maar gebruiken we een pijltje `=>` om de functie te definiëren. De functie `faculteit` kunnen we dus ook als volgt definiëren:

```javascript
const faculteit = (n) => {
  if (n === 0) {
    return 1;
  }

  return n * faculteit(n - 1);
};

console.log(faculteit(5));
```

Bij een arrow function is `return` niet altijd verplicht. Je kan alles in één oneliner schrijven zonder de accolades en de `return`. De arrow functie zal dan automatisch het resultaat van de expressie teruggeven:

```javascript
const add = (a, b) => {
  return a + b;
};

// is gelijk aan:
const add2 = (a, b) => a + b;

console.log(add(1, 2));
console.log(add2(1, 2));
```

### Spread operator

De spread operator (`...`) is een operator die je toelaat om een expressie uit te breiden. Je kan de spread operator gebruiken om bv. een array te maken met de elementen van een andere array, een object uit te breiden met de attributen van een ander object...

Laten we een voorbeeld voor arrays bekijken:

```javascript
const myArray = [1, 2, 3, 4, 5];
const myArray2 = [6, 7, 8, 9, 10];

// alles in één array plaatsen:
const theArray = [...myArray, ...myArray2];
console.log(theArray);

// bekijk het verschil zonder de spread operator:
const theArray2 = [myArray, myArray2];
console.log(theArray2);
```

Met objecten kunnen we ook gebruik maken van de spread operator:

```javascript
const myObject = {
  name: 'John',
  age: 42,
};
const myObject2 = {
  birthday: '01-01-1970',
};

// alles in één object plaatsen:
const theObject = {
  ...myObject,
  ...myObject2,
};
console.log(theObject);

// bekijk het verschil zonder de spread operator:
const theObject2 = {
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

### Destructuring

Destructuring is een techniek die je toelaat om een object of array te ontleden in variabelen. Je kan destructuring gebruiken om bv. een of meerdere keys uit een object te halen en deze op te slaan in variabelen. Je kan ook bv. het eerste element uit een array halen en de rest van de array opslaan in een variabele.

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
