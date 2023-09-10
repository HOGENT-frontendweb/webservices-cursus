# JavaScript

Jullie hebben reeds kennis gemaakt met JavaScript in het olod Web Development II. Dit hoofdstuk heeft als doel om jullie kennis van JavaScript te herhalen en op sommige gebieden te verdiepen.

> Merk op: dit hoofdstuk is nieuw sinds dit academiejaar en experimenteert met interactieve JavaScript playgrounds ([Runkit](https://runkit.com/)). Mocht iets niet werken, laat het dan zeker weten aan jouw lector.

## Functioneel programmeren

Functies zijn first-class citizens in JavaScript. Dit wil zeggen dat je functies kan doorgeven als argument aan een andere functie, kan teruggeven als resultaat van een functie en kan opslaan in een variabele.

Tot nu toe heb je enkel object-georiënteerd geprogrammeerd. Dit is een totaal andere manier van programmeren. In object-georiënteerd programmeren staat een object centraal. Dit object heeft een aantal eigenschappen en methodes. In functioneel programmeren staat een functie centraal. Deze functie heeft een aantal argumenten en een resultaat. In vergelijking met OO programmeren, draait functioneel programmeren meer rond *wat* je wil doen en niet *hoe* je het wil doen.

JavaScript is niet helemaal functioneel. Je hebt nl. ook nog objecten en klassen, side effects (globale variabelen)... Maar je kan wel functioneel programmeren in JavaScript. In de olods Web Services en Front-end Web Development zal daarom uitsluitend functioneel geprogrammeerd worden. Je bent natuurlijk vrij om klassen te gebruiken, maar dit zal niet de focus van deze olods zijn.

De belangrijkste onderdelen van JavaScript om functioneel te programmeren zijn:

- functies als first-class citizens
- recursie
- arrow functies
- closures
- currying
- spread operator (en destructuring)

### Functies als first-class citizens

Je kan in JavaScript op twee manieren een functie definiëren. De eerste functie gebruikt het keyword `function`, de tweede functie wordt een **arrow function** genoemd. Je kan beide functies uitvoeren en het resultaat opslaan in een variabele:

<div data-runkit>

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

</div>

Functies gedragen zich erg als objecten. Telkens een functie nodig is (omdat ze uitgevoerd wordt, of omdat ze aan een variabele toegewezen wordt) wordt er geheugen gealloceerd en een nieuw functie object toegewezen. Twee functies die er exact hetzelfde uitzien, zijn dus niet hetzelfde object:

<div data-runkit>

```javascript
const g = (a) => {
  return a * 2;
};

const h = (a) => {
  return a * 2;
}
console.log(g === h);
```

</div>

Daarnaast is het ook mogelijk om functies door te geven als argument aan een andere functie:

<div data-runkit>

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

</div>

### Recursie

Recursie kennen we al: een functie roept zichzelf aan tot we in een of meerdere basisgevallen uitkomen. In JavaScript is het ook mogelijk om recursie te gebruiken. Laten we het typische voorbeeld van faculteit nemen als demonstratie:

<div data-runkit>

```javascript
function faculteit(n) {
  if (n === 0) {
    return 1;
  }

  return n * faculteit(n - 1);
}

console.log(faculteit(5));
```

</div>

Met recursie kan je alles doen wat je met `while`- en `for`-lussen kan doen. Dat wil niet zeggen dat je nu alles met recursie moet doen, het is niet altijd de meest efficiënte oplossing. Maar het is wel een krachtig concept dat je zeker moet kennen.

### Closures

Een closure is een functie die een andere functie teruggeeft. De teruggegeven functie heeft toegang tot de lokale variabelen van de functie waarin ze gedefinieerd is. Dit is een krachtig concept dat je toelaat om bepaalde zaken te verbergen voor de buitenwereld, je zou het bijna kunnen vergelijken met private attributen in een klassen.

Laten we een voorbeeld bekijken:

<div data-runkit>

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

</div>

Deze functie definieert een variabele `count` gelijk aan nul. Vervolgens geeft er een functie terug die dit getal verhoogt en teruggeeft. We kunnen de functie blijven aanroepen en krijgen telkens een hoger getal terug. Merk dus op dat de functie `counter` nog steeds toegang heeft tot de variabele `count`, ook al is de functie `createCounter al lang uitgevoerd.

### Currying

Functies die een andere functie teruggeven worden vaak gebruikt en kunnen nuttig zijn. Soms weet je bepaalde argumenten nog niet op voorhand en wil je die later nog kunnen invullen. Dit kan met currying. Currying is een techniek waarbij je een functie kan aanroepen met een deel van de argumenten. De functie geeft dan een nieuwe functie terug die je kan aanroepen met de rest van de argumenten.

Laten we een voorbeeld bekijken:

<div data-runkit>

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

</div>

### Arrow function

We hebben reeds gezien dat we functies op twee manieren kunnen definiëren. Een van die manieren is een arrow function. Hierbij maken we geen gebruik van het `function` keyword, maar gebruiken we een pijltje `=>` om de functie te definiëren. De functie `faculteit` kunnen we dus ook als volgt definiëren:

<div data-runkit>

```javascript
const faculteit = (n) => {
  if (n === 0) {
    return 1;
  }

  return n * faculteit(n - 1);
}

console.log(faculteit(5));
```

</div>

Bij een arrow function is `return` niet altijd verplicht. Je kan alles in één oneliner schrijven zonder de accolades en de `return`. De arrow functie zal dan automatisch het resultaat van de expressie teruggeven:

<div data-runkit>

```javascript
const add = (a, b) => {
  return a + b;
};

// is gelijk aan:
const add2 = (a, b) => a + b;

console.log(add(1, 2));
console.log(add2(1, 2));
```

</div>

### Spread operator

De spread operator (`...`) is een operator die je toelaat om een expressie uit te breiden. Je kan de spread operator gebruiken om bv. een array te maken met de elementen van een andere array, een object uit te breiden met de attributen van een ander object...

Laten we een voorbeeld voor arrays bekijken:

<div data-runkit>

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

</div>

Met objecten kunnen we ook gebruik maken van de spread operator:

<div data-runkit>

```javascript
const myObject = {
  name: 'John',
  age: 42,
};
const myObject2 = {
  birthday: '01-01-1970',
}

// alles in één object plaatsen:
const theObject = {
  ...myObject,
  ...myObject2,
}
console.log(theObject);

// bekijk het verschil zonder de spread operator:
const theObject2 = {
  myObject,
  myObject2,
};
console.log(theObject2);
```

</div>

De spread operator kan ook handig zijn om argumenten door te geven aan een functie:

<div data-runkit>

```javascript
const numbers = [1, 2, 3];
const multiply = (a, b, c) => {
  return a * b * c;
};

console.log(multiply(...numbers));
```

</div>

### Destrucuring

Destructuring is een techniek die je toelaat om een object of array te ontleden in variabelen. Je kan destructuring gebruiken om bv. een of meerdere keys uit een object te halen en deze op te slaan in variabelen. Je kan ook bv. het eerste element uit een array halen en de rest van de array opslaan in een variabele.

Laten we een voorbeeld bekijken:

<div data-runkit>

```javascript
const address = {
  city: 'gent',
  street: 'coupure',
  number: 152
};

// we halen de naam en leeftijd uit het object en slaan ze op in variabelen
const { street, number } = address;

console.log(street);
console.log(number);

// je kan ook een element uit de array halen en de rest in een andere array plaatsen:
const numbers = [1, 2, 3, 4, 5];
const [first, ...rest] = numbers;
console.log(first);

// het wordt ook vaak gebruikt om één key uit een object te halen
// jammer genoeg werkt dit (nog) niet in Runkit
// (je zal een error krijgen als je onderstaande code uit commentaar haalt)
// const { city, ...addressWithoutCity } = address;

// console.log(city);
// console.log(addressWithoutCity);
```

</div>

## Asynchrone code

JavaScript is een single-threaded taal. Dit wil zeggen dat er maar één thread is die de code uitvoert. Dit is een groot verschil met bv. Java, waar je meerdere threads *kan* hebben die parallel uitgevoerd worden. Dit heeft als gevolg dat JavaScript code asynchroon moet uitgevoerd worden. Als je bv. een API call doet, dan moet je wachten op het resultaat. Als je dit synchroon zou doen, dan zou de hele applicatie blokkeren tot het resultaat van de API call terug is.

In JavaScript werd/wordt dit opgelost door een callback functie mee te geven aan de functie die de API call doet. De callback functie wordt dan uitgevoerd als het resultaat van de API call terug is.

Tegenwoordig wordt er meer en meer gebruik gemaakt van Promises. Een Promise is een object dat een resultaat kan bevatten dat nu nog niet beschikbaar is. Je kan een callback functie meegeven aan de Promise die uitgevoerd wordt als het resultaat beschikbaar is. Je kan ook een callback functie meegeven die uitgevoerd wordt als er een fout optreedt. Promises hebben drie mogelijke toestanden:

- pending: het resultaat is nog niet beschikbaar
- fulfilled: het resultaat is beschikbaar
- rejected: er is een fout opgetreden

Laten we een voorbeeld met callbacks bekijken:

<div data-runkit>

```javascript
// stel we maken een functie die na een bepaalde tijd een callback functie uitvoert
function waitFor(timeInMs, callback) {
  setTimeout(() => {
    callback();
  }, timeInMs);
}

// we kunnen deze functie als volgt gebruiken:
waitFor(1000, () => {
  console.log('Hello world!');
});
// na 1 seconde zal 'Hello world!' afgedrukt worden

// met Promises wordt dit:
function waitForPromise(timeInMs) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve();
    }, timeInMs);
  });
}

