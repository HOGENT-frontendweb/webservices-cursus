# CI/CD

Dit hoofdstuk wordt gedeeld tussen de olods Front-end Web Development en Web Services. Onderstaande tabel geeft aan welke secties van toepassing zijn voor welk olod. In de secties waar één olod niet van toepassing is, wordt dit in de tekst ook nog eens expliciet vermeld.

**In dit hoofdstuk werk je uitsluitend met je eigen applicatie.** Het is de bedoeling dat je jouw eigen applicatie online zet. Je kan de voorbeeldapplicatie wel gebruiken als referentie, maar je moet de stappen zelf uitvoeren op jouw eigen applicatie.

| Sectie                                                             | Front-end Web Development | Web Services             |
| ------------------------------------------------------------------ | ------------------------- | ------------------------ |
| [Continuous Integration/Delivery](#continuous-integrationdelivery) | :heavy_check_mark:        | :heavy_check_mark:       |
| [Nodige services](#nodige-services)                                | :heavy_check_mark:        | :heavy_check_mark:       |
| [Aanpassingen](#aanpassingen)                                      | :heavy_check_mark:        | :heavy_check_mark:       |
| [Render account aanmaken](#render-account-aanmaken)                | :heavy_check_mark:        | :heavy_check_mark:       |
| [Back-end online zetten](#back-end-online-zetten)                  | :heavy_multiplication_x:  | :heavy_check_mark:       |
| [Front-end online zetten](#front-end-online-zetten)                | :heavy_check_mark:        | :heavy_multiplication_x: |
| [Hosting remarks](#hosting-remarks)                                | :heavy_check_mark:        | :heavy_check_mark:       |

## Continuous Integration/Delivery

Vroeger werd software geleverd op cd-roms, of zelfs diskettes. De software werd dan op een cd-rom gebrand en naar de klant gestuurd. De klant installeerde de software op zijn computer en kon er vervolgens mee aan de slag. Als er een fout in de software zat, dan moest de software opnieuw gebrand worden en opnieuw naar de klant gestuurd worden. Dit was een tijdrovend proces. Daarom kwamen versies maar eens om de zoveel jaar uit. Een nieuwe versie bevatte dan een 'batch' aan nieuwe functionaliteiten.

Het werk van programmeurs samenbrengen in één werkende applicatie was dan altijd een gedoe. Op welbepaalde tijdstippen werden 'builds' gemaakt met een aantal nieuwe functionaliteiten. Deze builds werden vervolgens getest door een Quality Assurance (QA) team. Als er geen fouten in zaten, werden ze bewaard. Als er toch fouten in zaten, dan moesten de programmeurs opnieuw aan de slag om de fouten te herstellen. Dit was een tijdrovend proces.

Wanneer de deadline van een nieuwe beta versie dichterbij kwam, werd de ontwikkeling van nieuwe features bevroren. Vanaf dan werden enkel nog bugfixes toegevoegd.

Dit proces is niet meer van deze tijd. De klant verwacht dat er regelmatig nieuwe functionaliteiten worden toegevoegd. De klant verwacht ook dat fouten snel worden opgelost. Daarom is het belangrijk dat er regelmatig nieuwe versies van de software worden uitgebracht. Dit proces wordt **Continuous Integration/Continuous Delivery (CI/CD)** genoemd.

Het internet heeft ervoor gezorgd dat updates heel snel kunnen uitrollen. Voor webapplicaties gaat het zelfs zo ver dat men daar niet spreekt over versies. Niemand zal ooit zeggen: "Ik draai nog versie 7 van Facebook, nog geen tijd gehad om naar versie 8 te upgraden.".

Het verschil tussen Continuous Integration (CI) en Continuous Delivery (CD) is dat CI het proces is waarbij de code van verschillende programmeurs samen wordt gebracht in één werkende applicatie. CD is het proces waarbij de applicatie automatisch wordt uitgerold naar de klant. In deze cursus doen we beide, elke nieuwe push naar de main branch zorgt ervoor dat de applicatie automatisch wordt uitgerold.

Al snel bleek dat de manier om software snel in een stabiele staat te krijgen, was om ervoor te zorgen dat de software **altijd** stabiel was. Het streven wordt om in git (of een ander versiebeheersysteem) altijd een stabiele branch te hebben. Deze branch kan bij wijze van spreken op elk moment uitgerold worden naar de klant. Dit is de **master of main branch**.

### Feature branches

Als iedereen door elkaar commits doet op deze branch, lukt dat nooit natuurlijk. Er is dus een andere git-strategie nodig.

![Feature branch](./images/10_1_git_branches_merge.png ':size=50%')

Een mogelijke methode is werken met **feature branches**. Het idee hierachter is dat de main branch altijd stabiel is. Als je aan een feature (of bugfix) start, creëer je een nieuwe branch. Je doet daar al je commits tot het werk af is, voegt testen toe, en merget uiteindelijk alles terug naar de main. Tussendoor kan je zelfs je feature branch rebasen met de main branch of de main branch mergen in jouw feature branch, om zo de nieuwste wijzigingen te hebben voor je de merge doet. Herhaal dit proces voor elke feature.

Het is een best practice om feature branches niet te lang te laten leven. Hoe langer een branch bestaat, hoe lastiger het wordt om deze branch te mergen in de main branch. Mergen is altijd een risico, hoe meer code er veranderd is, hoe groter het risico op fouten. Het is dus beter om **regelmatig heel kleine branches te mergen** dan één grote branch.

### CI/CD pipeline

Nog een stap verder is het automatiseren van het proces. Dit wordt gedaan met een **CI/CD pipeline**. Dit is een geautomatiseerd proces dat de code van de feature branch automatisch test en uitrolt naar de klant. Als er een fout in de code zit, wordt de uitrol naar de klant niet gedaan en krijgt bijvoorbeeld de programmeur hiervan een melding. Als de testen slagen, wordt de code uitgerold naar de klant of bv. naar een deel van de gebruikers.

Het hele concept van CI/CD valt buiten de scope van dit olod. We proberen jullie wel de essentie mee te geven.

## Nodige services

Om de back-end en front-end online te zetten, zijn er een aantal services nodig:

- [Render](https://render.com/)
- MySQL databank in het VIC (= Virtual IT Company van HOGENT): zie mail (ook spam) voor de inloggegevens
- Docker

?> Studenten die reeds geslaagd zijn voor het olod Web Services en een databank nodig hebben om hun back-end van vorig jaar te hergebruiken, gelieve een mail te sturen naar [Thomas Aelbrecht](mailto:thomas.aelbrecht@hogent.be). Houd er rekening mee dat het 1 à 2 werkdagen kan duren vooraleer je een antwoord krijgt, mail dus niet vlak voor de deadline.

### Render

Er bestaan heel wat software- en cloudoplossingen om CI/CD toe te passen. Vaak zijn deze oplossingen betalend want een paar virtuele machines opstarten om tests te draaien van een beetje serieuze applicaties is niet gratis natuurlijk.

[Heroku](https://www.heroku.com/) had een gratis versie die eenvoudig te gebruiken was, maar die is, jammer genoeg, [verdwenen sinds 28 november 2022](https://dev.to/lukeecart/more-heroku-changes-that-will-definitely-affect-you-10o8).

Daarom maken we vanaf nu gebruik van een all-in-one oplossing, nl. [Render](https://render.com/). De Render omgeving is gratis (tot een bepaalde limiet uiteraard) en biedt meteen een oplossing voor zowel back-end als front-end. Het is ontzettend eenvoudig - een beetje klikken, invullen en klaar.

### MySQL databank in het VIC

Als we onze back-end online willen zetten, hebben we een MySQL databank nodig. Op [Render](https://render.com/) kan je gratis een PostgreSQL databank opstarten, maar wij gebruiken MySQL (naar analogie met het olod Databases I). _Feel free to switch, but you're on your own then._

Er bestaan heel wat gratis MySQL services online maar eigenlijk geen enkele degelijke waar je geen kredietkaart voor nodig hebt, ofwel zien ze er sketchy uit of zijn ze vaak down.

Daarom hosten we zelf een MySQL databank in het VIC (Virtual IT Company van HOGENT). Jullie krijgen (of kregen) een mail met de inloggegevens van jouw persoonlijke MySQL databank. **Let op: er wordt maar één databank per student voorzien!**

**Dus je moet zelf geen MySQL databank aanmaken!** Droppen van de databank is mogelijk vanuit code, dat kunnen we helaas niet verhinderen. Wil je terug een lege databank? Drop dan simpelweg alle tabellen manueel.

We zijn geen gigantisch datacenter, dus we kunnen niet garanderen dat de databank altijd online zal zijn of snel zal reageren. We doen ons best om de databank zo goed mogelijk online te houden.

Bij problemen met de databank kan je altijd terecht bij [Thomas Aelbrecht](mailto:thomas.aelbrecht@hogent.be). Houd er rekening mee dat het 1 à 2 werkdagen kan duren vooraleer je een antwoord krijgt, mail dus niet vlak voor de deadline.

### Docker

Voor het online zetten van onze back-end willen we naar een mature development manier gaan.
Daarom gaan we docker gebruiken, zodat we onafhankelijk van onze host-systemen kunnen werken.
Gezien we met Render werken, volstaat het voor ons om een `Dockerfile` aan te maken, waarin vastgelegd wordt wat nodig is om onze applicatie uit te voeren.

Het opstellen van de Dockerfiles zullen we specifiek in de volgende secties bespreken.
Ook zullen we de `docker-compose.yml` file gebruiken om onze applicatie lokaal te kunnen draaien in een identieke setup als op Render.

Docker levert ons zo een aantal voordelen:

- Consistency: Docker zorgt ervoor dat onze applicatie op dezelfde manier draait, op eender welke machine. Zo voorkomen we het "it works on my machine" probleem.
- Isolation: Dankzij onze containers waarop de dependencies voor de applicaties geïnstalleerd zijn, voorkomen we dat er conflicten van dependencies optreden.
- Scalability: Dankzij Docker kunnen we onze applicatie eenvoudig opschalen, door meerdere keren dezelfde container te starten over verschillende machines in de cloud. (Dit valt wel buiten de scope van het OLOD).
- Portability: We zullen de container eenvoudig op verschillende omgevingen kunnen draaien, zonder dat we iets hoeven te wijzigen aan de container.

Het enige wat we dus op de server zelf nodig hebben is Docker.

## Aanpassingen

Deze sectie is verdeeld in een stuk voor de [back-end](#back-end) en een stuk voor de front-end. De back-end sectie is enkel van toepassing voor het olod Web Services. De [front-end](#front-end) sectie is enkel van toepassing voor het olod Front-end Web Development.

### Front-end

Het klaarmaken van de applicatie voor productie gaan we gradueel verbeteren.
Zo zullen we beginnen met een eerste, maar naïve poging, waarbij we telkens een probleem zullen tegenkomen en oplossen met een verbetering.

#### Eerste naïve poging

Bij de eerste, maar naïve poging zullen we van onze applicatie een build maken. Hiervoor gaan we gebruik maken van het build-script.
Voer hiervoor `pnpm build` uit.
Deze build zal ervoor zorgen dat we een folder genaamd `dist` krijgen.
Deze gaan we laten draaien dankzij een Nginx-server in docker.

##### Nginx

Eerst en vooral moeten we een plan hebben om onze front-end te serven.
Hiervoor zullen we gebruik maken van Nginx.
De onderstaande configuratie is gebaseerd op de documentatie van [Nginx Serve Static Content](https://docs.nginx.com/nginx/admin-guide/web-server/serving-static-content/).
Deze zal ervoor zorgen dat onze productie build van de front-end als static files geleverd kunnen worden.

Maak hiervoor een bestand `nginx.conf` aan in de root van de frontend-code.
Een standaard, maar productie klare Nginx configuratie leveren we hieronder aan:

```nginx
# 👇 1
events{}

http {
    # 👇 2
    include /etc/nginx/mime.types;
    server {
        # 👇 3
        listen 80;
        # 👇 4
        server_name localhost;
        # 👇 5
        root /usr/share/nginx/html;
        # 👇 6
        index index.html;
        location / {
            # 👇 7
            try_files $uri $uri/ /index.html;
        }
    }
}
```

1. Deze regel is vereist voor Nginx om te kunnen opstarten. De defaults zijn echter voldoende, waardoor we niets overschrijven.
2. Deze regel zorgt ervoor dat de mime-type mappings ingeladen worden, zodat Nginx de correct `Content-Type` headers kan meegeven.
3. Deze regel zorgt ervoor dat de Nginx server luistert op poort 80.
4. Deze regel zorgt ervoor dat de server reageert op requests naar localhost. Dit is in orde omdat dit draait in Docker.
5. Deze regel geeft aan aan Nginx waar de static files te vinden zijn.
6. Deze regel geeft aan wat de naam van de index file is.
7. Deze regel probeert de inkomende request te verwerken als static files. Hiervoor zoekt hij eerste naar de specifieke file, dan naar de directory en tenslotte een fallback naar de index file. Dit laatste is cruciaal voor SPA's.

##### Docker

Om nu deze Nginx server te laten draaien, zullen we zelf een `Dockerfile` maken, waarin we beschrijven wat er allemaal moet gebeuren om onze applicatie te laten draaien. Hiervoor maken we een `Dockerfile` aan in de root van de frontend-code, met de volgende inhoud:

```Dockerfile
# 👇 1
FROM nginx:1.27.4-alpine

# 👇 2
COPY ./nginx.conf /etc/nginx/nginx.conf

# 👇 3
RUN rm -rf /usr/share/nginx/html/*

# 👇 4
COPY ./dist /usr/share/nginx/html

# 👇 5
EXPOSE 80

# 👇 6
CMD ["nginx", "-g", "daemon off;"]
```

1. Deze regel zorgt ervoor dat de Nginx-image van Docker wordt gebruikt.
2. Deze regel kopieert de Nginx configuratie uit onze code naar de juiste locatie in de Docker-container.
3. Deze regel verwijdert de bestaande (default) static files uit de Nginx-server.
4. Deze regel kopieert de build van de front-end naar de Nginx-server.
5. Deze regel geeft aan aan Docker dat poort 80 moet worden geopend (de standaardpoort voor Nginx). Dit is nodig omdat we de Nginx-server draaien in Docker, en niet op de host machine.
6. Deze regel start de Nginx-server.

##### Docker Compose

Om ervoor te zorgen dat we lokaal een geautomatiseerde opstart hebben, die bovendien zo dicht mogelijk aanleunt bij de productieomgeving, maken we gebruik van Docker Compose. Hiervoor maken we een bestand `docker-compose.yml` aan in de root van de frontend-code, met de volgende inhoud:

```yml
services:
  budget-app-frontend:
    container_name: budget-app-frontend
    image: budget-app-frontend # 👈 1
    build:
      context: .
      dockerfile: ./Dockerfile # 👈 2
    ports:
      - '80:80' # 👈 3
```

1. Deze regel geeft aan welke naam de gemaakte image zal krijgen.
2. Deze regel beschrijft hoe de Docker-image van onze front-end wordt gebouwd. Wij zeggen hiermee dat dit gebouwd moet worden uit de `Dockerfile` in de root van de frontend-code.
3. Deze regel zal poort 80 van de host machine naar poort 80 in de Docker-container binden. Dit is nodig omdat we de Nginx-server draaien in Docker, en niet op de host machine. Bovendien is poort 80 de default voor http, waardoor we zullen kunnen surfen naar `http://localhost`.

##### Eerste test

Wanneer we nu `docker compose up` uitvoeren, zullen we een Nginx-server draaien met onze front-end.
We kunnen nu naar `http://localhost` surfen om te controleren of alles goed werkt.
Hierbij valt op dat onze api-calls niet correct werken, hierbij zien we dat de baseUrl van onze api-client niet juist is.
Deze hebben we tot nu toe ingesteld in de `.env` file, maar een productie build gebruikt dit niet.
De productie build gaat kijken naar de environment-variabelen van ons systeem.

##### Oplossing bug

Om dit op te lossen moeten we de environment-variabelen van ons systeem instellen.
Dit doen we op Linux/macOS met het commando `VITE_API_URL="http://localhost:3000/api"` of op Windows met `set VITE_API_URL="http://localhost:3000/api"`.
Dit is ook hoe je bij een professionele applicatie deze environment variabelen zou instellen op het systeem waarop de applicatie wordt uitgevoerd.

Vervolgens moeten we wel de bestaande container en image opkuisen, de stappen `pnpm build` en `docker compose up` opnieuw uitvoeren.
Nu kunnen we naar `http://localhost` surfen en zien dat onze front-end correct werkt.

Wanneer we nu onze container nog kort even analyseren, dan valt op dat de docker image een grootte heeft van ongeveer 50 MB.
Dit is belangrijk om zo meteen te onthouden bij poging 2.

##### Problemen naïve poging

De problemen hiermee zijn vooral dat er veel manuele stappen zijn om de applicatie in docker op te starten.
Ons doel is om deze stappen te automatiseren.

#### Tweede poging: automatisering

##### Aanpassingen

In plaats van nu zelf de code te builden, zullen we docker dit laten doen voor ons in de `Dockerfile`.
Belangrijk hierbij is te onthouden dat we nog steeds de environment variables moeten instellen, maar dat dit niet meer op onze hostmachine gebeurt.
Hiervoor zullen we deze als volgt aanpassen:

```Dockerfile
FROM nginx:1.27.4-alpine

# 👇 1
COPY ./nginx.conf /etc/nginx/nginx.conf
RUN rm -rf /usr/share/nginx/html/*

# 👇 2
WORKDIR /usr/src/app
COPY . .

# 👇 3
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# 👇 4
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# 👇 5
RUN apk add --update nodejs npm
RUN npm install -g pnpm@10.15.0
RUN pnpm add -D vite

# 👇 6
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile
RUN pnpm run build

# 👇 7
RUN mv ./dist/* /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

1. Net zoals voorheen willen we nog steeds dezelfde Nginx configuratie gebruiken en de default static files van Nginx verwijderen.
2. Ditmaal verplaatsen we ons eerst naar een working directory, zodat we onze build kunnen zetten op een plaats die niet gebruikt wordt door de container.
3. We willen de environment variables kunnen doorgeven aan de container. Deze moeten we vervolgens ook instellen in de environment van de container.
4. Omdat we pnpm willen gebruiken, gaan we al instellen in de container waar pnpm komt te staan.
5. Voordat we onze productie build kunnen uitvoeren, moeten we eerst de afhankelijkheden installeren. Hiervoor hebben we nodejs, pnpm en vite nodig. Om pnpm te installeren hebben we echter ook npm nodig.
6. Nu kunnen we eindelijk onze productie build uitvoeren. Hierbij hebben we eerst ook een install waarbij wat instellingen gebeuren om alles performant te laten werken (gebruikmakend van caching), en waarbij we instellen dat pnpm de versies uit onze lockfile moet gebruiken.
7. Tot slot kunnen we de dist folder naar de verwachte locatie van de Nginx-server kopiëren. Let er hierbij op dat we het `mv` commando moeten gebruiken, dus dat de syntax een beetje verschilt tegenover voorheen.

We moeten echter ook nog het Docker Compose bestand aanpassen, zodat voor ons gemak van lokaal testen deze environment variables doorgegeven worden:

```yml
services:
  budget-app-frontend:
    image: budget-app-frontend
    build:
      context: .
      dockerfile: ./Dockerfile
      args:
        - 'VITE_API_URL=http://localhost:3000/api'
    container_name: budget-app-frontend
    ports:
      - '80:80'
```

Tot slot zijn er nog een aantal bestanden die we sowieso niet mee willen in onze container, gezien deze alles zelf moet opbouwen vanaf onze codebase. Maak hiervoor een bestand `.dockerignore` aan in de root van de frontend-code, met de volgende inhoud:

```text
node_modules
.vscode
cypress
dist
```

Let erop: als je wijzigingen aanbrengt in de code en opnieuw wil builden, dan moet je telkens de Docker image verwijderen, want anders zorgen de caching van layers en versioning van Docker ervoor dat de vorige versie gebruikt wordt.

##### Problemen tweede poging

Als eerste valt het op hoeveel software we manueel moeten installeren in de container om onze applicatie te kunnen laten draaien.
Dit is veel omslachtiger dan gewenst is.

Daarnaast is er een tweede probleem, dat veel ernstiger is. Docker images willen we zo klein mogelijk houden, maar wanneer we nu kijken naar de grootte van de image, dan zien we dat deze drastisch vergroot is, tot bijna 1.2 GB.

#### Finale poging: Multi-stage build

Deze laatste problemen zullen we oplossen door gebruik te maken van een [multi-stage build](https://docs.docker.com/build/building/multi-stage/).

Bij een multi-stage docker build, zullen we een container gebruiken om een deel van de "heavy lifting" voor ons te doen.
Deze container zal vertrekken van een image die voor ons geschikt is om dat specifieke deel van het werk te doen.
Daarna zullen we een nieuwe container maken die verder bouwt op het resultaat van de vorige container, maar die zelf ook weer vertrekt van een image die wederom ideaal is voor de volgende stap.
Dit proces van de eerste container naar de tweede container wordt ook wel "multi-stage build" genoemd.

Het einde van een stage herken je eenvoudig door het `FROM` keyword dat opnieuw gebruikt wordt.

##### Aanpassingen

```Dockerfile
# 👇 1
FROM node:24-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# 👇 2
RUN corepack enable

WORKDIR /usr/src/app
COPY . .

# 👇 1
FROM base AS build

# 👇 3
ARG VITE_API_URL
# 👇 3
ENV VITE_API_URL=$VITE_API_URL

# 👇 3
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
# 👇 3
RUN pnpm run build


# 👇 1
FROM nginx:1.27.4-alpine

COPY ./nginx.conf /etc/nginx/nginx.conf
RUN rm -rf /usr/share/nginx/html/*

# 👇 4
COPY --from=build /usr/src/app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

1. Bij de finale oplossing zullen we drie stages gebruiken:
   1. De eerste stage vertrekt van een nodejs image, waarmee we de nodige software reeds hebben. Deze stage wordt bij ons `base` genoemd.
   2. De tweede stage bouwt verder op de eerste, en gebruiken we om de specifieke build van de applicatie te maken. Deze is strikt gezien niet noodzakelijk, maar zorgt voor een mooie scheiding van verantwoordelijkheden. Deze stage wordt bij ons `build` genoemd.
   3. De laatste stage vertrekt van een nginx image, zodat we de server eenvoudig zullen kunnen starten.
2. We zitten hier in een nodejs docker-container, het commando `corepack enable` zorgt ervoor dat we pnpm zullen kunnen gebruiken in het verdere verloop
3. In onze build stage geven we de environment variables door aan de container en maken we de effectieve productie build.
4. Tot slot moeten we enkel nog de dist folder van onze vorige stage kopiëren naar de verwachte locatie van de Nginx-server.

##### Besluit

Deze finale poging zorgt ervoor dat het hele build process van de applicatie volledig automatisch wordt uitgevoerd.
Het heeft ook het installeren van de nodige software voor ons vereenvoudigd.

Als we tot slot opnieuw kijken naar de grootte van de image, dan zien we dat deze opnieuw mooi op 50 MB uitkomt.

Nu zijn we klaar om onze front-end online te zetten. **Commit en push deze wijziging.**

### Back-end

#### Eerste poging

Bij de back-end kunnen we dezelfde stappen herhalen zoals we dit in de front-end hebben gedaan.
We gaan dit echter niet doen, gezien we nu al beter weten waar we naartoe willen.
Indien je het olod Front-end Web Development niet volgt, lees dan zeker toch de vorige sectie, waarin de uitleg staat over multi-stage builds in Docker, en waarom dit net zo belangrijk is.

##### Dockerfile

Voor het maken van onze Dockerfile voor de back-end, zullen we vertrekken van de aanzet die de [NestJS documentatie](https://docs.nestjs.com/deployment#dockerizing-your-application) ons aanbiedt:

```Dockerfile
FROM node:24

# 👇 1
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /usr/src/app

COPY . .

# 👇 2
ARG NODE_ENV
ENV NODE_ENV=$NODE_ENV

# 👇 2
ARG PORT
ENV PORT=$PORT

# 👇 2
ARG CORS_ORIGINS
ENV CORS_ORIGINS=$CORS_ORIGINS

# 👇 2
ARG CORS_MAX_AGE
ENV CORS_MAX_AGE=$CORS_MAX_AGE

# 👇 2
ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL

# 👇 2
ARG AUTH_JWT_SECRET
ENV AUTH_JWT_SECRET=$AUTH_JWT_SECRET

RUN pnpm install
RUN pnpm build

EXPOSE 3000

CMD ["node", "dist/src/main"]
```

1. Deze lijnen zijn identiek aan de `Dockerfile` van de front-end, we willen hier wederom gebruik kunnen maken van pnpm.
2. Deze lijnen zijn er om alle environment variables door te geven aan de container.

##### Docker Compose bestand

We moeten echter ook nog de Docker Compose bestand aanpassen, zodat voor ons gemak van lokaal testen deze environment variables doorgegeven worden.
Noem dit bestand ditmaal `docker-compose-backend.yml`. Deze zal de backend starten, maar niet de database. Dit willen we gescheiden houden:

```yml
services:
  budget-app-backend:
    container_name: budget-app-backend
    image: budget-app-backend
    build:
      context: .
      dockerfile: Dockerfile
      # 👇 1
      args:
        - 'NODE_ENV=production'
        - 'PORT=3000'
        - 'CORS_ORIGINS=["http://localhost:5173", "http://localhost"]' # 👈 2
        - 'CORS_MAX_AGE=10800'
        - 'DATABASE_URL=mysql://devusr:devpwd@host.docker.internal:3306/budget' # 👈 3
        - 'AUTH_JWT_SECRET=eensuperveiligsecretvoorindevelopment'
    ports:
      - '3000:3000'
```

1. Bijna alles uit dit bestand is identiek aan het Docker Compose bestand uit de front-end. Dit wordt niet opnieuw herhaald. Let erop dat alle nodige environment variables doorgegeven worden.
2. Opgelet bij de `CORS_ORIGINS` variabele, hier is een vreemde syntax nodig, omdat dit een array is, maar tegelijkertijd ook correcte json in een configuratie bestand moet zijn. Hierbij zijn twee hosts toegevoegd, zodat we zowel op de normale manier de frontend kunnen starten, als wanneer we deze in docker draaien.
3. Opgelet bij de `DATABASE_URL` variabele, hier wordt de host van de database gezet op `host.docker.internal`, wat betekent dat we de database zoeken op de host machine. Dit is nodig omdat de database niet in dezelfde docker compose staat, waardoor we geen gebruik kunnen maken van de DNS voorzien door Docker Compose. Wanneer we de database van VIC gebruiken zal dit eenvoudiger zijn.

Dit bestand kan je tot slot uitvoeren met het commando `docker compose -f docker-compose-backend.yml up`.

##### Dockerignore

Vergeet ook niet om nog een bestand `.dockerignore` aan te maken in de root van de backend, met de volgende inhoud:

```text
node_modules
.vscode
dist
```

##### Problemen

Net zoals bij de front-end, hebben we hier het probleem dat onze image veel te groot is. Voor onze voorbeeldapplicatie is deze ongeveer 1.4 GB.

#### Multi-stage build

De aanpassingen die nodig zijn zullen zich enkel in de `Dockerfile` bevinden:

```Dockerfile
# 👇 1
FROM node:24-alpine AS base

ARG NODE_ENV
ENV NODE_ENV=$NODE_ENV

ARG PORT
ENV PORT=$PORT

ARG CORS_ORIGINS
ENV CORS_ORIGINS=$CORS_ORIGINS

ARG CORS_MAX_AGE
ENV CORS_MAX_AGE=$CORS_MAX_AGE

ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL

ARG AUTH_JWT_SECRET
ENV AUTH_JWT_SECRET=$AUTH_JWT_SECRET

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
# 👇 1.1
RUN apk add --no-cache libc6-compat

# 👇 1
FROM base AS dev-deps

WORKDIR /app

# 👇 2
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

# 👇 1
FROM base AS prod-deps

WORKDIR /app

# 👇 3
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

# 👇 1
FROM base AS builder
WORKDIR /app

# 👇 4
COPY --from=dev-deps /app/node_modules ./node_modules
COPY . .

RUN pnpm build

# 👇 1
FROM base AS runner

WORKDIR /app

# 👇 5
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/migrations ./dist/migrations

EXPOSE 3000

CMD ["node", "dist/src/main"]
```

1. Ditmaal zijn we de multi-stage build aan het opstellen volgens de regels van de kunst. Alles draait over dezelfde base-layer, zodat we overal node:24-alpine kunnen gebruiken. Vervolgens hebben we een stage om de dependencies te installeren, eentje om de productie build te maken en een laatste om de productie server te draaien.
   1. Opgelet, hier wordt de base-layer nu opgebouwd vanuit een alpine image, hierdoor moeten we ook de libc6-compat library installeren. Dit is een library die packages die native C code nodig hebben zal helpen (voorbeelden hiervan zijn argon2 en swc).
2. Deze lijnen doen, net zoals bij de front-end, geoptimaliseerde installaties van de dependencies. Let hierbij op een speciaal geval, we hebben een stage dev-deps en een stage prod-deps. Dit is omdat het build-commando een aantal devDependencies nodig heeft, maar onze effectief productie code heeft enkel de echte dependencies nodig. We willen uiteraard de devDependencies dus niet mee in onze uiteindelijke image.
3. Let hier op de `--prod`, dit zorgt ervoor dat alle devDependencies verwijderd worden.
4. Op deze manier kunnen we bestanden van de ene stage kopiëren naar een andere stage. Opgelet dat we hier dus de node_modules met devDependencies gebruiken.
5. Tot slot hebben we de node_modules, de dist folder en de migrations nodig in de runner-stage. Opgelet dat we hier dus de node_modules zonder devDependencies gebruiken.

##### Besluit

Bij de finale poging zien we nu dat de image van onze back-end drastisch kleiner geworden is, deze is nu ongeveer 220 MB.
We hebben bovendien een mooie scheiding van verantwoordelijkheden.

#### Migraties

Het enige wat we nog kunnen verbeteren is het automatisch uitvoeren van migraties bij het starten van de back-end.
Om dit op te lossen moeten we wat code toevoegen aan onze DrizzleModule
(Opmerking: Dit kan ook de AppModule zijn, maar gezien het over de database migraties gaat, voelt DrizzleModule correct aan):

```ts
import { Logger, Module, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import {
  type DatabaseProvider,
  DrizzleAsyncProvider,
  drizzleProvider,
  InjectDrizzle,
} from './drizzle.provider';
import path from 'path';
import { migrate } from 'drizzle-orm/mysql2/migrator';

@Module({
  providers: [...drizzleProvider],
  exports: [DrizzleAsyncProvider],
})
// 👇 1
export class DrizzleModule implements OnModuleDestroy, OnModuleInit {
  private readonly logger = new Logger(DrizzleModule.name); // 👈 2

  constructor(@InjectDrizzle() private readonly db: DatabaseProvider) {}

  // 👇 1
  async onModuleInit() {
    this.logger.log('⏳ Running migrations...');
    // 👇 3
    await migrate(this.db, {
      migrationsFolder: path.resolve(__dirname, '../../migrations'),
    });
    this.logger.log('✅ Migrations completed!');
  }

  async onModuleDestroy() {
    await this.db.$client.end();
  }
}
```

1. We zorgen dat de DrizzleModule de `OnModuleInit` interface implementeert. Zo kunnen we een `onModuleInit` methode implementeren, waarin we de migraties laten uitvoeren bij het initialiseren van de module die de database connectie verzorgd.
2. We gebruiken onze geconfigureerde logger, zodat we bij de opstart wat logging kunnen uitvoeren. Zo kunnen we zien of de migratie succesvol is uitgevoerd.
3. We gebruiken de `migrate` functie van de `drizzle-orm` library. Hieraan moeten we meegeven waar deze de migraties zal kunnen terugvinden.

#### Seeding

Voor de seeding van de database zullen we dit manueel moeten oplossen. Hiervoor kan je tijdelijk je `.env` aanpassen, zodat de `DATABASE_URL` verwijst naar je online database.
Hierna kan je het `pnpm db:seed` commando uitvoeren om de seeding uit te voeren.

## Render account aanmaken

De volgende stap is het aanmaken van een Render account. Ga naar [Render](https://render.com/) en klik op "Sign In" rechtsboven.

![Render account aanmaken](./images/10_2_render_homepage.png ':size=80%')

Kies voor "GitHub" als authenticatiemethode en volg de stappen van de wizard. Als je niet voor GitHub kiest, heb je geen toegang tot jouw repositories in onze classroom. Na het aanmaken van je account krijg je een verificatiemail, klik op de link.

![Render aanmelden met GitHub](./images/10_3_sign_in_with_github.png ':size=80%')

Na verificatie van je account kom je terecht op je dashboard.

![Render dashboard](./images/10_4_render_dashboard.png ':size=80%')

## Back-end online zetten

?> **Let op!** Deze sectie is **niet** van toepassing voor het olod Front-end Web Development.

We zetten eerst de back-end online, klik op "New Web Service".

![Render new web service](./images/10_5_new_web_service.png ':size=80%')

Zoek jouw **eigen** back-end repository op, selecteer deze en klik op "Connect".

![Search backend repo](./images/10_6_search_backend_repo.png ':size=80%')

Vul vervolgens alle nodige settings in:

- Kies een unieke naam voor je service (hint: je repository-naam is uniek).
- Maak eventueel een project aan zodat alle resources van je applicatie gegroepeerd zijn.
- Kies als language voor `Docker`.
- Kies als branch de `main` branch. Moest je een andere branch gebruiken, kies deze dan.
- Kies "Frankfurt (EU Central)" als regio.
- Vul bij "Root Directory" de naam van de map in waar jouw back-end-code staat. Dit is de map waarin je `package.json` staat. Indien alles in de root staat, laat je dit veld leeg.
- Laat het Dockerfile path leeg, tenzij je zou afwijken van de standaardwaarde.
- Kies tenslotte voor "Free" als plan. Dit is het gratis plan van Render. Dit is voldoende voor onze applicatie. Hierdoor wordt jouw applicatie wel afgesloten indien er geen activiteit is, dus het kan even duren vooraleer de back-end online is.

De rest zou normaal correct ingevuld moeten zijn. **Controleer dit voor jouw situatie**.

![Render back-end settings part 1](./images/10_7_backend_settings.png ':size=80%')

Vul onder de instance types de nodige environment variabelen in. Check je mail voor de nodige credentials voor jouw persoonlijke databank. Als je authenticatie en autorisatie hebt, moet je deze environment variabelen ook nog toevoegen.

> Hint: voor de variabele `AUTH_JWT_SECRET` kan je een random string gebruiken. Klik op "Generate" om een random string te laten genereren door Render.

![Render back-end settings part 3](./images/10_9_backend_settings_part_3.png ':size=80%')

Optioneel kan je onder "Advanced" een "Health Check Path" invullen. Dit is een URL die je kan gebruiken om te controleren of je service nog online is, bij ons is dit `/api/health/ping`.

![Render back-end settings part 4](./images/10_10_backend_settings_part_4.png ':size=80%')

Klik vervolgens op "Deploy Web Service" en wacht geduldig af (het gratis plan kan trager zijn). Als alles goed is gegaan, zou je nu een werkende back-end moeten hebben. De URL van jouw back-end vind je linksboven.

![Back-end is online](./images/10_11_backend_online.png ':size=80%')

**Lees eerst de logs alvorens de lectoren te contacteren!** Krijg je het niet werkende? Maak een issue op jouw repository en tag jouw lector. Voeg een kopie van je logs en je settings (zonder secrets) toe, anders kunnen we niet helpen.

![Read the logs](https://imgs.xkcd.com/comics/rtfm.png ':size=30%')

## Front-end online zetten

?> **Let op!** Deze sectie is **niet** van toepassing voor het olod Web Services.

Het is tijd om onze front-end online te zetten. Onze front-end draait ook op docker, dus kan je dezelfde stappen volgen als bij de back-end.

Open het Render dashboard en klik rechtsboven op "+ New" en "Web service" (of klik op "New Web service" indien je geen back-end hebt).

![Render new web service](./images/10_12_new_static_site.png ':size=80%')

Zoek nu jouw **eigen** front-end repository op en klik op "Connect"

![Render search front-end repo](./images/10_13_search_frontend_repo.png ':size=80%')

Vul vervolgens alle nodige settings in:

- Kies een unieke naam voor je statische website (hint: je repository-naam is uniek).
- Selecteer eventueel een project.
- Kies als language voor `Docker`.
- Kies als branch de `main` branch. Moest je een andere branch gebruiken, kies deze dan.
- Kies "Frankfurt (EU Central)" als regio.
- Vul bij "Root Directory" de naam van de map in waar je front-end-code staat. Dit is de map waarin je `package.json` staat. Indien alles in de root staat, laat je dit veld leeg.
- Laat het Dockerfile path leeg, tenzij je zou afwijken van de standaardwaarde.
- Kies tenslotte voor "Free" als plan. Dit is het gratis plan van Render. Dit is voldoende voor onze applicatie. Hierdoor wordt jouw applicatie wel afgesloten indien er geen activiteit is, dus het kan even duren vooraleer de front-end online is.

De rest zou normaal correct ingevuld moeten zijn. **Controleer dit voor jouw situatie**.

![Render front-end settings part 1](./images/10_14_frontend_settings_part_1.png ':size=80%')

We moeten onze front-end nog vertellen waar onze back-end draait. Dit doen we door een environment variabele in te stellen. Kopieer de URL van jouw back-end van het Render dashboard naar een environment variabele met naam `VITE_API_URL`. Vergeet niet `/api` toe te voegen aan het einde van de URL, tenzij je dit anders aangepakt hebt in jouw applicatie.

![Render front-end settings part 2](./images/10_15_frontend_settings_part_2.png ':size=80%')

Klik vervolgens op "Deploy" en wacht geduldig af (het gratis plan kan trager zijn). Als alles goed is gegaan, zou je nu een werkende front-end moeten hebben. De URL van jouw front-end vind je linksboven.

![Front-end is online](./images/10_16_frontend_online.png ':size=80%')

### CORS probleem

Je kan nu alvast naar jouw front-end gaan maar je zal merken dat er nog een probleem is. Probeer bijvoorbeeld een gebruiker te registreren (of een ander request uit te voeren) en bekijk de console. Je krijgt een CORS error, dit moeten we gaan fixen in de back-end!

![CORS error](./images/10_17_frontend_cors.png ':size=80%')

CORS kan je enkel oplossen door in de back-end de juiste headers te zetten. Gezien we dit in onze environment geconfigureerd hebben, moeten we alleen de URL van onze front-end toevoegen aan de CORS origins op Render.

> Merk dus op dat je een CORS-probleem niet kan oplossen in de front-end of als je geen toegang hebt tot de back-end!

![CORS fix](./images/10_17.2_frontend_cors.png ':size=80%')

## Hosting remarks

Dit was maar een (eenvoudig) voorbeeld om je applicatie online te zetten. Onze hoofdbekommernis was bovendien om alles 100% gratis te kunnen regelen, wat niet altijd het eenvoudigst of handigst is.

Hier linten of testen we onze applicatie ook niet voor we deze online zetten. We merken het dus niet op als onze applicatie een bug heeft die door de testen opgevangen zou worden.

> Tip: GitHub heeft een vrij grote free tier (2000 minuten aan computation time) op vlak van CI/CD. Dit heet GitHub Actions, waarbij je bij het pushen van code automatisch je testen kan laten uitvoeren en zoveel meer.

Als je ooit echte applicaties online wil zetten, kijk dan eerst eens rond. Er zijn veel opties, en vaak helemaal niet duur meer maar zelden helemaal gratis. Vaak zal de CI/CD pipeline veel meer omvatten dan louter builden en online plaatsen.

Op Render wordt ook de complexiteit van de CI/CD pipeline niet getoond. Je moet slechts een paar veldjes invullen en Render doet alle magie voor jou. Dit is natuurlijk niet realistisch. Als je ooit een echte applicatie online zet, zal je zelf een CI/CD pipeline moeten opzetten. Dit is een hele klus en je zal er veel tijd in moeten steken. Het is echter wel de moeite waard, want het zal je veel tijd besparen in de toekomst.

Denk bij het online zetten van een applicatie ook altijd na over reproduceerbaarheid. Als je een applicatie online zet, moet je ervoor zorgen dat je dit opnieuw kan doen. Dit betekent dat je alles moet documenteren en automatiseren. Als je dit niet doet, zal je in de toekomst veel tijd verliezen. In dit hoofdstuk hebben we alles manueel gedaan, maar in een realistisch project zal je dit automatiseren met bv. [Terraform](https://developer.hashicorp.com/terraform), [Ansible](https://www.ansible.com/) of een andere tool. Zo kan je met één commando de hele infrastructuur opzetten.

## Oefening 1 - README

Pas vervolgens jouw README aan met de nodige commando's... om de applicatie in productie op te starten. Je kan inspiratie opdoen in de README's van de voorbeeldapplicaties.

> **Eindpunt voorbeeldapplicatie**
>
> De `main` branch bevat de finale versie van de voorbeeldapplicatie voor beide olods.

<iframe src="https://giphy.com/embed/3otPoS81loriI9sO8o" width="480" height="269" frameBorder="0" class="giphy-embed" allowFullScreen></iframe>
