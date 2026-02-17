<!-- markdownlint-disable first-line-h1 -->

## Complexe types

Uiteraard zijn er meer dan alleen de basis types die we in de vorige sectie hebben gezien.
In deze sectie gaan we kijken naar de complexere types die TypeScript kent.
Opgelet, deze voorbeelden werken enkel wanneer we het keyword `type` gebruiken, bij `interface` zal dit niet werken.

> Onderstaande operators kunnen vaak werken met interfaces als argument, maar ze retourneren nadien een type.

### Intersection types

Om types te combineren moet je gebruik maken van de `&` operator, dit heet **intersection types**. De types worden hierbij samengevoegd tot één type. Het is hierbij verplicht dat variabelen van dit type aan alle types voldoen, m.a.w. het moet alle properties uit de types bevatten.

```typescript
type Book = {
  title: string;
  author: string;
};

type BookExtension = Book & { isbn: string };
const book: BookExtension = {
  title: 'Introducing MLOps',
  author: 'Mark Treveil & the Dataiku Team',
  isbn: '9781492083290',
};
```

### Union types

Je kan ook types combineren met de `|` operator, dit heet **union types**. De types worden hierbij niet samengevoegd, het is ofwel het ene ofwel het andere type, ofwel een combinatie van beide. Het is dus niet verplicht om aan alle types te voldoen.

```typescript
type Member = {
  name: string;
  age: number;
};

type Email = {
  email: string;
};

type MemberExtension = Member | Email;

const member: MemberExtension = {
  name: 'Thomas Aelbrecht',
  age: 25,
};
const member2: MemberExtension = {
  name: 'Thomas Aelbrecht',
  age: 25,
  email: 'thomas.aelbrecht@hogent.be',
};
const member3: MemberExtension = {
  email: 'thomas.aelbrecht@hogent.be',
};
```

Zet je de union operator helemaal vooraan het type, dan moet het één van de types zijn, maar niet alle types. Dit heet **discriminated unions**.

```typescript
type NetworkLoadingState = {
  state: 'loading';
};
type NetworkFailedState = {
  state: 'failed';
  code: number;
};
type NetworkSuccessState = {
  state: 'success';
  response: {
    title: string;
    duration: number;
    summary: string;
  };
};
// Een van de drie, niet allemaal
type NetworkState =
  | NetworkLoadingState
  | NetworkFailedState
  | NetworkSuccessState;
```

In dit voorbeeld is het property `state` gedeeld. TypeScript kan dit property gebruiken om type inference te doen om te bepalen welk type gebruikt wordt. Zo krijg je in bv. `if` statements de juiste code completion en type checking.

## Utility types

TypeScript heeft ook heel wat [utility types](https://www.typescriptlang.org/docs/handbook/utility-types.html). Dit zijn types die je kan gebruiken om andere types te maken. De meest gebruikte utility types zijn:

- `Partial<Type>`: maakt een type optioneel
- `Omit<Type, Keys>`: verwijdert een of meerdere properties van een type
- `Record<Keys, Types>`: maakt een type voor een object met properties met naam volgens `Keys` en type volgens `Types`
- `Pick<Type, Keys>`: haalt een of meerdere properties (`Keys`) op uit een type (`Type`)
- ...

```typescript
type MyExample = {
  a: number;
  b: string;
};

type WithoutB = Omit<MyExample, 'b'>;
type OptionalMyExample = Partial<MyExample>;

type PersonKeys = 'firstName' | 'lastName' | 'email';
type Person = Record<PersonKeys, string>;
// is gelijk aan:
// type Person = {
//     firstName: string;
//     lastName: string;
//     email: string;
// };

type OnlyEmail = Pick<Person, 'email'>;
type FullName = Pick<Person, 'firstName' | 'lastName'>;
```

TypeScript heeft nog ontzettend veel mogelijkheden om types te manipuleren, maar dit valt buiten de scope van deze cursus. Je kan alles vinden in de [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/2/types-from-types.html).