// je zal zien dat Runkit de Promise uitprint
// daarop kan je de status van de Promise volgen
waitForPromise(2000).then(() => {
  console.log('Hello world from Promise!');
});

```

</div>

Je kan ook een Promise maken die een fout teruggeeft:

<div data-runkit>

```javascript
function immediatelyFail(timeInMs) {
  return new Promise((resolve, reject) => {
    reject('Something went wrong!');
  });
}

immediatelyFail().catch((error) => {
  console.log(error);
});
```

</div>

Callbacks leiden vaak tot **callback hell**: je moet een callback functie meegeven aan een functie die een callback functie verwacht, die op zijn beurt een callback functie verwacht... Daarom werden in de eerste plaats Promises geïntroduceerd en later ook async/await.

Async/await zijn keywords die toelaten om asynchrone code te schrijven die er synchroon uitziet. Je kan een functie als `async` markeren. Deze functie kan dan `await` gebruiken om te wachten op het resultaat van een Promise. Je kan ook een `try`/`catch` blok gebruiken om fouten op te vangen. Een `async` functie geeft **altijd** een Promise terug, ook al doe je geen expliciete `return`. Met async/await los je dus het probleem van callback hell op.

We raden dus aan om altijd async/await te gebruiken. Je kan nog steeds callbacks gebruiken, maar dit is niet meer nodig.

Laten we een voorbeeld bekijken:

<div data-runkit>

```javascript
// we maken een functie die een bepaalde REST API aanspreekt
// deze functie geeft een Promise terug aangezien ze gebruik maakt van await
async function getMeSomethingFunny() {
  // we wachten op het resultaat van de API call
  const response = await fetch('https://icanhazdadjoke.com', {
    headers: {
      Accept: 'application/json',
    },
  });
  // als we een resultaat hebben, dan zetten we het om naar JSON
  const data = await response.json();
  // we geven het resultaat terug
  // dit wordt automatisch omgezet naar een Promise
  return data.joke;
}

