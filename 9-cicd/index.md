# CI/CD

Dit hoofdstuk wordt gedeeld tussen de olods Front-end Web Development en Web Services. Onderstaande tabel geeft aan welke secties van toepassing zijn voor welk olod. In de secties waar één olod niet van toepassing is, wordt dit in de tekst ook nog eens expliciet vermeld.

**In dit hoofdstuk werk je uitsluitend met je eigen applicatie.** Het is de bedoeling dat je jouw eigen applicatie online zet. Je kan de voorbeeldapplicatie wel gebruiken als referentie, maar je moet de stappen zelf uitvoeren op jouw eigen applicatie.

| Sectie                                                             | Front-end Web Development | Web Services             |
| ------------------------------------------------------------------ | ------------------------- | ------------------------ |
| [Continuous Integration/Delivery](#continuous-integrationdelivery) | :heavy_check_mark:        | :heavy_check_mark:       |
| [Docker](#docker)                                                  | :heavy_check_mark:        | :heavy_check_mark:       |
| [Aanpassingen](#aanpassingen)                                      | :heavy_check_mark:        | :heavy_check_mark:       |
| [Back-end online zetten](#back-end)                                | :heavy_multiplication_x:  | :heavy_check_mark:       |
| [Front-end online zetten](#front-end)                              | :heavy_check_mark:        | :heavy_multiplication_x: |
| [Online plaatsen op vichogent.be](#online-plaatsen-op-vichogentbe) | :heavy_check_mark:        | :heavy_check_mark:       |

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

### Docker

Voor het online zetten van onze back-end willen we naar een mature development manier gaan.
Daarom gaan we docker gebruiken, zodat we onafhankelijk van onze host-systemen kunnen werken.
Gezien we met het VIC werken waarop we docker zullen uitvoeren, volstaat het voor ons om een `Dockerfile` aan te maken, waarin vastgelegd wordt wat nodig is om onze applicatie uit te voeren.

Het opstellen van de Dockerfiles zullen we specifiek in de volgende secties bespreken.
Ook zullen we de `docker-compose.yml` file gebruiken om onze applicatie lokaal te kunnen draaien in een identieke setup als op het VIC.

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
Hierbij valt op dat onze api-calls niet correct werken. We krijgen een CORS probleem. Dit pakken we verder in de cursus aan.

Wanneer we nu onze container nog kort even analyseren, dan valt op dat de docker image een grootte heeft van ongeveer 50 MB.
Dit is belangrijk om zo meteen te onthouden bij poging 2.

##### Problemen naïve poging

De problemen hiermee zijn vooral dat er veel manuele stappen zijn om de applicatie in docker op te starten.
Ons doel is om deze stappen te automatiseren.

#### Tweede poging: automatisering

##### Aanpassingen

In plaats van nu zelf de code te builden, zullen we docker dit laten doen voor ons in de `Dockerfile`.
Belangrijk hierbij is te onthouden dat we nog steeds de environment variables moeten instellen, maar dat dit niet meer op onze hostmachine gebeurt. We dienen deze nu door te geven aan de container.
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
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

# 👇 7
RUN mv ./dist/* /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

1. Net zoals voorheen willen we nog steeds dezelfde Nginx configuratie gebruiken en de default static files van Nginx verwijderen.
2. Ditmaal verplaatsen we ons eerst naar een working directory, zodat we onze build kunnen zetten op een plaats die niet gebruikt wordt door de container.
3. We willen de environment variables kunnen doorgeven als argument aan de container. Deze moeten we vervolgens ook instellen in de environment van de container.  De .env file is immers niet aanwezig is in de container. Bij een professionele applicatie zullen deze environment variabelen ingesteld worden op het systeem waarop de applicatie wordt uitgevoerd.
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
        VITE_API_URL: http://localhost:3000/api
    container_name: budget-app-frontend
    ports:
      - '80:80'
```

Tot slot zijn er nog een aantal bestanden die we sowieso niet mee willen in onze container, gezien deze alles zelf moet opbouwen vanaf onze codebase. Maak hiervoor een bestand `.dockerignore` aan in de root van de frontend-code, met de volgende inhoud:

```text
.env*
.gitignore
.vscode

cypress
dist
eslint.config.js
node_modules
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
# 👇 2
ENV PNPM_CONFIG_MINIMUM_RELEASE_AGE=0
RUN corepack enable

WORKDIR /usr/src/app

COPY . .

RUN pnpm install
RUN pnpm build

EXPOSE 3000

CMD ["node", "dist/src/main"]
```

1. Deze lijnen zijn identiek aan de `Dockerfile` van de front-end, we willen hier wederom gebruik kunnen maken van pnpm.
2. Deze lijn zorgt ervoor dat pnpm geen release age nodig heeft voor het installeren van dependencies. Indien deze lijn er niet staat kan het zijn dat we een dag moeten wachten voor te builden. Dit is over het algemeen wel een slim idee voor security redenen, maar in onze development omgeving is dit niet nodig en enkel omslachtig.

Indien dit niet lukt, controleer zeker de logs van de docker build. Hoogst waarschijnlijk is dit een probleem met de lockfile of met de approve-builds. Hiervoor kan je dan best de lockfile en node_modules eens verwijderen en opnieuw `pnpm install` doen, zodat je daarna `pnpm approve-builds` kan uitvoeren.

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
    env_file:
      - .env.docker-local
    ports:
      - '3000:3000'
    # 👇 3
    restart: unless-stopped
  # 👇 2
  db:
     image: mysql:8.0
     ports:
        - '3306:3306'
     volumes:
        - db_data_prod:/var/lib/mysql
     environment:
        MYSQL_ROOT_PASSWORD: root
        MYSQL_DATABASE: budget
        MYSQL_USER: devusr
        MYSQL_PASSWORD: devpwd
     healthcheck:
        test: [ 'CMD', 'mysqladmin', 'ping', '-h', 'localhost', '--silent' ]
        timeout: 30s
        interval: 30s
        retries: 5
        start_period: 30s

volumes:
   db_data_prod:
```

1. Het eerste deel uit dit bestand is bijna identiek aan het Docker Compose bestand uit de front-end. Dit wordt niet opnieuw herhaald. Let erop dat alle nodige environment variables doorgegeven worden via een env_file en niet als build arguments. Environment variables worden opgeslaan in de image en zijn at runtime beschikbaar voor de applicatie. Build arguments zijn enkel beschikbaar tijdens het bouwen van de image.
2. Dit is een copy-paste van onze database docker compose. Enkel de naam van het volume is aangepast (opgelet: op twee plaatsen).
3. De restart is noodzakelijk omdat we in één docker compose bestand twee services (containers) opstarten. Zowel de backend als de database. We weten echter niet zeker dat de database opgestart zal zijn voordat de backend opgestart is. Indien dit niet zo is zal de backend crashen. Om dit tegen te gaan laten we deze gewoon eenvoudigweg opnieuw opstarten.

De .env.docker-local ziet er als volgt uit:

```dotenv
NODE_ENV=production
PORT=3000
CORS_ORIGINS=["http://localhost:5173"]
CORS_MAX_AGE=10800
DATABASE_URL=mysql://devusr:devpwd@db:3306/budget 👈 1
LOG_LEVELS=["log","error","warn"]
LOG_DISABLED=false
AUTH_JWT_SECRET=eensuperveiligsecretvoorinproduction
```

1. In de `DATABASE_URL` staat na de @-teken `db`. Dit is de naam van de service in de docker compose file. Dit is omdat we hier gebruik maken van de interne DNS van docker compose.

Dit geheel kan je tot slot uitvoeren met het commando `docker compose -f docker-compose-backend.yml up`. Eventueel voeg je nog optie -d uit om dit als background process te starten.

##### Dockerignore

Vergeet ook niet om nog een bestand `.dockerignore` aan te maken in de root van de backend, met de volgende inhoud:

```text
.env*
.gitignore
.prettierrc
.vscode

coverage
docker-compose*.yml
Dockerfile
dist
eslint.config.mjs
jest-e2e.config.ts
node_modules
```

##### Problemen

Net zoals bij de front-end, hebben we hier het probleem dat onze image veel te groot is. Voor onze voorbeeldapplicatie is deze ongeveer 1.4 GB.

#### Multi-stage build

De aanpassingen die nodig zijn zullen zich enkel in de `Dockerfile` bevinden:

```Dockerfile
# 👇 1
FROM node:24-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV PNPM_CONFIG_MINIMUM_RELEASE_AGE=0
RUN corepack enable
# 👇 1.1
RUN apk add --no-cache libc6-compat

# 👇 1
FROM base AS dev-deps

WORKDIR /app

# 👇 2
COPY package.json pnpm*.yaml ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

# 👇 1
FROM base AS prod-deps

WORKDIR /app

# 👇 3
COPY package.json pnpm*.yaml ./
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
COPY --from=builder /app/migrations ./migrations

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

## Online plaatsen op vichogent.be

### Algemene info

Afhankelijk van of je groep ingeschreven is in de cursus `Web Services` of `Front-end Web Development` zal je groepsnummer er respectievelijk als `WSXX` of `FWDXX` uitzien, waarbij `XX` het nummer zal zijn.
Deze groepsnaam zal gevolgd worden voor de DNS naam die jouw VPS van het VIC zal krijgen.
Om dit niet telkens te herhalen zullen we in de cursus als naamgeving de vorm `GXX` hanteren.

In het begin van de semester werden de VPS's (Virtual Private Server) aangevraagd bij vichogent.be.
Hiervoor werd de public key van je SSH keypair doorgestuurd.
Hiermee is er vanuit het VIC een virtuele server voorzien per groep, beide studenten kunnen connecteren met SSH.
Jullie ontvingen hierover een mailing met de aan jullie toegekende poort.

Hiermee wordt achterliggend via een firewall (die zorgt voor portforwarding) doorgestuurd naar de VPS die aan jullie toegekend is, dewelke afgeschermd is via SSH.
Vanwege deze afscherming is het dus niet mogelijk te connecteren met de server die aan een andere groep toegekend is.

Op iedere server zijn twee poorten geconfigureerd via een reverse proxy:

- poort 80, geconfigureerd op domein `https://GXX-frontendweb.vichogent.be`
- poort 3000, geconfigureerd op domein `https://GXX-webservices.vichogent.be`

?> Opmerking: je ziet dat er geen poort geconfigureerd staat voor de database. Dat wil zeggen dat we niet zelf aan de database kunnen en dat deze enkel bereikbaar zal zijn voor de backend via het docker compose dns systeem. Dit is een security best practice die we voldoen. Dit zal ons een probleem opleveren voor de seeding van de database, maar in een volgend deel van dit hoofdstuk zullen we dat probleem aanpakken.

Het is dus belangrijk dat de applicaties draaien op de juiste poort van het toestel, anders zal het geheel niet werken.
Denk hierbij zeker na over de werking van de portforwarding van docker compose!
Dit hebben we echter bewust op de juiste manier geconfigureerd in het eerst deel van dit hoofdstuk.

### Connecteren met de VPS

!> Opgelet: denk verantwoord na over wat je met de server doet. Dit is een toestel dat gemonitord wordt, het is niet toegestaan illegaal gebruik via deze server uit te voeren. Cryptomining is alsook niet toegestaan.

!> Opgelet: je mag nooit de VPS afsluiten. Gezien dit geen fysiek toestel is, zou je deze niet meer opgestart krijgen.

Iedere student heeft normaal toegang tot de VPS.
Jullie hebben hiervoor een poort ontvangen.
Connecteren doe je via het volgende commando (XXXXX vervangen door de door jullie ontvangen poort):

```bash
ssh vicuser@vichogent.be -p XXXXX
```

Indien dit niet werkt, bij één student en bij de andere wel, dan is dit een probleen in ssh configuratie die jullie zelf kunnen oplossen.
In de map `.ssh` zal je een bestand genaamd `authorized_keys` zien.
Deze kan je wijzigen, waarbij je enkel de publieke ssh key van de andere student hoeft toe te voegen.

!> Opgelet: verwijder geen andere SSH keys, zo kan je ervoor zorgen dat anderen niet meer in je server kunnen. Dan kunnen wij je niet meer (gemakkelijk) helpen.

### Configureren VPS

Iedere groep krijgt een VPS waar alleen maar standaardinstellingen op staan.
We zullen dus zelf docker moeten installeren.

De VPS is een Ubuntu VM, voor de installatie van Docker kan je dus de officiële handleiding van [Docker](https://docs.docker.com/engine/install/ubuntu/) volgen.
Volg hierbij de stappen `Install using the api repository`.

### Binnenhalen van de projectcode

Voor het binnenhalen van de projectcode zullen we gebruik maken van `git clone <url>`.
Het probleem hierbij is echter dat de repositories private zijn, dus dat de VPS hier geen toegang toe heeft.
Om dit probleem op te lossen gaan we gebruik maken van [GitHub Deploy keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#deploy-keys).

In essentie moet je eerst een SSH public-private-keypair maken (herinner `ssh-keygen`) op de VPS.
Vervolgens zal je de public key moeten toevoegen aan de private repository op GitHub onder `Settings > Security and quality > Deploy keys`.
Zo geef je de VPS toegang enkel en alleen tot de repository.

Tot slot kan je de code binnenhalen via `git clone <url>`.

### Opstarten applicatie

De laatste stap is het opstarten van de applicatie via `docker compose`.

Let er hier bij op dat we in het eerste deel van dit hoofdstuk een aparte docker-compose file hebben gebruikt voor front-end en back-end.
Het is eenvoudiger om deze te combineren tot één enkele docker-compose file, hoewel dit niet strikt noodzakelijk is.

Let erbij op dat je nog enkele wijzigingen moet doen:

- Bij de frontend-service moet de `VITE_API_URL` ingesteld worden op `https://GXX-webservices.vichogent.be/api`.
- Bij de backend-service moet een `.env.production` bestand toegevoegd worden. Deze is gelijkaardig aan de `.env.docker-local` die we eerder maakten, enkel de `CORS_ORIGINS` moet ingesteld worden op `["https://GXX-frontendweb.vichogent.be"]`.

Eenmaal dit klaargezet is kan je de applicatie opstarten met `docker compose up -d` (indien je file anders heet dan `docker-compose.yml` mag je de -f optie niet vergeten).
Dit kan soms een error geven op pnpm build/install instructies, indien dit voorvalt probeer je best gewoon eens opnieuw. Dit komt vermoedelijk door een timing probleem in de docker build, maar vanwege de caching in docker zal hij alle voorgaande layers niet opnieuw moeten uitvoeren.

### Seeding

De laatste stap voordat alles klaar is, is de seeding van het project.
Zoals eerder vermeld is dat een lastig probleem, omdat we geen toegang hebben tot de database.
Bovendien willen we geen `pnpm` installeren op de VPS (gezien de code binnenhalen zelf eigenlijk iets is dat beter kan).

!> Zorg dat er geen docker container (of ander proces) draait op poort 3306 van je eigen toestel.

Dit zullen we oplossen door via SSH een tunnel te leggen met de VPS.
Hierbij zullen we poort 3306 van de VPS tunnelen naar poort 3306 van onze localhost over SSH.
Dit doen we met het volgende commando:

```bash
ssh vicuser@vichogent.be -p XXXXX -L 3306:localhost:3306
```

Dit zal in terminal tonen dat je aangemeld bent op de VPS, sluit deze zeker niet af (anders beëindig je de tunnel).
Dit heeft als resultaat dat je de seeding van je project kan uitvoeren op je localhost op poort 3306 (zoals we altijd deden met `pnpm db:seed` voor local development).
De data zal echter in de database op de VPN terecht komen.

### Controle resultaat

Vergeet niet te controleren of het uiteindelijke resultaat correct is.
Surf naar `https://GXX-frontendweb.vichogent.be` en controleer of alles werkt zoals gewenst.

### Mogelijke verbeteringen (Optioneel)

Hieronder staan wat verbeteringen op vlak van automatische pipelines. Dit is volledig optioneel en gaat buiten de scope van deze cursus.
Moest je toch zo een automatisch systeem maken, vermeld dit zeker in je dossier zodat we hier vragen naar kunnen stellen.

#### Via GitHub Actions (Optioneel)

Je zou de docker image kunnen builden aan de hand van github actions.
Deze moet dan opgeslagen worden in een artifact repository waar docker images in kunnen staan.
Hiervoor kan je gebruik maken van `ghcr.io`, de GitHub Container Repository.
Deze hangt automatisch gelinkt aan je private repository.

Het enige dat je dan moet doen op de VPS is de docker compose file maken, waarbij je ipv. de context zal verwijzen naar de image op ghcr.io.
Eén van moeilijkheden hiervan is het werken met versienummers.
Bij een nieuwe versie moet je dan enkel naar de VPS connecteren, vervolgens in de docker compose file de versie van de image aanpassen en opnieuw `docker compose up` uitvoeren.

Indien gewenst zou je ook een action kunnen maken die automatisch deze stappen uitvoert.
Dan kan je zorgen dat de action zelf connecteert met de VPS en de docker compose file aanpast en uitvoert.

#### Zelf build pipeline maken (Optioneel)

Je kan ook de automatische pipeline zelf opzetten (vb via Jenkins).

Indien je iets interessant wil proberen en hiervoor meer rekenkracht nodig hebt, stuur ons zeker een mailtje met wat uitleg over wat je wil proberen en welke resources je denkt nodig te hebben. (ander voorbeeld zou kunnen zijn om zelf een github action runner te hosten voor het maken van de pipeline).

## Oefening 1 - README

Pas vervolgens jouw README aan met de nodige commando's... om de applicatie in productie op te starten. Je kan inspiratie opdoen in de README's van de voorbeeldapplicaties.

Wanneer je in je README of cursusnotities naar branches verwijst, gebruik dan dezelfde `chapter-X` naamgeving als elders in de cursus.

> **Eindpunt voorbeeldapplicatie**
>
> Voor dit hoofdstuk kan je verder bouwen op een lokale branch zoals `chapter-9`. De `main` branch bevat de finale versie van de voorbeeldapplicatie voor beide olods.

<iframe src="https://giphy.com/embed/3otPoS81loriI9sO8o" width="480" height="269" frameBorder="0" class="giphy-embed" allowFullScreen></iframe>
