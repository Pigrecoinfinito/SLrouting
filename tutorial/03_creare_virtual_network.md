# Come creare la roads_network per analisi di routing (civici,saf) parte 2

## CREARE LA BUILD NETWORK TRAMITE GUI o BASH

### USANDO la GUI (spatialite_gui)

### Costruire la virtual network

![grafo](/img/virtualNetwork/virtualN001.png 'Build Network')

![grafo](/img/virtualNetwork/virtualN002.png 'Build Network - configurazione')

**NB**: di default i punti 8 e 9 si presentano come in figura, ma occorre modificarli lasciando solo la r al posto di roads: **r_network_net_data** e **r_network_net**; modifica indispensabile altrimenti gli script non troveranno le tabelle.

**OSSERVAZIONI**: se la rete stradale di partenza è corretta topologicamente e la roads_network è stata creata correttamente non ci dovrebbero essere problemi a creare la build network tramite GUI. Solo in caso di errore è quasi indispensabile usare la CLI in quanto individua l'errore e suggerisce la correzione.

![grafo](/img/virtualNetwork/virtualN003.png 'Build Network creata con successo!!!')


## USANDO BASH

questa procedura è consigliata in quanto, in caso di errori, segnala il tipo di errore e come correggerlo.

`spatialite_network -d db_cesbamed.sqlite -T roads_network -f start_id -t end_id -g geom --bidirectional --output-table r_network_data --virtual-table r_network_net`

![grafo](/img/virtualNetwork/virtualN009.png 'Schermata bash in Windows 10')

per entrambe le procedure, il risultato è visibile in spatialite_gui: aggiunta di una tabella e di una view

![grafo](/img/virtualNetwork/virtualN004.png 'Tabelle database')

## Query di selezione routing

```
SELECT *
FROM roads_network_net
WHERE NodeFrom = 1 AND NodeTo = 200
limit 1;
```

![grafo](/img/virtualNetwork/virtualN005.png 'Query di selezione routing -path')

oppure:
```
SELECT *
FROM roads_network_net
WHERE NodeFrom = 1 AND Cost <=400;
```

![grafo](/img/virtualNetwork/virtualN006.png 'Query di selezione - cost')

E finalmente possiamo fare la prima interrogazione di navigazione (query routing):
* definire semplicemente la clausola WHERE NodeFrom = ... AND NodeTo = ...
* il risultato rappresenterà la soluzione di percorso minimo
* la prima riga del risultato (limit 1) sintetizza l'intero percorso e contiene la corrispondente geometria;
* le altre righe rappresentano i singoli archi da percorrere, nel giusto ordine, per andare dall'origine alla
destinazione.

Visualizziamo il percorso più breve in [QGIS](https://qgis.org/it/site/):

**percorso più breve tra il nodo 1 e il 200:**
![grafo](/img/virtualNetwork/virtualN007.png 'Esempio - shortpath')

**punti distanti <=400 m dal punto 340**
![grafo](/img/virtualNetwork/virtualN008.png 'esempio punti entro 400 m da un saf') 


[<-- indietro](/tutorial/02_preparare_rete_per_routing.md 'preparare rete per routing') -<>- [avanti -->](/tutorial/04_creare_shortestpath01.md 'Creare shortestpath01')

[<-- HOME](/README.md 'Home')