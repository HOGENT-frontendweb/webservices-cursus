# Webhooks

Webhooks zijn een manier om real-time notificaties te sturen tussen applicaties. In plaats van dat een client regelmatig de server bevraagt (**polling**), stuurt de server zelf een HTTP-verzoek naar de client zodra er iets interessants gebeurt. Dit noemen we ook wel **push** in tegenstelling tot **pull**.

## Concept

Bij een klassieke REST API roept de client de server op:

```text
Client  →  GET /transactions  →  Server
Client  ←  200 OK             ←  Server
```

Bij webhooks is het omgekeerd: een externe service roept jóuw server op wanneer er een event plaatsvindt:

```text
Externe service  →  POST /webhooks/events  →  Jouw server
Externe service  ←  200 OK                 ←  Jouw server
```

Voorbeelden van diensten die webhooks aanbieden:

- [Stripe](https://docs.stripe.com/webhooks) — notificatie wanneer een betaling geslaagd is
- [GitHub](https://docs.github.com/en/webhooks) — notificatie wanneer er een push naar een repository is
- [Mollie](https://docs.mollie.com/docs/webhooks) — notificatie wanneer een betaling van status verandert

## Eigen webhook endpoint maken

Bij het maken van een webhook endpoint moet je rekening houden met een aantal best practices:

- Een webhook endpoint is een simpel `POST` endpoint in een NestJS controller.
- Je bepaalt de payload zelf — meestal is dit een JSON-object met een `type` veld en een `data` veld, maar dit verschilt per dienst.
  - Via `type` kan je later in je code bepalen welk event er binnenkomt.
  - Via `data` wordt relevante informatie over het event doorgegeven, zoals details van een betaling of een GitHub push.
- Qua url-structuur is het gebruikelijk om een prefix zoals `/webhooks` te gebruiken, gevolgd door een subroute die de bron of het type van het event aangeeft (bijv. `/webhooks/stripe` of `/webhooks/events`).
  - Zorg vooral dat duidelijk is dat dit endpoint alleen bedoeld is voor webhooks - geen andere functionaliteit - en dat het duidelijk is welke bron of welk type events er binnenkomen.
- Zorg voor een goede documentatie van je webhook endpoint, zodat externe partijen weten hoe ze er gebruik van kunnen maken (welke URL, welke payload, welke headers, ...).
- Zorg voor een degelijke beveiliging, bijvoorbeeld door een geheim token (= API key) te gebruiken dat in de headers van het request wordt meegegeven. Je kan hiervoor inspiratie opdoen op onderstaande links. Het spreekt voor zich dat je de API key geheim houdt.
  - <https://swagger.io/docs/specification/v3_0/authentication/api-keys/>
  - <https://blog.stoplight.io/api-keys-best-practices-to-authenticate-apis>

## Webhook events versturen

Je kan ook zelf webhooks versturen naar externe services wanneer er iets in jouw applicatie gebeurt. Hiervoor moet je een aantal best practices in acht nemen:

- Afhankelijk van de interface van de webhook, moet je andere packages installeren. Voor HTTP-webhooks wordt heel vaak gegrepen naar packages als [axios](https://www.npmjs.com/package/axios), maar die packages zijn typisch groot en uitgebreid. Je hebt al die functionaliteiten niet nodig, je gebruikt beter [node-fetch](https://www.npmjs.com/package/node-fetch). Dit package is klein en heeft een eenvoudige API voor het versturen van HTTP-verzoeken.
- Zorg dat API keys of andere gevoelige informatie niet in de code staan, maar in environment variables. Gebruik hiervoor de `ConfigModule` van NestJS, zodat je gemakkelijk toegang hebt tot deze variabelen in je services.
