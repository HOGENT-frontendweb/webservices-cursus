# Software <!-- omit in toc -->

Voor dit olod gaan we ervan uit dat je onderstaande **software installeert en configureert voor de eerste les**. Tijdens de les wordt geen tijd meer voorzien om dit te doen, dus zorg ervoor dat je dit op voorhand in orde brengt. Indien je problemen ondervindt, kan je deze melden via een issue op je eigen repository.

- [Git](#git)
- [Node.js](#nodejs)
- [Yarn](#yarn)
- [Visual Studio Code](#visual-studio-code)
- [Postman](#postman)

## Git

Installeer Git via een package manager:

- Windows: `choco install git`
- macOS: `brew install git`
- Linux: [distro afhankelijk](https://git-scm.com/download/linux)

### Configuratie Git <!-- omit in toc -->

Open een terminal (of bv. Git Bash op Windows) en voer onderstaande commando's uit. Je bent natuurlijk vrij om deze instellingen aan te passen naar jouw voorkeur.

```terminal
git config --global core.autocrlf true # <- enkel op Windows
git config --global core.autocrlf input # <- enkel op macOS en Linux
git config --global core.ignorecase false

git config --global init.defaultBranch main

git config --global pager.branch false
git config --global pager.log false

git config --global pull.ff only
git config --global pull.rebase true

git config --global push.default simple

git config --global user.name "Voornaam Achternaam"
git config --global user.email "Jouw e-mailadres"
```

Volg vervolgens de [GitHub Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) om een SSH-key toe te voegen aan je GitHub-account. Dit is o.a. nodig om te kunnen pushen naar je repository.

## Node.js

Installeer Node.js (**minimaal versie 20.6.0**) via een package manager:

- Windows: `choco install nodejs`
- macOS: `brew install node`
- Linux: [distro afhankelijk](https://nodejs.org/en/download/package-manager)

Of kies voor een manuele installatie door **minimaal v20.6.0** te downloaden vanaf de website: <https://nodejs.org/en/>.

Check na de installatie of Node.js correct geïnstalleerd is door volgend commando uit te voeren:

```terminal
$ node --version
v20.6.0
```

## Yarn

Installeer `yarn` als alternatieve package manager voor `npm`:

```terminal
npm install -g yarn
```

Schakel vervolgens [Corepack](https://nodejs.org/api/corepack.html) in:

```terminal
corepack enable
```

Corepack is een package manager die de installatie van `yarn` en andere packages versnelt. Het kan automatisch de versie van `yarn` installeren die in het `package.json`-bestand staat. Wij werken met Yarn v4, Corepack is dus een vereiste.

Test of `yarn` correct geïnstalleerd is en kan gebruikt worden:

```terminal
yarn --version
```

Dit zou een versienummer moeten opleveren.

Windows-gebruikers kunnen een fout krijgen bij het uitvoeren van dit commando. De fout is in de vorm van `yarn.ps1 cannot be loaded because running scripts is disabled on this system`. Indien dit het geval is, open een PowerShell terminal in Administrator modus. Voer vervolgens het volgende commando uit en antwoord met `A` op de vraag:

```terminal
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

## Visual Studio Code

Installeer Visual Studio Code via een package manager:

- Windows: `choco install vscode`
- macOS: `brew install --cask visual-studio-code`
- Linux: [distro afhankelijk](https://code.visualstudio.com/docs/setup/linux)

Of kies voor een manuele installatie door de laatste versie te downloaden vanaf de website: <https://code.visualstudio.com/download>.

### Visual Studio Code: plugins <!-- omit in toc -->

Een aantal **verplichte** plugins voor VS Code:

- [Error Lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)
- [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [Path Intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense)
- [Prisma](https://marketplace.visualstudio.com/items?itemName=Prisma.prisma)

Een aantal optionele, maar toch handige plugins:

- [EditorConfig for VS Code](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
- [Git Blame](https://marketplace.visualstudio.com/items?itemName=waderyan.gitblame)
- [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [Todo Tree](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree)
- [TODO Highlight](https://marketplace.visualstudio.com/items?itemName=wayou.vscode-todo-highlight)
- [vscode-twoslash-queries](https://marketplace.visualstudio.com/items?itemName=Orta.vscode-twoslash-queries)

### Configuratie VS Code <!-- omit in toc -->

Voeg onderstaande configuratie toe aan de instellingen van Visual Studio Code. De eenvoudigste manier is om dit via de JSON-interface te doen:

1. Open de zoekfunctie via de toets `F1`
2. Zoek op "settings" en kies voor `Preferences: Open User Settings (JSON)`
3. Kopieer onderstaande JSON-code en voeg toe aan het JSON-bestand dat geopend werd. Zorg ervoor dat je een geldig JSON-object maakt!

> Merk op: de laatste setting schakelt de "Trusted workspaces" uit. Indien je dit niet wenst, verwijder deze setting.

```json
{
  "files.eol": "\n",
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "[javascript]": {
    "editor.defaultFormatter": "dbaeumer.vscode-eslint"
  },
  "editor.linkedEditing": true,
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

### Fira Code lettertype <!-- omit in toc -->

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

## Postman

Installeer Postman via een package manager:

- Windows: `choco install postman`
- macOS: `brew install --cask postman`
- Linux: [distro afhankelijk](https://www.postman.com/downloads/)

Open Postman en maak een account aan. Je kan er natuurlijk ook voor kiezen om eenvoudigweg met Google aan te melden.
