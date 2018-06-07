<!-- TOC -->

- [SpatiaLite routing](#spatialite-routing)
- [Nozioni basilari sulle reti](#nozioni-basilari-sulle-reti)
- [Fonti dati OSM](#fonti-dati-osm)
- [Creazione database SpatiaLite e importazione dati](#creazione-database-spatialite-e-importazione-dati)
- [Preparazione rete per routing](#preparazione-rete-per-routing)
- [Creare virtual network](#creare-virtual-network)
- [Creare shortestpath01](#creare-shortestpath01)
- [Clonare virtual network](#clonare-virtual-network)
- [Estrarre i dati](#estrarre-i-dati)
- [Descrizione database](#descrizione-database)
- [Ricerca errori](#ricerca-errori)
- [video](#video)

<!-- /TOC -->

## SpatiaLite routing
[estratto dal CookBook italiano di Alessandro Furieri pp.129](http://www.gaia-gis.it/spatialite-3.0.0-BETA/SpatiaLite-Cookbook_ITA.pdf)

SpatiaLite gestisce un modulo di “routing” denominato VirtualNetwork (rete virtuale). Lavorando su una
rete arbitraria questo modulo consente di identificare le connessioni di percorso minimo (shortest path) con
una semplice interrogazione SQL.
Il modulo VirtualNetwork si appoggia su algoritmi sofisticati ed altamente ottimizzati, così è veramente
veloce ed efficiente anche nel caso di reti di grande dimensione.

## Nozioni basilari sulle reti
Non potete presumere che qualsiasi generica mappa di strade corrisponda ad una rete. Una vera rete deve
soddisfare parecchi requisiti specifici, ad es. deve essere un grafo.
La teoria dei Grafi è un'ampia e complessa area della matematica; se siete interessati a ciò, qui potete trovare
ulteriori dettagli:
* [Teoria Dei Grafi (Graph Theory)](https://en.wikipedia.org/wiki/Graph_theory)
* [Problema del Percorso Minimo (Shortest Path Problem)](https://en.wikipedia.org/wiki/Shortest_path_problem)
* [Algoritmo di Dijkstra (Dijkstra's Algorithm)](https://en.wikipedia.org/wiki/Dijkstra's_algorithm)
* [Algoritmo A* (A* Algorithm)](https://en.wikipedia.org/wiki/A*_search_algorithm)

![grafo](/img/grafo01.png)

image by A. Furieri

Spiegato in poche parole:
* una rete è un insieme di **archi**
* ogni arco connette due **nodi**
* ogni arco ha una **direzione** univoca: ad es. l'arco dal nodo A al nodo B non è necessariamente lo stesso
dell'arco che va dal nodo B al nodo A;
* ogni arco ha un “**costo**” conosciuto (ad es. lunghezza, tempo di percorrenza, capacità, ....)
* archi e nodi devono essere **univocamente identificati** da etichette
* la geometria del grafo (archi e nodi) deve soddisfare una **forte coerenza topologica**.
Partendo da una **rete** (o **grafo**) sia l'algoritmo di **Dijkstra** che l'algoritmo **A*** possono individuare il **percorso
minimo** (connessione con il minimo costo) che connette ogni coppia arbitraria di punti.

## Fonti dati OSM

Vi sono parecchie fonti che distribuiscono dati di tipo rete. Una delle più note e largamente usate è **`OSM`**
[Open Street Map], un archivio di dimensione planetaria _completamente libero._ Vi sono parecchi siti dove
scaricare OSM; tanto per citarne qualcuno:
* [http://www.openstreetmap.org/](https://www.openstreetmap.org)
* [http://download.geofabrik.de/osm/](http://download.geofabrik.de/)
* [http://downloads.cloudmade.com/](http://downloads.cloudmade.com/)
* [Sub-regions Italia](http://download.geofabrik.de/europe/italy.html)

![grafo](/img/sub-region-italy.png "osm")

----
![grafo](/img/licenza.jpg)

----
## Creazione database SpatiaLite e importazione dati

![grafo](/img/import_dati/import001.png 'spatialite_gui 2.1')

[vai alla sezione -->](/tutorial/01_import_dati.md)

## Preparazione rete per routing

![avvio](/img/import_dati/import021.png 'spatialite_gui') 

[vai alla sezione -->](/tutorial/02_preparare-rete-per-routing.md)

## Creare virtual network

![grafo](/img/virtualNetwork/virtualN001.png 'spatialite_gui')

[vai alla sezione -->](/tutorial/03_creare_virtual_network.md)

## Creare shortestpath01

![short](/img/shortestpath/short001.png 'avvio spatialite_gui')

[vai alla sezione -->](/tutorial/04_creare_shortestpath01.md)

## Clonare virtual network

![short](/img/shortestpath/short_01_004.png 'clonare tabella - ESEGUI!!! -->')

[vai alla sezione -->](/tutorial/05_clonare_shortestpath01.md)

## Estrarre i dati

![tab_fin](/img/tabelle_finali/tab_fin001.png 'vista: v_tabella_percorsi_minimi_01')

[vai alla sezione -->](/tutorial/06_create_tabelle_output.md)

## Descrizione database

![desc](/img/descrizione_db/desc_db.png)

[vai alla sezione -->](/tutorial/07_descrizione_database.md)

## Ricerca errori

[vai alla sezione -->](/tutorial/08_ricerca_errori.md)

## video

[![video youtube](https://img.youtube.com/vi/HKUNDusUcUY/0.jpg)](https://youtu.be/HKUNDusUcUY 'Import dati')

[![video youtube](https://img.youtube.com/vi/k4gBkLh8Bf8/0.jpg)](https://youtu.be/k4gBkLh8Bf8 'Shortestpat_01')





