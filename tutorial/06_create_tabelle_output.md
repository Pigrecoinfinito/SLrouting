## Creare ed esportare tabella percorsi

### Creo una vista unica tra _civici_cesbamed_ e _civici-residenti_

```
CREATE VIEW v_civici_residenti AS
SELECT c.pk_elem,c."codice_asc",c."nome_strad",c."num_civ",r."residenti" AS residenti,n.id_nodes,n.pk_uid as id_nodes_all,c."geom"
FROM "civici_cesbamed" c left join "civici_residenti" r USING (codice_asc)
JOIN nodes_all n ON (n.id_civ_saf = c.codice_asc)
ORDER BY "codice_asc"
--
-- registro geometria
--
INSERT INTO views_geometry_columns
(view_name, view_geometry, view_rowid, f_table_name, f_geometry_column, read_only)
VALUES ('v_civici_residenti', 'geom', 'pk_elem', 'civici_cesbamed', 'geom',1);
```

Creo una vista **v_nodeto_civ_servizi_01** 
```
CREATE VIEW v_nodeto_civ_servizi_01 as
SELECT k.id_civ_saf,t.nodeto,t.id_nodes_all,t.nro,t.nodefrom_all
FROM
(SELECT "nodeto",n.id_nodes_all, count (*) as nro, group_concat (s.nodefrom) as nodefrom_all
FROM "shortestpath_01" s, nodes n
where s.nodeto = n.pk_uid group by 1,2) t , "nodes_all" k
WHERE t.id_nodes_all = k.pk_uid
order by 4 desc
```
![tab_fin](/img/tabelle_finali/tab_fin002.png 'vista: v_nodeto_civ_servizio_01')

id_civ_saf|nodeto|id_nodes_all|nro|nodefrom_all
----------|------|------------|---|------
0000241000082|132|67|10|372,762,784,918,1044,1198,1352,1478,1583,1939
0000241000080|1452|23|10|372,762,784,918,1044,1198,1352,1478,1583,1939
0000652500005|25|650|9|372,784,918,1044,1105,1198,1352,1478,1583
0000096500003|210|544|9|372,784,918,1044,1198,1352,1478,1583,1939
0000096500001|424|588|9|372,784,918,1044,1198,1352,1478,1583,1939
0000652500004|94|279|8|372,784,918,1044,1198,1352,1478,1583
0000241000090|299|388|8|372,784,918,1044,1198,1352,1478,1583
0000330500010|447|559|8|372,784,918,1044,1198,1352,1478,1583
0000330500018|595|45|8|372,784,918,1044,1198,1352,1478,1583

descrizione colonne:

**id_civ_saf**: identificativo civico saf, proviene dalla tabella nodes_all; può rappresentare l'identificativo del civico (codice_asc) oppure del servizio_01 (SAF) dipende dal contesto;

**nodeto**: è il numero che identifica, nella road network, il nodo di arrivo, in generale sono sempre i civici;

**id_nodes_all**: identificativo della tabella nodes_all (pk_uid);

**nro**: numero di percorsi brevi con punto di partenza il civico relativo in tabella;

**nodefrom_all**: è il numero che identifica, nella road network, il nodo di partenza, in generale sono sempre i servizi_01 (saf); in questo caso rappresenta la lista delle fermate raggiunte, percorrendo <= 400 m, partendo dal civico relativo in tabella;

**esempio**: la prima riga, codice_asc  0000241000082, nella road network è rappresentato dal numero 132, nella tabella nodes_all è rappresentato dal numero 67, sono 10 i percorsi <= 400 m che partono dal civico e raggiungono 10 fermate diverse il cui numero è nella lista;

```
CREATE VIEW v_nodefrom_servizi_01_civ as
SELECT t.nodefrom,t.id_nodes_all,k.id_civ_saf,t.nro
FROM
(SELECT "nodefrom",n.id_nodes_all, count(*) as nro
FROM "shortestpath_01" s, nodes n
where s.nodefrom = n.pk_uid
group by 1,2) t , "nodes_all" k
WHERE t.id_nodes_all = k.pk_uid
ORDER BY 3
```
![tab_fin](/img/tabelle_finali/tab_fin003.png 'vista: v_nodefrom_servizio_01_civ')

nodefrom|id_nodes_all|id_civ_saf|nro
--------|------------|----------|--
464|654|101|74
1733|655|102|157
976|660|107|1
759|661|108|1
550|662|109|28
79|663|110|27
1789|664|111|42
1721|665|112|49
1105|666|113|66
992|667|114|54
784|668|115|120
1198|669|116|122
1478|670|117|109
1352|671|118|86
762|672|119|59
1939|673|120|59
1044|674|121|77
372|675|122|68
918|676|123|133
1583|677|124|130
250|678|125|4
1460|679|126|2
1699|680|127|1
585|681|128|1

Il numero di righe di questa vista rappresenta il numero di servizi_01 (saf) raggiunti entro 400 m dai civici; per ogni riga il campo nro rappresenta il numero di percorsi;

