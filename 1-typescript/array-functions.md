
<!-- markdownlint-disable first-line-h1 -->
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
console.log(sum);

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
console.log(groupBy);
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