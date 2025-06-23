<!-- markdownlint-disable first-line-h1 -->

## Wat is een API?

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/s7wmiS2mSXY?si=7u14hhoBHVRS5Rqk" frameborder="0" referrerpolicy="no-referrer" allowfullscreen></iframe>

Een **API (Application Programming Interface)** is een software-interface die het mogelijk maakt dat twee applicaties met elkaar kunnen communiceren. Dit in tegenstelling tot een User Interface, die mensen met software laat werken. Ze maken de overdracht van gegevens van systeem naar systeem mogelijk. API’s bieden een gestandaardiseerde toegang tot de applicatiegegevens.

### Voorbeeld van het gebruik van een API

Stel je voor dat je bezig bent met het ontwerp van een klantenbeheersysteem. In dit systeem wil je gegevens zoals klantnamen, adressen en koophistorie bijhouden. Daarnaast moeten verkopers de mogelijkheid hebben om klanten en hun bestellingen toe te voegen, te bewerken en te verwijderen.

Om deze gegevens op te slaan, heb je ervoor gekozen om gebruik te maken van een relationele databank. Om gebruikers in staat te stellen deze gegevens te bekijken en te beheren, overweeg je het gebruik van een webinterface.

Een benadering om dit te realiseren is het ontwikkelen van een monolithische applicatie, die op één server draait en gegevens ophaalt via database queries. Vervolgens worden HTML-pagina's gegenereerd en teruggestuurd naar de webbrowser. Dit is een veelgebruikte methode en zal later in de opleiding ook aan bod komen.

Echter, een alternatieve aanpak is om het systeem op te splitsen in twee afzonderlijke programma's. Eén programma (de **server**) beheert de gegevens en de toegang tot de database, terwijl het andere (de **client**) een webinterface biedt. Je kan deze keuze maken omdat je bv. ook een Android-applicatie wil aanbieden die dezelfde data aanspreekt, en je het servergedeelte wil hergebruiken. Het kan ook handig zijn als verschillende teams aan de ontwikkeling werken, om een zo het principe van "separation of concerns" af te dwingen.

Nu doemt de vraag op: hoe communiceren deze twee programma's met elkaar?

In theorie zou je SQL-query's (vanuit de client) over een netwerk kunnen verzenden en de resultaten kunnen ontvangen, maar al snel zul je inzien dat dit niet de beste aanpak is. Zelfs kleine wijzigingen in het databankschema zouden vereisen dat alle clients volledig herschreven moeten worden.

Daarom is het noodzakelijk om een efficiëntere methode te gebruiken om gegevens (en wijzigingen daarin) over het netwerk te verzenden, en **REST** is een van deze methoden.
