# CI/CD (WIP)

Dit hoofdstuk wordt gedeeld tussen de olods Front-end Web Development en Web Services. Onderstaande tabel geeft aan welke secties van toepassing zijn voor welk olod. In de secties waar één olod niet van toepassing is, wordt dit in de tekst ook nog eens expliciet vermeld.

**In dit hoofdstuk werk je uitsluitend met je eigen applicatie.** Het is de bedoeling dat je jouw eigen applicatie online zet. Je kan de voorbeeldapplicatie wel gebruiken als referentie, maar je moet de stappen zelf uitvoeren op jouw eigen applicatie.

| Sectie                                                             | Front-end Web Development | Web Services             |
| ------------------------------------------------------------------ | ------------------------- | ------------------------ |
| [Continuous Integration/Delivery](#continuous-integrationdelivery) | :heavy_check_mark:        | :heavy_check_mark:       |
| [Nodige services](#nodige-services)                                | :heavy_check_mark:        | :heavy_check_mark:       |
| [Refactoring](#refactoring)                                        | :heavy_check_mark:        | :heavy_check_mark:       |
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

Als iedereen door elkaar commit op deze branch, lukt dat nooit natuurlijk. Er is dus een andere git-strategie nodig.

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

?> Studenten die reeds geslaagd zijn voor het olod Web Services en een databank nodig hebben om hun back-end van vorig jaar te hergebruiken, gelieve een mail te sturen naar [Thomas Aelbrecht](mailto:thomas.aelbrecht@hogent.be).

### Render

Er bestaan heel wat software- en cloudoplossingen om CI/CD toe te passen. Vaak zijn deze oplossingen betalend want een paar virtuele machines opstarten om tests te draaien van een beetje serieuze applicaties is niet gratis natuurlijk.

[Heroku](https://www.heroku.com/) had een gratis versie die eenvoudig te gebruiken was, maar die is, jammer genoeg, [verdwenen sinds 28 november 2022](https://dev.to/lukeecart/more-heroku-changes-that-will-definitely-affect-you-10o8).

Daarom maken we vanaf nu gebruik van een all-in-one oplossing, nl. [Render](https://render.com/). De Render omgeving is gratis (tot een bepaalde limiet uiteraard) en biedt meteen een oplossing voor zowel back-end als front-end. Het is ontzettend eenvoudig - een beetje klikken, invullen en klaar.

### MySQL databank in het VIC

Als we onze back-end online willen zetten, hebben we een MySQL databank nodig. Op [Render](https://render.com/) kan je gratis een PostgreSQL databank opstarten, maar wij gebruik MySQL (naar analogie met het olod Databases I). _Feel free to switch, but you're on your own then._

Er bestaan heel wat gratis MySQL services online maar eigenlijk geen enkele degelijke waar je geen kredietkaart voor nodig hebt, ofwel zien ze er sketchy uit of zijn ze vaak down.

Daarom hosten we zelf een MySQL databank in het VIC (Virtual IT Company van HOGENT). Jullie krijgen (of kregen) een mail met de inloggegevens van jouw persoonlijke MySQL databank. **Let op: er wordt maar één databank per student voorzien!**

**Dus je moet zelf geen MySQL databank aanmaken!** Droppen van de databank is mogelijk vanuit code, dat kunnen we helaas niet verhinderen. Wil je terug een lege databank? Drop dan simpelweg alle tabellen manueel.

We zijn geen gigantisch datacenter, dus we kunnen niet garanderen dat de databank altijd online zal zijn of snel zal reageren. We doen ons best om de databank zo goed mogelijk online te houden.

Bij problemen met de databank kan je altijd terecht bij [Thomas Aelbrecht](mailto:thomas.aelbrecht@hogent.be).

### Docker

Voor het online zetten van onze backend willen we naar een mature development manier gaan.
Daarom gaan we docker gebruiken, zodat we onafhankelijk van onze host-systemen kunnen werken.
Gezien we met Render werken, volstaat het voor ons om een Dockerfile aan te maken, waarin vastgelegd wordt wat nodig is om onze applicatie uit te voeren.

Het opstellen van de Dockerfiles zullen we specifiek in de volgende secties bespreken.
Ook zullen we de docker-compose.yml file gebruiken om onze applicatie lokaal te kunnen draaien in een identieke setup als op Render.

Het grote voordeel van Docker is dat we op de server geen installatie van software gaan moeten doen, dit wordt allemaal gedaan in Docker.
Het enige dat we nodig hebben op de server is docker zelf.

## Aanpassingen

Deze sectie is verdeeld in een stuk voor de [back-end](#back-end) en een stuk voor de front-end. De back-end sectie is enkel van toepassing voor het olod Web Services. De [front-end](#front-end) sectie is enkel van toepassing voor het olod Front-end Web Development.

[//]: # TODO()
### Back-end

Allereerst moeten we ervoor zorgen dat onze back-end klaar is om in een productie-omgeving te draaien.

#### Dynamisch poortnummer en JWT secret

We moeten eerst een paar kleine aanpassingen doen aan onze code zodat deze werkt in onze productie-omgeving. Wij starten onze server altijd op poort 9000, maar op Render kan je de poort niet zomaar kiezen (je bent niet alleen op de server). Render kiest zelf een poort die het beschikbaar heeft, geeft die door aan je proces, en verwacht dan dat je je daaraan bindt.

Pas daarom de code van de `start` functie uit `src/createServer.ts` aan zodat de poort uit configuratie gelezen wordt:

```ts
// ... (imports)
import config from 'config'; // 👈

const PORT = config.get<number>('port'); // 👈

return {
  // ...

  start() {
    return new Promise<void>((resolve) => {
      app.listen(PORT); // 👈
      getLogger().info(`🚀 Server listening on http://localhost:${PORT}`); // 👈
      resolve();
    });
  },

  // ...
};
```

Vervolgens zorgen we ervoor dat we de environment variabele `PORT` mappen naar het configuratieproperty `port`. Daarnaast zorgen we er ook voor dat we de environment variabele `AUTH_JWT_SECRET` mappen naar het configuratieproperty `auth.jwt.secret` zodat we het JWT secret kunnen instellen vanuit environment variabelen. Je wil nl. het secret niet publiek in je code hebben staan.

Controleer of het bestand `config/custom-environment-variables.ts` minstens onderstaande inhoud heeft. Je mag dit uiteraard uitbreiden met andere environment variabelen die je nodig hebt in je eigen project.

```ts
export default {
  env: 'NODE_ENV',
  port: 'PORT',
  auth: {
    jwt: {
      secret: 'AUTH_JWT_SECRET',
    },
  },
};
```

Voeg vervolgens poort 9000 toe aan de **alle** configuratiebestanden.

```ts
export default {
  port: 9000,
  // ... (andere properties)
};
```

#### Default configuratie

Je merkt dat we heel wat identieke configuratie op meerdere plekken hebben, dat is niet ideaal. Je kan dit oplossen door een bestand `config/default.ts` toe te voegen met de default configuratie. Vervolgens kan je in elk configuratiebestand enkel de verschillen met de default configuratie opgeven.

Zonder alle gedeelde configuratie af in een bestand `config/default.ts` en pas de andere configuratiebestanden aan zodat ze enkel de verschillen bevatten. Deze properties moet je momenteel minimaal hebben in elk configuratiebestand:

- `config/development.ts`
  - `auth.jwt.expirationInterval`
  - `auth.jwt.secret`
- `config/production.ts`
  - `auth.jwt.expirationInterval`
- `config/testing.ts`:
  - `auth.maxDelay`
  - `auth.jwt.expirationInterval`
  - `auth.jwt.secret`

Het secret zetten we niet in de default configuratie omdat we willen dat dit in productie expliciet ingesteld wordt, of een fout oplevert als het niet ingesteld is.

#### Versies van Node.js en Yarn

Het laatste moeten ervoor zorgen dat Render beschikt over de juiste versies van Node.js en Yarn. Voeg onderstaand fragment toe onderaan jouw `package.json`. Voeg eventueel komma's toe om een correct JSON-syntax te krijgen. Uiteraard laat je de buitenste accolades weg! Je kan de versies aanpassen als je dat wenst.

```json
{
  "engines": {
    "node": "20.6.0",
    "yarn": "4.4.0"
  }
}
```

Nu zijn we klaar om onze back-end online te zetten. **Commit en push deze wijziging.**



















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
Deze zal er voor ons voor zorgen dat onze productie build van de front-end als static files geleverd kunnen worden.

Maak hiervoor een bestand `nginx.conf` aan in de root van de frontend-code.
Een standaard, maar productie klare Nginx configuratie leveren we hieronder aan:

```
events{} 👈 1
http {
    include /etc/nginx/mime.types; 👈 2
    server {
        listen 80; 👈 3
        server_name localhost; 👈 4
        root /usr/share/nginx/html; 👈 5
        index index.html; 👈 6
        location / {
            try_files $uri $uri/ /index.html; 👈 7
        }
    }
}
```

1. Deze regel is vereist voor Nginx om te kunnen opstarten. De defaults zijn echter voldoende, waardoor we niets overschrijven.
2. Deze regel zorgt ervoor dat de mime-type mappings ingeladen worden, zodat Nginx de correct Content-type headers kan meegeven.
3. Deze regel zorgt ervoor dat de Nginx server luistert op poort 80.
4. Deze regel zorgt ervoor dat de server reageert op bevragingen naar localhost. Dit is in orde omdat dit draait in Docker.
5. Deze regel geeft aan aan Nginx waar de static files te vinden zijn.
6. Deze regel geeft aan wat de naam van de index file is.
7. Deze regel probeert de inkomende request te verwerken door de static files te verwerken. Hiervoor zoekt hij eerste naar de specifieke file, dan naar de directory en tenslotte een fallback naar de index file. Dit laatste is cruciaal voor SPA's.

##### Docker

Om nu deze Nginx server te laten draaien, zullen we zelf een `Dockerfile` maken, waarin we beschrijven wat er allemaal moet gebeuren om onze applicatie te laten draaien.
Hiervoor maken we een `Dockerfile` aan in de root van de frontend-code, met de volgende inhoud:

```
FROM nginx:1.27.4-alpine 👈 1

COPY ./nginx.conf /etc/nginx/nginx.conf 👈 2

RUN rm -rf /usr/share/nginx/html/* 👈 3

COPY ./dist /usr/share/nginx/html 👈 4

EXPOSE 80 👈 5

CMD ["nginx", "-g", "daemon off;"] 👈 6
```

1. Deze regel zorgt ervoor dat de Nginx-image van Docker wordt gebruikt.
2. Deze regel kopieert de Nginx configuratie uit onze code naar de juiste locatie in de Docker-container.
3. Deze regel verwijdert de bestaande (default) static files uit de Nginx-server.
4. Deze regel kopieert de build van de front-end naar de Nginx-server.
5. Deze regel geeft aan aan Docker dat poort 80 moet worden geopend (de standaardpoort voor Nginx). Dit is nodig omdat we de Nginx-server draaien in Docker, en niet op de hostmachine.
6. Deze regel start de Nginx-server.

##### Docker-compose

Om ervoor te zorgen dat we lokaal een geautomatiseerde opstart hebben, die bovendien zo dicht mogelijk aanleunt bij de productieomgeving, maken we gebruik van Docker-compose.
Hiervoor maken we een bestand `docker-compose.yml` aan in de root van de frontend-code, met de volgende inhoud:

```
services:
  budget-app-frontend:
    image: budget-app-frontend 👈 1
    build:
      context: .
      dockerfile: ./Dockerfile 👈 2
    container_name: budget-app-frontend
    ports:
      - '80:80' 👈 3
```

1. Deze regel geeft aan welke naam de gemaakte image zal krijgen.
2. Deze regel beschrijft hoe de Docker-image van onze front-end wordt gebouwd. Wij zeggen hiermee dat dit gebouwd moet worden uit de `Dockerfile` in de root van de frontend-code.
3. Deze regel zal poort 80 van de hostmachine naar poort 80 in de Docker-container binden. Dit is nodig omdat we de Nginx-server draaien in Docker, en niet op de hostmachine. Bovendien is poort 80 de default voor http, waardoor we zullen kunnen surfen naar `http://localhost`.

##### Eerste test

Wanner we nu `docker compose up` uitvoeren, zullen we een Nginx-server draaien met onze front-end.
We kunnen nu naar `http://localhost` surfen om te controleren of alles goed werkt.
Hierbij valt op dat onze api-calls niet correct werken, hierbij zien we dat de baseUrl van onze api-client niet juist is.
Deze hebben we tot nu toe ingesteld in de `.env` file, maar een productie build gebruikt dit niet. 
De productie build gaat kijken naar de environment-variabelen van ons systeem.

##### Oplossing bug

[//]: # (TODO: OPMERKING VOOR DE REVIEWER: kan iemand dat windows commando uitproberen ajb? ik kan dit zelf niet testen.)

Om dit op te lossen moeten we de environment-variabelen van ons systeem instellen.
Dit doen we in bash met het command `VITE_API_URL="http://localhost:3000/api"` of in windows met `set  VITE_API_URL="http://localhost:3000/api"`.
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

In de plaats van nu zelf de code te builden, zullen we docker dit laten doen voor ons in de `Dockerfile`.
Belangrijk hierbij is te onthouden dat we nog steeds de environment variables moeten instellen, maar dat dit niet meer op onze hostmachine gebeurt.
Hiervoor zullen we deze als volgt aanpassen: 

```
FROM nginx:1.27.4-alpine

COPY ./nginx.conf /etc/nginx/nginx.conf 👈 1
RUN rm -rf /usr/share/nginx/html/* 👈 1

WORKDIR /usr/src/app 👈 2
COPY . . 👈 2

ARG VITE_API_URL 👈 3
ENV VITE_API_URL=$VITE_API_URL 👈 3

ENV PNPM_HOME="/pnpm" 👈 4
ENV PATH="$PNPM_HOME:$PATH" 👈 4

RUN apk add --update nodejs npm 👈 5
RUN npm install -g pnpm@10.15.0 👈 5
RUN pnpm add -D vite 👈 5

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile 👈 6
RUN pnpm run build 👈 6

RUN mv ./dist/* /usr/share/nginx/html 👈 7

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

1. Net zoals voorheen willen we nog steeds dezelfde nginx configuratie gebruiken en de default static files van nginx verwijderen.
2. Ditmaal gaan we eerst naar een working directory verplaatsen, zodat we onze build kunnen zetten op een plaats die niet gebruikt wordt door de container.
3. We willen de environment variables kunnen doorgeven aan de container. Deze moeten we vervolgens ook instellen in de environment van de container.
4. Omdat we pnpm willen gebruiken, gaan we al instellen in de container waar pnpm komt te staan.
5. Voordat we onze productie build kunnen uitvoeren, moeten we eerst de afhankelijkheden installeren. Hiervoor hebben we nodejs, pnpm en vite nodig. Om pnpm te installeren hebben we echter ook npm nodig.
6. Nu kunnen we eindelijk onze productie build uitvoeren. hierbij hebben we eerst ook een install waarbij wat instellingen gebeuren om alles performant te laten werken (gebruikmakend van caching), en waarbij we instellen dat pnpm de versies uit onze lockfile moet gebruiken.
7. Tot slot kunnen we de dist folder naar de verwachte locatie van de Nginx-server kopieren. Let er hierbij op dat we het mv commando moeten gebruiken, dus dat de syntax een beetje verschilt tegenover het voorheen was.

We moeten echter ook nog de docker-compose file aanpassen, zodat voor ons gemak van lokaal testen deze environment variables doorgegeven worden:
```
services:
  budget-app-frontend:
    image: budget-app-frontend
    build:
      context: .
      dockerfile: ./Dockerfile
      args:
        - "VITE_API_URL=http://localhost:3000/api"
    container_name: budget-app-frontend
    ports:
      - '80:80'
```

Tot Slot zijn er nog een aantal files die we sowieso niet mee willen in onze container, gezien deze alles zelf moet opbouwen vanaf onze codebase.
Maak hiervoor een bestand `.dockerignore` aan in de root van de frontend-code, met de volgende inhoud:

```
node_modules
.vscode
cypress
dist
```

Let erop, als je wijzigingen aanbrengt in de code en opnieuw wil builden, dan moet je telkens de docker-image verwijderen, want anders zorgt docker zijn caching van layers en versioning ervoor dat de vorige versie gebruikt wordt.

##### Problemen tweede poging

Als eerste valt het op hoeveel software we manueel moeten installeren in de container om onze applicatie te kunnen laten draaien.
Dit is veel omslachtiger dan gewenst is.

Daarnaast is er een tweede probleem, dat veel ernstiger is. 
Docker-images willen we light-weight houden, maar wanneer we nu kijken naar de grootte van de image, dan zien we dat deze drastisch vergroot is, tot bijna 1.2 GB.

#### Finale poging: Multi-stage build

Deze laatste problemen zullen we oplossen door gebruik te maken van een [multi-stage build](https://docs.docker.com/build/building/multi-stage/).

Bij een multi-stage docker build, zullen we een container gebruiken om een deel van de "heavy lifting" voor ons te doen.
Deze container zal vertrekken van een image die voor ons geschikt is om dat specifieke deel van het werk te doen. 
Daarna zullen we een nieuwe container maken die verder bouwt op het resultaat van de vorige container, maar die zelf ook weer vertrekt van een image die wederom ideaal is voor de volgende stap.
Dit proces van de eerste container naar de tweede container wordt ook wel "multi-stage build" genoemd.

Het einde van een stage herken je eenvoudige door het `FROM` keyword die opnieuw gebruikt wordt.

##### Aanpassingen


```
FROM node:24-alpine AS base 👈 1

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable 👈 2

WORKDIR /usr/src/app
COPY . .

FROM base AS build 👈 1

ARG VITE_API_URL 👈 3
ENV VITE_API_URL=$VITE_API_URL 👈 3

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile 👈 3
RUN pnpm run build 👈 3


FROM nginx:1.27.4-alpine 👈 1

COPY ./nginx.conf /etc/nginx/nginx.conf
RUN rm -rf /usr/share/nginx/html/*

COPY --from=build /usr/src/app/dist /usr/share/nginx/html 👈 4

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

1. Bij de finale oplossing zullen we drie stage gebruiken:
   1. De eerste stage vertrekt van een nodejs image, waarmee we de nodige software reeds hebben. Deze stage wordt bij ons `base` genoemd.
   2. De tweede stage bouwt verder op de eerste, en gebruiken we om de specifieke build van de applicatie te maken. Deze is strikt gezien niet noodzakelijk, maar zorgt voor een mooie scheiding van verantwoordelijkheden. Deze stage wordt bij ons `build` genoemd.
   3. De laatste stage vertrekt van een nginx image, zodat we de server eenvoudig zullen kunnen starten.
2. We zitten hier in een nodejs docker, corepack enable zorgt ervoor dat we pnpm zullen kunnen gebruiken in het verdere verloop
3. In onze build stage geven we de environment variables door aan de container en maken we de effectieve productie build.
4. Tot slot moeten we enkel nog de dist folder van onze vorige stage kopiëren naar de verwachte locatie van de Nginx-server.

##### Besluit

Deze finale poging zorgt ervoor dat het hele build process van de applicatie volledig automatisch wordt uitgevoerd. 
Het heeft ook het installeren van de nodige software voor ons vereenvoudigd.

Tot slot als we nu opnieuw kijken naar de grootte van de image, dan zien we dat deze opnieuw mooi op 50 MB uitkomt.









Ook hier moeten we ervoor zorgen dat Render beschikt over de juiste versies van Node.js en Yarn. 
Voeg onderstaand fragment toe onderaan jouw `package.json`. 
Voeg eventueel komma's toe om een correct JSON-syntax te krijgen. 
Uiteraard laat je de buitenste accolades weg! Je kan de versies aanpassen als je dat wenst. 
**Commit en push deze wijziging!**

```json
{
  "engines": {
    "node": "20.6.0",
    "yarn": "4.4.0"
  }
}
```

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
- Kies "Frankfurt (EU Central)" als regio.
- Vul bij "Root Directory" de naam van de map in waar je back-end code staat. Dit is de map waarin je `package.json` staat. Indien alles in de root staat, laat je dit veld leeg.
- Vul `corepack enable && yarn install && yarn build && yarn prisma migrate deploy` in bij "Build Command". Dit is het commando dat Render zal uitvoeren om je back-end te bouwen. We zorgen ervoor dat we Yarn v2 kunnen gebruiken, installeren eerst onze dependencies, bouwen vervolgens onze applicatie en migreren onze databank.
  - Wens je de databank te resetten? Voer dan lokaal `yarn prisma migrate reset --force` uit maar dan met de juiste `DATABASE_URL` in je `.env` bestand. **Gebruik dit commando NOOIT in de instellingen van Render!** Je gooit hiermee de hele databank weg en dat is niet de bedoeling.
- Vul `node build/src/index.js` in bij "Start Command". Dit is het commando dat Render zal uitvoeren om je back-end te starten. We starten onze back-end vanuit de `build` directory.
- Kies tenslotte voor "Free" als plan. Dit is het gratis plan van Render. Dit is voldoende voor onze applicatie. Hierdoor wordt jouw applicatie wel afgesloten indien er geen activiteit is, dus het kan even duren vooraleer de back-end online is.

De rest zou normaal correct ingevuld moeten zijn. **Controleer dit voor jouw situatie**.

![Render back-end settings part 1](./images/10_7_backend_settings_part_1.png ':size=80%')

![Render back-end settings part 2](./images/10_8_backend_settings_part_2.png ':size=80%')

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

Het is tijd om onze front-end online te zetten. Onze front-end is (na het builden) niet meer dan een statische website met wat HTML, JS, CSS... Veel hebben we hiervoor dus niet nodig.

Open het Render dashboard en klik rechtsboven op "+ New" en "Static Site" (of klik op "New Static Site" indien je geen back-end hebt).

![Render new web service](./images/10_12_new_static_site.png ':size=80%')

Zoek nu jouw **eigen** front-end repository op en klik op "Connect"

![Render search front-end repo](./images/10_13_search_frontend_repo.png ':size=80%')

Vul vervolgens alle nodige settings in:

- Kies een unieke naam voor je statische website (hint: je repository-naam is uniek).
- Selecteer eventueel een project.
- Vul bij "Root Directory" de naam van de map in waar je front-end code staat. Dit is de map waarin je `package.json` staat. Indien alles in de root staat, laat je dit veld leeg.
- Vul `corepack enable && yarn install && yarn build` in bij "Build Command". Dit is het commando dat Render zal uitvoeren om je front-end te bouwen. We zorgen ervoor dat we Yarn v2 kunnen gebruiken, installeren eerst onze dependencies en bouwen vervolgens onze applicatie.
- Vul `dist` in bij de "Publish directory".

De rest zou normaal correct ingevuld moeten zijn. **Controleer dit voor jouw situatie**.

![Render front-end settings part 1](./images/10_14_frontend_settings_part_1.png ':size=80%')

We moeten onze front-end nog vertellen waar onze back-end draait. Dit doen we door een environment variabele in te stellen. Kopieer de URL van jouw back-end van het Render dashboard naar een environment variabele met naam `VITE_API_URL`. Vergeet niet `/api` toe te voegen aan het einde van de URL, tenzij je dit anders aangepakt hebt in jouw applicatie. Daarnaast voegen we ook `SKIP_INSTALL_DEPS` toe met waarde `true` zodat Render onze dependencies niet automatisch installeert. Indien dit wel zou gebeuren, zou dit een foutmelding geven omdat corepack nog niet ingeschakeld is.

![Render front-end settings part 2](./images/10_15_frontend_settings_part_2.png ':size=80%')

Klik vervolgens op "Deploy Static Site" en wacht geduldig af (het gratis plan kan trager zijn). Als alles goed is gegaan, zou je nu een werkende front-end moeten hebben. De URL van jouw front-end vind je linksboven.

![Front-end is online](./images/10_16_frontend_online.png ':size=80%')

### CORS probleem

Je kan nu alvast naar jouw front-end gaan maar je zal merken dat er nog een probleem is. Probeer bijvoorbeeld een gebruiker te registreren (of een ander request uit te voeren) en bekijk de console. Je krijgt een CORS error, dit moeten we gaan fixen in de back-end!

![CORS error](./images/10_17_frontend_cors.png ':size=80%')

CORS kan je enkel oplossen door in de back-end de juiste headers te zetten. We hadden reeds ons CORS package geconfigureerd en moeten enkel de URL aanpassen in het bestand `config/production.ts`. Voeg jouw eigen front-end URL toe aan de `cors.origins` array.

> Merk dus op dat je een CORS-probleem niet kan oplossen in de front-end of als je geen toegang hebt tot de back-end!

```js
// config/production.ts
export default {
  cors: {
    origins: ['https://frontendweb-budget-dna5.onrender.com'], // 👈
  },
  // ...
};
```

**Commit en push deze wijziging.** Wacht tot de back-end opnieuw online is en herlaad de front-end. De CORS error zou nu weg moeten zijn.

### 404 probleem

Probeer nu op jouw front-end rechtstreeks naar een URL verschillend van `/` te gaan. In ons voorbeeld gaan we naar `/transactions`. Je zal merken dat je een 404 krijgt. Dit moeten we oplossen in de front-end!

Ga naar het Render dashboard van jouw front-end en klik op "Redirects/Rewrites". Voeg een nieuwe Rewrite-regel toe zoals op onderstaande afbeelding. Klik vervolgens op "Save Changes". Je kan meteen testen of het werkt! Deze regel zorgt ervoor dat alle requests naar de front-end die niet naar `/` gaan, als antwoord de `index.html` van de front-end krijgen. [Lees meer over het verschil tussen redirects en rewrites](https://render.com/docs/redirects-rewrites).

![Front-end rewrite](./images/10_18_frontend_rewrite.png ':size=80%')

## Hosting remarks

Dit was maar een (eenvoudig) voorbeeld om je applicatie online te zetten. Onze hoofdbekommernis was bovendien om alles 100% gratis te kunnen regelen, wat niet altijd het eenvoudigst of handigst is.

Hier linten of testen we onze applicatie ook niet voor we deze online zetten. We merken het dus niet op als onze applicatie een bug heeft die door de testen opgevangen zou worden.

Als je ooit echte applicaties online wil zetten, kijk dan eerst eens rond. Er zijn veel opties, en vaak helemaal niet duur meer maar zelden helemaal gratis. Vaak zal de CI/CD pipeline veel meer omvatten dan louter builden en online plaatsen.

Op Render wordt ook de complexiteit van de CI/CD pipeline niet getoond. Je moet slechts een paar veldjes invullen en Render doet alle magie voor jou. Dit is natuurlijk niet realistisch. Als je ooit een echte applicatie online zet, zal je zelf een CI/CD pipeline moeten opzetten. Dit is een hele klus en je zal er veel tijd in moeten steken. Het is echter wel de moeite waard, want het zal je veel tijd besparen in de toekomst.

Denk bij het online zetten van een applicatie ook altijd na over reproduceerbaarheid. Als je een applicatie online zet, moet je ervoor zorgen dat je dit opnieuw kan doen. Dit betekent dat je alles moet documenteren en automatiseren. Als je dit niet doet, zal je in de toekomst veel tijd verliezen. In dit hoofdstuk hebben we alles manueel gedaan, maar in een realistisch project zal je dit automatiseren met bv. [Terraform](https://developer.hashicorp.com/terraform), [Ansible](https://www.ansible.com/) of een andere tool. Zo kan je met één commando de hele infrastructuur opzetten.

## Oefening 1 - README

Pas vervolgens jouw README aan met de nodige commando's... om de applicatie in productie op te starten. Je kan inspiratie opdoen in de README's van de voorbeeldapplicaties.

## Oefening 2 - Optimalisatie TypeScript build back-end

Je zal zien dat onze build van de back-end onze testbestanden en de Jest configuratie bevat. Dit is niet nodig in productie. Pas de `tsconfig.json` aan zodat deze bestanden niet in de build terechtkomen.

- Oplossing +

  Voeg een `exclude` property toe in `tsconfig.json` (of pas deze aan):

  ```json
  {
    "exclude": ["jest.config.ts", "__tests__"]
  }
  ```

> **Eindpunt voorbeeldapplicatie**
>
> De `main` branch bevat de finale versie van de voorbeeldapplicatie voor beide olods.

<iframe src="https://giphy.com/embed/3otPoS81loriI9sO8o" width="480" height="269" frameBorder="0" class="giphy-embed" allowFullScreen></iframe>
