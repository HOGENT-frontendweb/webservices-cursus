<!-- markdownlint-disable first-line-h1 -->

## Asynchrone code

JavaScript is een single-threaded taal (je kan wel threads maken m.b.v. [worker threads](https://nodejs.org/api/worker_threads.html)). Dit wil zeggen dat er maar één thread is die de code uitvoert. Dit is een groot verschil met bv. Java, waar je meerdere threads _kan_ hebben die parallel uitgevoerd worden. Dit heeft als gevolg dat JavaScript code asynchroon moet uitgevoerd worden. Als je bv. een API call doet, dan moet je wachten op het resultaat. Als je dit synchroon zou doen, dan zou de hele applicatie blokkeren tot het resultaat van de API call terug is.

In JavaScript werd/wordt dit opgelost door een callback functie mee te geven aan de functie die de API call doet. De callback functie wordt dan uitgevoerd als het resultaat van de API call terug is.

Tegenwoordig wordt er meer en meer gebruik gemaakt van Promises. Een Promise is een object dat een resultaat kan bevatten dat nu nog niet beschikbaar is. Je kan een callback functie meegeven aan de Promise die uitgevoerd wordt als het resultaat beschikbaar is. Je kan ook een callback functie meegeven die uitgevoerd wordt als er een fout optreedt. Promises hebben drie mogelijke toestanden:

- pending: het resultaat is nog niet beschikbaar
- fulfilled: het resultaat is beschikbaar
- rejected: er is een fout opgetreden

Laten we een voorbeeld met callbacks bekijken:

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

waitForPromise(2000).then(() => {
  console.log('Hello world from Promise!');
});
```

Je kan ook een Promise maken die een fout teruggeeft:

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

Callbacks leiden vaak tot **callback hell**: je moet een callback functie meegeven aan een functie die een callback functie verwacht, die op zijn beurt een callback functie verwacht... Daarom werden in de eerste plaats Promises geïntroduceerd en later ook async/await.

Async/await zijn keywords die toelaten om asynchrone code te schrijven die er synchroon uitziet. Je kan een functie als `async` markeren. Deze functie kan dan `await` gebruiken om te wachten op het resultaat van een Promise. Je kan ook een `try`/`catch` blok gebruiken om fouten op te vangen. Een `async` functie geeft **altijd** een Promise terug, ook al doe je geen expliciete `return`. Met async/await los je dus het probleem van callback hell op.

We raden dus aan om altijd async/await te gebruiken. Je kan nog steeds callbacks gebruiken, maar dit is niet meer nodig.

Laten we een voorbeeld bekijken:

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