const joke = await getMeSomethingFunny();
console.log(joke);

// zonder await krijgen we de Promise terug die "ooit" een dad joke zal bevatten
const jokeWithoutAwait = getMeSomethingFunny();
console.log(jokeWithoutAwait);
```

</div>

## Array functions

JavaScript heeft een aantal handige functies die je kan gebruiken op arrays. Deze functies zijn geïnspireerd op functioneel programmeren en zijn dus erg handig om te gebruiken. We overlopen de belangrijkste functies:

- `sort`: deze functie sorteert de elementen van een array (sorteert in-place, dus je moet geen nieuwe array maken).

<div data-runkit>

```javascript
const numbers = [5, 2, 3, 1, 4];
numbers.sort();
console.log(numbers);
```

</div>

- `map`: deze functie past een functie toe op elk element van een array en geeft een nieuwe array terug met de resultaten.

<div data-runkit>

```javascript
const numbers = [5, 2, 3, 1, 4];
const doubled = numbers.map((number) => {
  return number * 2;
});
console.log(doubled);
```

</div>

- `filter`: deze functie past een functie toe op elk element van een array en geeft een nieuwe array terug met de elementen die voldoen aan de functie.

<div data-runkit>

```javascript
const numbers = [5, 2, 3, 1, 4];
const even = numbers.filter((number) => {
  return number % 2 === 0;
});
console.log(even);
```

</div>

- `reduce`: deze functie past een functie toe op elk element van een array en geeft **één** resultaat terug (je doet dus aggregatie). Het eerste argument is een functie met twee parameters: het tussenresultaat van de reduce en de huidige waarde in de array. Je geeft als tweede argument (na de functie) een startwaarde mee.

<div data-runkit>

```javascript
const numbers = [5, 2, 3, 1, 4];
const sum = numbers.reduce((accumulator, number) => {
  return accumulator + number;
}, 0);

