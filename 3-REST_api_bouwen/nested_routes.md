TODO MOET VERHUIZEN NAAR EEN ANDER HOOFDSTUK WANT NOG GEEN ID's voor place in MOCKDATA

## Geneste routes

In het vorige hoofdstuk hebben een voorbeeld uitgewerkt voor een recepten API waarbij een veelgemaakte fout was dat subroutes niet correct gedefinieerd worden. Hier geven we een praktisch voorbeeld van zo'n geneste route in onze budget app.

Elke transactie heeft een plaats waar deze gebeurd is. We willen nu alle transacties van een bepaalde plaats opvragen. Welke URL gebruiken we hiervoor?

- Antwoord +

  We gebruiken `/api/places/:id/transactions`. Hierbij is `:id` de id van de plaats.

  Heel vaak wordt dit verkeerd geïmplementeerd zoals bv. `/api/transactions/place/:id`. Dit is niet correct omdat we hier geen duidelijk pad volgen. We willen alle transacties van een plaats opvragen, dus is het logischer om eerst de plaats op te geven en dan de transacties van die plaats op te vragen.

We definiëren een nieuwe functie in `src/service/transaction.ts`:

```ts
// src/service/transaction.ts
// ...
export const getTransactionsByPlaceId = async (placeId: number) => {
  return TRANSACTIONS.filter((t) => t.place.id === placeId);
};
```

Deze functie filtert alle transacties op basis van de plaats id en geeft deze terug. Vervolgens maken we een nieuwe router aan in `src/rest/place.ts`:

```ts
import Router from '@koa/router';
import * as transactionService from '../service/transaction';
import type { Context } from 'koa';

const getTransactionsByPlaceId = async (ctx: Context) => {
  const transactions = await transactionService.getTransactionsByPlaceId(
    Number(ctx.params.id),
  );
  ctx.body = {
    items: transactions,
  };
};

export default (parent: Router) => {
  const router = new Router({
    prefix: '/places',
  });

  router.get('/:id/transactions', getTransactionsByPlaceId);

  parent.use(router.routes()).use(router.allowedMethods());
};
```

Hierin definiëren we onze geneste route. Vergeet niet deze router te installeren in `src/rest/index.ts`.

### Oefening 7 - Je eigen project

Werk de routes van de entiteiten in je eigen project uit. Zorg ervoor dat je geneste routes correct definieert. Werk voorlopig met mock data.

> **Oplossing voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les3-opl 4e63e94
> yarn install
> yarn start:dev
> ```
