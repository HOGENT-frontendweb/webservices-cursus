# Software

Voor dit olod gaan we ervan uit dat je volgende **software installeert en configureert voor de eerste les**:

- [Software](#software)
  - [NodeJS](#nodejs)
  - [Yarn](#yarn)
  - [Visual Studio Code](#visual-studio-code)
    - [Visual Studio Code: plugins](#visual-studio-code-plugins)
    - [Configuratie VS Code](#configuratie-vs-code)
    - [Fira Code lettertype](#fira-code-lettertype)

## NodeJS

Installeer NodeJS (**minimaal versie 20.6.0**) via een package manager:

- Windows: `choco install nodejs`
- macOS: `brew install node`
- Linux: [distro afhankelijk](https://nodejs.org/en/download/package-manager)

Of kies voor een manuele installatie door **minimaal v20.6.0** te downloaden vanaf de website: <https://nodejs.org/en/>.

Check na de installatie of NodeJS correct geïnstalleerd is door volgend commando uit te voeren:

```bash
$ node --version
v20.6.0
```

## Yarn

Installeer `yarn` als alternatieve package manager voor `npm`:

```bash
npm install -g yarn
```

Test of `yarn` correct geïnstalleerd is en kan gebruikt worden:

```bash
yarn --version
```

Dit zou een versienummer moeten opleveren.

Windows-gebruikers kunnen een fout krijgen bij het uitvoeren van dit commando. De fout is in de vorm van `yarn.ps1 cannot be loaded because running scripts is disabled on this system`. Indien dit het geval is, open een PowerShell terminal in Administrator modus. Voer vervolgens het volgende commando uit en antwoord met `A` op de vraag:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

## Visual Studio Code

Installeer Visual Studio Code via een package manager:

- Windows: `choco install vscode`
- macOS: `brew install --cask visual-studio-code`
- Linux: [distro afhankelijk](https://code.visualstudio.com/docs/setup/linux)

Of kies voor een manuele installatie door de laatste versie te downloaden vanaf de website: <https://code.visualstudio.com/download>.

### Visual Studio Code: plugins

Een aantal **verplichte** plugins voor VS Code:

- [Error Lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)
- [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [Path Intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense)

Een aantal optionele, maar toch handige plugins:

- [EditorConfig for VS Code](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
- [Git Blame](https://marketplace.visualstudio.com/items?itemName=waderyan.gitblame)
- [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [Todo Tree](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree)
- [TODO Highlight](https://marketplace.visualstudio.com/items?itemName=wayou.vscode-todo-highlight)
- [vscode-twoslash-queries](https://marketplace.visualstudio.com/items?itemName=Orta.vscode-twoslash-queries)

### Configuratie VS Code

Voeg onderstaande configuratie toe aan de instellingen van Visual Studio Code. De eenvoudigste manier is om dit via de JSON-interface te doen:

1. Open de zoekfunctie via de toets `F1`
2. Zoek op "settings" en kies voor `Preferences: Open User Settings (JSON)`
3. Kopieer onderstaande JSON-code en voeg toe aan het JSON-bestand dat geopend werd. Zorg ervoor dat je een geldig JSON-object maakt!

> Merk op: de laatste setting schakelt de "Trusted workspaces" uit. Indien je dit niet wenst, verwijder deze setting.

```json
{
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "[javascript]": {
    "editor.defaultFormatter": "dbaeumer.vscode-eslint"
  },
  "errorLens.delay": 500,
  "errorLens.enabledDiagnosticLevels": [
      "error",
      "warning",
      "info"
  ],
  "errorLens.messageTemplate": "$severity $message $count ($source - $code)",
  "errorLens.severityText": [
      "❗️ ",
      "⚠️ ",
      "ℹ️ ",
      "💡 "
  ],
  "editor.bracketPairColorization.enabled": true,
  "security.workspace.trust.enabled": false
}
```

Een thema kan je uiteraard zelf kiezen, maar [One Dark Pro](https://marketplace.visualstudio.com/items?itemName=zhuangtongfa.Material-theme) is wel een overzichtelijk thema.

### Fira Code lettertype

Fira Code is een gratis monospace lettertype met speciale karakters voor developers. Uiteraard is de keuze aan jou om dit te installeren.

Installeer het lettertype via een package manager:

- Windows: `choco install firacode`
- macOS: `brew install firacode`
- Linux: [distro afhankelijk](https://github.com/tonsky/FiraCode/wiki/Linux-instructions#installing-with-a-package-manager)

Of volg de instructies op de [GitHub van Fira Code](https://github.com/tonsky/FiraCode/wiki/Installing).

Voeg nadien volgende JSON-configuratie toe aan de settings van VS Code (zie hierboven hoe je daar komt):

```json
{
  "editor.fontFamily": "'Fira Code', Menlo, Monaco, 'Courier New', monospace",
  "editor.fontSize": 16,
  "editor.fontLigatures": true,
  "editor.tabSize": 2
}
```