// reduce kan je ook gebruiken om een group by te doen
// laten we de even en oneven getallen groeperen in een array
const groupBy = numbers.reduce((accumulator, number) => {
  if (number % 2 === 0) {
    accumulator.even.push(number);
  } else {
    accumulator.odd.push(number);
  }
  return accumulator;
}, {
  even: [],
  odd: [],
});
```

</div>

- `forEach`: deze functie past een functie toe op elk element van een array en geeft niets terug. Je gebruikt deze functie dus om een side effect te hebben (bv. iets afdrukken). Deze functie wordt vaak misbruikt als je eigenlijk `map` wil gebruiken.

<div data-runkit>

```javascript
const numbers = [5, 2, 3, 1, 4];
numbers.forEach((number) => {
  console.log(number);
});

// misbruik terwijl je eigenlijk map wil gebruiken:
const doubled = []
numbers.forEach((number) => {
  doubled.push(number * 2);
});
console.log(doubled);
```

</div>

- `find`: deze functie past een functie toe op elk element van een array en geeft het eerste element terug dat voldoet aan de functie. Als er geen element voldoet aan de functie, dan geeft de functie `undefined` terug.

<div data-runkit>

```javascript
const numbers = [5, 2, 3, 1, 4];
const firstEven = numbers.find((number) => {
  return number % 2 === 0;
});
console.log(firstEven);
```

</div>

- `some`: deze functie past een functie toe op elk element van een array en geeft `true` terug als minstens één element voldoet aan de functie.

<div data-runkit>

```javascript
const numbers = [5, 2, 3, 1, 4];
const hasBigNumber = numbers.some((number) => {
  return number > 10;
});
console.log(hasBigNumber);
```

</div>

- `every`: deze functie past een functie toe op elk element van een array en geeft `true` terug als alle elementen voldoen aan de functie.

<div data-runkit>

```javascript
const numbers = [5, 2, 3, 1, 4];
const areSmallNumbers = numbers.every((number) => {
  return number <= 5;
});
console.log(areSmallNumbers);
```

</div>

- `includes`: deze functie geeft `true` terug als een array een bepaald element bevat.

<div data-runkit>

```javascript
const numbers = [5, 2, 3, 1, 4];
const hasThree  = numbers.includes(3);
console.log(hasThree);
```

</div>

Er komen steeds nieuwe functies bij. Je kan de volledige lijst van functies vinden op [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array). Mogelijks zijn nieuwe functies nog niet meteen ondersteund door Node.js of door browsers. Je kan dan gebruik maken van een polyfill om de functies toch te gebruiken, bundlers (zie Front-end Web Development) kunnen hier ook bij helpen.

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

## Oefening

### Examenopdracht

Denk gedurende deze eerste les na over het onderwerp van de [examenopdracht](../0-intro/situering?id=wat-gaan-jullie-doen). De ervaring leert ons dat het enige tijd vergt om de leerstof van Web Services te verwerken en dat je tijdig moet beginnen aan de opdracht (maar dat is altijd, toch?).

Teken een ERD van je databank m.b.v. <https://kroki.io>. Je vindt de syntax op <https://github.com/BurntSushi/erd>. Hou hierbij rekening met relaties en hoe je deze wegwerkt in een relationele databank (indien van toepassing).

Vraag hulp/feedback aan je lector als je een eerste versie van het ERD hebt. Je kan dit doen tijdens de les of na de les via een issue op jouw GitHub repository (gebruik het feedbacktemplate).

### JS drills

Vervolgens loont het de moeite om een aantal JavaScript-drilloefeningen te maken. Tijdens dit olod leer je heel wat nieuws in Node.js, we kunnen niet blijven stilstaan bij basis JavaScriptsyntax en -functionaliteiten.

Clone de repository <https://github.com/HOGENT-Web/webservices-ch1-exercise> en lees de instructies in de README. De oplossingen zijn te vinden op de branch [`solution`](https://github.com/HOGENT-Web/webservices-ch1-exercise/tree/solution).

## Must read/watch

- [Statements vs. expressions](https://www.joshwcomeau.com/javascript/statements-vs-expressions/)
- [100+ JavaScript Concepts you Need to Know (Fireship)](https://www.youtube.com/watch?v=lkIFF4maKMU)
- [JavaScript for the Haters (Fireship)](https://www.youtube.com/watch?v=aXOChLn5ZdQ)
- [JS Is Weird](https://jsisweird.com/)
