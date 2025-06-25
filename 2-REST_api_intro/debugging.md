<!-- markdownlint-disable first-line-h1 -->

## Debugging

Een applicatie ontwikkelen zonder eens te moeten debuggen is een utopie, ook in Node.js.

Net zoals in vanilla JavaScript kan je hier gebruik maken van o.a. `console.log`, maar op die manier debuggen is tijdrovend en lastig. Het zou handig zijn als we in VS Code konden debuggen... Uiteraard kan dit ook!

Maak een bestand `launch.json` aan in de `.vscode` map en voeg volgende configuratie toe:

?> Als je zowel Front-end Web Development als Web Services volgt én je opent steeds de root van jouw GitHub repository, dan moet je de `.vscode` map in de root van je GitHub repository te zetten. Anders zal VS Code de debug configuratie niet inladen.

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Attach to NestJS server",
      "address": "localhost",
      "port": 9229,
      "request": "attach",
      "skipFiles": ["<node_internals>/**"],
      "type": "node",
      "restart": true,
      "timeout": 10000
    }
  ]
}
```

Dit zorgt ervoor dat VS Code de debugger zal koppelen aan localhost:9229. Indien de debugger om een of andere reden ontkoppeld wordt, zal VS Code proberen opnieuw te koppelen voor maximaal 10 seconden.

Voor NestJS hoef je geen extra opties toe te voegen aan het start-commando. NestJS heeft standaard debugging ondersteuning ingebouwd.

Start je applicatie in debug modus met `pnpm start:debug`. Vervolgens kan je in VS Code debugger starten door op het play-icoontje (naast 'Attach to NestJS server') te klikken in de debug tab:

![Start VS Code debuggen](images/debugging-in-vscode.png ':size=50%')

Vervolgens zal je in de terminal zien dat de debugger verbonden is en kan je breakpoints toevoegen in je code.

![Debugger attached](images/debugger-attached.png ':size=75%')

Voeg breakpoints toe door op de lijnnummers te klikken. De debugger zal nu stoppen op deze lijn wanneer deze uitgevoerd wordt (doordat je bv. een request uitvoert in Postman). Je kan een breakpoint zetten in je `HealthController` op de lijn `return 'pong';` en zien dat de debugger stopt op deze lijn als je naar <http://localhost:3000/api/health/ping> surft. Bovenaan krijg je een paar knoppen die je zou moeten herkennen van bv. Eclipse of IntelliJ IDEA.

![Breakpoint](images/breakpoint.png ':size=75%')

In de documentatie van VS Code kan je meer lezen over de [debug actions in de toolbar bovenaan](https://code.visualstudio.com/docs/debugtest/debugging#_debug-actions).