nel nostro caso (criterio <= 400 m) su 30 servizi_01 solo 24 vengono raggiunti; mentre il servizio_01 con id = 101 è raggiunto da 74 civici; 
```
CREATE VIEW v_tabella_percorsi_minimi_01 AS
SELECT t1."codice_asc", t1."nome_strad", t1."num_civ", t1."residenti",t1.nodefrom,t1.nodeto,t1.cost,t1.geometry,t2.id_nodes_all,t2.id_civ_saf,t2.nro,t2.nodefrom_all
FROM
(
(SELECT * FROM "v_civici_residenti" JOIN  "nodes_all" ON (codice_asc = id_civ_saf)) t 
JOIN 
(SELECT * FROM "shortestpath_01") k ON (t.id_nodes = k.nodeto) 
) t1
JOIN "v_nodeto_civ_servizi_01" t2 ON (t1.codice_asc=t2.id_civ_saf)
ORDER BY 1
```
![tab_fin](/img/tabelle_finali/tab_fin001.png 'vista: v_tabella_percorsi_minimi_01')

codice_asc|nome_strad|num_civ|residenti|nodefrom|nodeto|cost|geometry|id_nodes_all|id_civ_saf|nro|nodefrom_all
----------|----------|-------|---------|--------|------|----|--------|------------|----------|---|-------
0000004500001|AFRO|1|155|372|2021|388.692321||235|0000004500001|8|"372,784,992,1044,1105|1198,1352,1478"
0000004500001|AFRO|1|155|784|2021|108.238121||235|0000004500001|8|"372,784,992,1044,1105|1198,1352,1478"
0000004500001|AFRO|1|155|992|2021|281.427047||235|0000004500001|8|"372,784,992,1044,1105|1198,1352,1478"
0000004500001|AFRO|1|155|1044|2021|356.921822||235|0000004500001|8|"372,784,992,1044,1105|1198,1352,1478"
0000004500001|AFRO|1|155|1105|2021|241.935078||235|0000004500001|8|"372,784,992,1044,1105|1198,1352,1478"
0000004500001|AFRO|1|155|1198|2021|119.795278||235|0000004500001|8|"372,784,992,1044,1105|1198,1352,1478"
0000004500001|AFRO|1|155|1352|2021|310.593560||235|0000004500001|8|"372,784,992,1044,1105|1198,1352,1478"
0000004500001|AFRO|1|155|1478|2021|260.506202||235|0000004500001|8|"372,784,992,1044,1105|1198,1352,1478"
0000057500001|ANGELO BERETTA|1||784|711|265.852814||371|0000057500001|2|"784,1198"
0000057500001|ANGELO BERETTA|1||1198|711|233.667337||371|0000057500001|2|"784,1198"

La tabella contiene, per ogni civico (ogni riga), il percorso più breve (<=400 m), inoltre, il civico è presente tante volte quante sono i servizi che lo raggiungono; es: 
il civico con codice_asc 0000004500001 è presente 8 volte nella tabella perché raggiunta da 8 saf diversi, tutti entro 400 m. La vista è in join con la vista **v_nodeto_civ_servizi_01**.


```
CREATE VIEW "v_saf_residenti" AS
SELECT sp."nodefrom", count(sp."nodeto"), avg(sp."cost"),nf."id_civ_saf",count(nt."id_civ_saf"), st_union(sp."geometry") as geom,sum(cr.residenti)
FROM "shortestpath_01" sp JOIN "v_nodefrom_servizi_01_civ" nf USING (nodefrom)
JOIN "v_nodeto_civ_servizi_01" nt USING (nodeto) JOIN "v_civici_residenti" cr ON (nt."id_civ_saf" = cr."codice_asc" )
group by 1,4
order by 4
```
SAF|nodefrom|nro civici|media cost|residenti TOT
---|--------|----------|----------|---------
101|464|74|283.963602|346
102|1733|157|246.694078|354
107|976|1|338.857390|
108|759|1|359.043027|
109|550|28|351.208786|726
110|79|27|345.822611|723
111|1789|42|300.631110|1362
112|1721|49|313.857079|1373
113|1105|66|312.197718|1462
114|992|54|302.597460|1445
115|784|120|247.977054|1241
116|1198|122|260.096545|1265
117|1478|109|304.664896|1300
118|1352|86|283.691522|1185
119|762|59|241.981621|306
120|1939|59|248.813611|330
121|1044|77|262.643088|1190
122|372|68|244.643052|1276
123|918|133|262.410702|1755
124|1583|130|267.641868|1708
125|250|4|336.838320|19
126|1460|2|387.053068|3
127|1699|1|286.041681|
128|585|1|303.004442|

La vista rappresenta le 24 fermate con media lunghezza percorso e numero di residenti raggiunti.


## Esportare in CSV

Selezionare la tabella e poi tasto destro del mouse | Esporta in CSV

![tab_fin](/img/tabelle_finali/tab_fin004.png 'Esportare in CSV')

[<-- indietro](/tutorial/05_clonare_shortestpath01.md 'Clonare shortestpath01') -<>- [avanti -->](/tutorial/07_descrizione_database.md 'Descrizione database')

[<-- HOME](/README.md 'Home')