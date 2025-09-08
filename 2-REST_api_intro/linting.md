<!-- markdownlint-disable first-line-h1 -->

<!-- TODO: dit moet ergens anders komen -->

## Linting

Linting is statische analyse van code om problemen zoals verkeerde syntax en twijfelachtig gebruik van code te detecteren. Waarom zou je gebruiken maken van linting en formatting? Het kan vroegtijdig fouten, typo's en syntax errors vinden. Het verplicht developers dezelfde codeerstijl te gebruiken, best practices te volgen en vermijdt het committen van slechte code.

[ESLint](https://github.com/eslint/eslint), gecreëerd door Nicholas C. Zakas in 2013, is een linting tool voor JavaScript. Je kan een eigen configuratie ontwerpen of gebruik maken van een reeds gedefinieerde zoals die van [Airbnb](https://github.com/airbnb/javascript). Er zijn tal van plugins beschikbaar om ESLint uit te breiden met extra linting rules.

### Linting: tools installeren

Voeg, indien nog niet gedaan, de [ESLint extensie](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint) toe aan VS Code.

Installeer ESLint in het project:

```bash
pnpm add --dev eslint @eslint/js typescript-eslint @stylistic/eslint-plugin
```

- [`eslint`](https://www.npmjs.com/package/eslint): de ESLint linter
- [`@eslint/js`](https://www.npmjs.com/package/@eslint/js): JavaScript specifieke functionaliteiten voor ESLint
- [`typescript-eslint`](https://www.npmjs.com/package/typescript-eslint): TypeScript specifieke functionaliteiten voor ESLint
- [`@stylistic/eslint-plugin`](https://www.npmjs.com/package/@stylistic/eslint-plugin): een plugin voor ESLint om codeerstijl te controleren

Pas de `package.json` aan, voeg onderstaand script toe:

```json
"scripts": {
  "lint": "eslint ."
}
```

Maak een `eslint.config.mjs` bestand in de root met onderstaande configuratie. De extensie `mjs` staat voor [ES modules](https://nodejs.org/api/esm.html) en laat ons toe om ES modules te gebruiken in Node.js. Je kan de configuratie ook in TypeScript schrijven, maar dat vereist extra stappen die een beetje overkill zijn.

```js
import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';
import stylistic from '@stylistic/eslint-plugin';

// 👇 1
export default tseslint.config(
  eslint.configs.recommended, // 👈 2
  ...tseslint.configs.recommended, // 👈 2
  {
    // 👇 3
    files: ['**/*.ts', '**/*.spec.ts'],
    plugins: {
      '@stylistic': stylistic,
    },
    rules: {
      '@stylistic/no-multiple-empty-lines': [
        'error',
        {
          max: 1,
          maxEOF: 1,
          maxBOF: 0,
        },
      ],
      '@stylistic/indent': ['error', 2, { SwitchCase: 1 }],
      '@stylistic/quotes': ['error', 'single'],
      '@stylistic/semi': ['error', 'always'],
      '@stylistic/comma-dangle': ['error', 'always-multiline'],
      '@stylistic/no-tabs': ['error'],
      '@stylistic/max-len': [
        'error',
        {
          code: 120,
          tabWidth: 2,
        },
      ],
      '@stylistic/arrow-parens': ['error', 'always'],
      '@stylistic/brace-style': ['error', '1tbs', { allowSingleLine: false }],
      '@stylistic/no-inner-declarations': 'off',
      '@typescript-eslint/no-explicit-any': 'off',
      '@typescript-eslint/consistent-type-imports': 'error',
      '@typescript-eslint/no-empty-object-type': 'off',
    },
  },
);
```

1. Dit is een helperfunctie zodat we IntelliSense krijgen in onze configuratie.
2. We vertrekken van de aanbevolen configuratie ESLint en TypeScript ESLint. Deze laatste bevat ook alle nodige configuratie om TypeScript-bestanden te kunnen lezen, dit kan nl. niet zomaar.
3. Vervolgens definiëren we onze eigen configuratie:
   - We linten enkel bestanden met de extensie `.ts` en `.spec.ts` (in eender welke map).
   - We voegen de `@stylistic` plugin toe. Deze helpt ons met het controleren van de codeerstijl.
   - Daarna definiëren we onze eigen regels. Voor regels gebruik je altijd dezelfde prefix als het property in de plugins, in dit geval `@stylistic`. Pas deze gerust naar eigen wens aan of baseer je op een bestaande configuratie.

Je kan VS Code zo instellen dat automatisch herstel van fouten wordt uitgevoerd telkens je CTRL+S (of COMMAND+S) drukt. Open de JSON settings via F1 > Zoek naar "Preferences: Open Settings (JSON)" en voeg onderstaand toe (zonder de { }):

```json
{
  "editor.codeActionsOnSave": {
    "source.fixAll": "always"
  },
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ]
}
```

Run voor elke commit `pnpm lint`. Dit zal je code linten, sommige problemen zelf oplossen en fouten geven omtrent manueel op te lossen problemen.

Indien je een foutmelding krijgt dat `typescript-eslint` jouw versie van TypeScript niet ondersteund. Pas dan de versie van TypeScript in `package.json` aan naar een ondersteunde versie. Soms helpt het ook om de `^` te vervangen door een `~` voor de versie van `typescript` in de `package.json`.

> **Oplossing voorbeeldapplicatie**
>
> ```bash
> git clone https://github.com/HOGENT-frontendweb/webservices-budget.git
> cd webservices-budget
> git checkout -b les2-opl 3acce6c
> pnpm install
> pnpm start:dev
> ```
