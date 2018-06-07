## CREARE TABELLA PERCORSI PER OGNI CIVICO E PER OGNI SAF CON COST <=400

avviare il seguente script all'interno di una cartella che contiene il **db_cesbamed.sqlite**

```
SELECT InitSpatialMetadata(1);

ATTACH DATABASE "./db_cesbamed.sqlite" AS input;

SELECT CloneTable('input', 'nodes_all', 'nodes_all', 1);

CREATE TEMPORARY TABLE saf AS
SELECT id_nodes FROM nodes_all WHERE length(id_civ_saf) = 3;

CREATE TABLE main.punti_a (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	nodefrom INTEGER NOT NULL, 
	nodeto INTEGER NOT NULL, 
	cost DOUBLE NOT NULL);

SELECT AddGeometryColumn('punti_a', 'geometry', 3045, 'POINT', 'XY');

INSERT INTO main.punti_a
SELECT NULL, nodefrom, nodeto, cost, geometry 
FROM input.r_network_net
WHERE NodeFrom IN (SELECT id_nodes FROM temp.saf) AND Cost <= 400;

CREATE TEMPORARY TABLE civ AS
SELECT p.nodeto 
FROM main.punti_a AS p, main.nodes_all AS n 
WHERE NodeFrom  IN (SELECT id_nodes FROM temp.saf) 
  AND n.id_nodes= p.nodeto AND length(n.id_civ_saf) > 3;

CREATE TABLE main.shortestpath (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	nodefrom INTEGER NOT NULL, 
	nodeto INTEGER NOT NULL, 
	cost DOUBLE NOT NULL);

SELECT AddGeometryColumn('shortestpath', 'geometry', 3045, 'LINESTRING', 'XY');

CREATE TEMPORARY TABLE sp AS
SELECT nodefrom, nodeto, cost, geometry
FROM input.r_network_net
WHERE NodeFrom IN (SELECT id_nodes FROM temp.saf)
AND NodeTo IN (SELECT nodeto FROM temp.civ);

INSERT INTO main.shortestpath
SELECT NULL, nodefrom, nodeto, cost, geometry
FROM temp.sp
WHERE cost < 400 AND geometry IS NOT NULL;

DETACH DATABASE input;

VACUUM;
```

Lo [script](/script/script_shortestpath01.sql), da lanciare come script SQL all'interno di _spatialite_gui_, dopo aver creato il database **shortestpath01.sqlite**:

![short](/img/shortestpath/short001.png 'avvio spatialite_gui')

![short](/img/shortestpath/short002.png 'creo nuovo database')

![short](/img/shortestpath/short003.png 'database creato e aperto in spatialite_gui')

![short](/img/shortestpath/short004.png 'eseguo SQL script')

dopo circa 50 secondi lo script terminerà:

![short](/img/shortestpath/short005.png 'esecuzione SQL script')

se tutto va bene comparirà l'avviso!!!

Controllare il numero di percorsi brevi creati:

![short](/img/shortestpath/short006.png 'verifica numero di shortestpath')

Fatto!!!

Video Youtube (non è pubblico)

[![video youtube](https://img.youtube.com/vi/k4gBkLh8Bf8/0.jpg)](https://youtu.be/k4gBkLh8Bf8 'Shortestpat_01')


[<-- indietro](/tutorial/03_creare_virtual_network.md 'Creare virtual network') -<>- [avanti -->](/tutorial/05_clonare_shortestpath01.md 'Clonare shortestpath01')

[<-- HOME](/README.md 'Home')