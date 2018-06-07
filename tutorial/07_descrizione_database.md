## Descrizione database

![desc](/img/descrizione_db/desc_db.png)

Lo screenshot rappresenta la situazione finale del database dopo aver inserito i dati ee eseguiti tutti gli script e tutte le analisi:

nel db troviamo:

- 4 tabelle che rappresentano i dati iniziali (1,2,3,4);
    - **civici_cesbamed** : rappresentano i civici, tabella con geometria;
    - **civici_residenti** : rappresenta una semplice tabella dei civici con numero di residenti;
    - **servizi_cesbamed_01** : rappresenta le fermate saf;
    - **strade_cesbamend** : tabella con geometria che rappresenta lo stradario;

- **lines_split** : rappresenta le strade divise secondo la tabella nodes_all;
- **lines_split_all** : rappresenta le strade divise secondo la tabella nodes_all e con aggiunta del tratto iniziale;
- **nodes** : rappresenta tutti i nodi delle rete stradale compreso i punti della tabella nodes_all;
- **nodes**2 : rappresenta tutti i nodi delle rete stradale tranne i punti della tabella nodes_all;
- **nodes_all** : rappresenta l'unione delle tabelle _civici_cesbamed_ e _servizi_cesbamed_01_;

- **r_network_net** : tabella virtuale per il routing; (non toccare)
- **r_network_net_data** : tabella per il routing; (non toccare)

- **road_network** : tabella che rappresenta la rete stradale e necessaria per creare le due tabelle di sopra; (non toccare)

- **shortestpath_01** : tabella che contiene tutti i percorsi brevi, proviene da altra tabella (vedi [creare_shortestpath01](04_creare_shortestpath01.md))

- 5 viste di analisi:
    - **civici_residenti**: vista che mette assieme le due tabelle civici_cesbamed e civici_residenti;
    - **v_nodefrom_servizi_01_civ** : vedi [create_tabelle_output](06_create_tabelle_output.md)
    - **v_nodeto_civ_servizi_01** : vedi [create_tabelle_output](06_create_tabelle_output.md)
    - **v_saf_residenti** : vedi [create_tabelle_output](06_create_tabelle_output.md)
    - **v_tabella_percorsi_minimi_01** : vedi [create_tabelle_output](06_create_tabelle_output.md)


PS: Le viste (view) sono delle tabelle, in memoria, che dipendono da altre tabelle fisiche, quindi sono tabelle dinamiche che si aggiornano automaticamente (per convenzione iniziano con una v_.

NB: SRID per tutte le tabelle con geometria è 3045


[<-- indietro](/tutorial/07_descrizione_database.md 'Descrizione database') -<>- [avanti -->](/tutorial/08_ricerca_errori.md 'Ricerca errori')

[<-- HOME](/README.md 'Home')