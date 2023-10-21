# FAQ

In dit hoofdstuk behandelen we nog enkele leuke extra's die nuttig kunnen zijn tijdens het ontwikkelen, alsook antwoorden
op de meest gestelde vragen.

## Debugging

Een applicatie ontwikkelen zonder eens te moeten debuggen is een utopie, ook in Node.js.

Net zoals in vanilla JavaScript kan je hier gebruik maken van o.a. `console.log`, maar op die manier debuggen is tijdrovend en lastig. Het zou handig zijn als we in VS Code konden debuggen... Uiteraard kan dit ook!

Maak een bestand `launch.json` aan in de `.vscode` map en voeg volgende configuratie toe:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "attach",
      "name": "Attach to server",
      "port": 9001,
      "address": "localhost",
      "restart": true,
      "timeout": 10000
    }
  ]
}
```

Dit zorgt ervoor dat VS Code de debugger zal koppelen aan <localhost:9001>. Indien de debugger om een of andere reden ontkoppeld wordt, zal VS Code proberen opnieuw te koppelen voor maximaal 10 seconden.

Alvorens je aan het debuggen gaat, check of jouw start-commando de optie `--inspect=0.0.0.0:9001` bevat. Indien je onze uitgebreide nodemon configuratie gebruikt, is dit al het geval.
