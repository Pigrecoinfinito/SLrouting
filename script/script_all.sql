-- step2 di: preparare rete per routing - unico vettore nodes_all
SELECT dropgeotable('nodes_all');
CREATE TABLE "nodes_all"
("pk_uid" integer PRIMARY KEY autoincrement NOT NULL,"id_civ_saf" text,id_nodes INTEGER);
--aggiungo colonna geometry
SELECT AddGeometryColumn ('nodes_all','geom',3045,'POINT','XY');
--inserisco i civici
INSERT INTO "nodes_all" ("pk_uid","id_civ_saf","geom")
SELECT NULL ,"codice_asc","geom"
FROM "civici_cesbamed";
--inserisco i saf
INSERT INTO "nodes_all" ("pk_uid","id_civ_saf","geom")
SELECT NULL ,"id","geom"
FROM "servizi_cesbamed_01";

-- step3 di: preparare rete per routing - aggiunge nodi alla rete
SELECT 'Creazione indice spaziale su ', 'nodes_all','geom',
coalesce(checkspatialindex('nodes_all','geom'),CreateSpatialIndex('nodes_all','geom'));

SELECT 'Creazione indice spaziale su ', 'strade','geom',
coalesce(checkspatialindex('strade_cesbamed','geom'),CreateSpatialIndex('strade_cesbamed','geom'));

SELECT dropgeotable('nearest_strade_to_nodes_all');
CREATE TABLE nearest_strade_to_nodes_all as
            SELECT c.pk_uid, c.id_civ_saf, d.distance as dist, d.fid as strade_pk
            FROM nodes_all as c 
        JOIN 
            (SELECT a.fid as fid, a.distance as distance, zz.pk_uid as pk_uid
            FROM knn as a JOIN nodes_all as zz
            WHERE f_table_name = 'strade_cesbamed' 
            AND f_geometry_column = 'geom' 
            AND ref_geometry = zz.geom 
            AND max_items = 1) as d
        ON (d.pk_uid =c.pk_uid ) 
            ORDER BY c.pk_uid;

SELECT addgeometrycolumn('nearest_strade_to_nodes_all','geom',
        (SELECT cast(srid as integer)
        FROM geometry_columns 
        WHERE lower(f_table_name) = lower('strade_cesbamed') 
        AND lower(f_geometry_column) = lower('geom')),'point', 'xy');

UPDATE nearest_strade_to_nodes_all SET geom = 
    (SELECT ST_ClosestPoint(a.geom, b.geom)
    FROM strade_cesbamed as a, nodes_all as b 
    WHERE a.pk_uid=nearest_strade_to_nodes_all.strade_pk 
    AND b.pk_uid=nearest_strade_to_nodes_all.pk_uid);

SELECT 'Creazione indice spaziale su ', 'nearest_strade_to_nodes_all','geom',
coalesce(checkspatialindex('nearest_strade_to_nodes_all','geom'),
CreateSpatialIndex('nearest_strade_to_nodes_all','geom'));

SELECT DropGeoTable('strade_snapped_to_projections_of_nodes_all');
SELECT CloneTable('main', 'strade_cesbamed', 'strade_snapped_to_projections_of_nodes_all', 1,'::cast2multi::geom');

UPDATE strade_snapped_to_projections_of_nodes_all SET geom=
    CastToMulti(
    RemoveRepeatedPoints(
    ST_Snap( 
            strade_snapped_to_projections_of_nodes_all.geom,
            (SELECT CastToMultiPoint(st_collect(b.geom)) 
            FROM nearest_strade_to_nodes_all as b
            WHERE b.strade_pk = strade_snapped_to_projections_of_nodes_all.pk_uid 
            GROUP BY b.strade_pk) , 0.01 
            ), 0.01 
            )
            ) 
WHERE EXISTS(
            SELECT 1 FROM nearest_strade_to_nodes_all as b
            WHERE b.strade_pk = strade_snapped_to_projections_of_nodes_all.pk_uid limit 1
            );

UPDATE strade_snapped_to_projections_of_nodes_all SET geom=
    CastToMulti(
                ST_Split(
                        strade_snapped_to_projections_of_nodes_all.geom,
                        (SELECT CastToMultiPoint(st_collect(b.geom)) 
                        FROM nearest_strade_to_nodes_all as b
                        WHERE b.strade_pk = strade_snapped_to_projections_of_nodes_all.pk_uid 
                        GROUP BY b.strade_pk)
                        )
                )
WHERE EXISTS(
            SELECT 1 FROM nearest_strade_to_nodes_all as b
            WHERE b.strade_pk = strade_snapped_to_projections_of_nodes_all.pk_uid limit 1
            );

SELECT DropGeoTable('lines_split');
SELECT ElementaryGeometries( 'strade_snapped_to_projections_of_nodes_all' ,
                             'geom' , 'lines_split' ,'out_pk' , 'out_multi_id', 1 ) as num, 'lines splitted' as label;
SELECT 'Creazione indice spaziale su ', 'strade','geom',
coalesce(checkspatialindex('lines_split','geom'),CreateSpatialIndex('lines_split','geom'));

SELECT UpdateLayerStatistics('lines_split');
SELECT DropGeoTable('strade_snapped_to_projections_of_nodes_all');
SELECT DropGeoTable('nearest_strade_to_nodes_all');

-- step4 di: preparare rete per routing - crea roads_network
CREATE VIEW "tmp_roads2" AS
SELECT geom,STARTPOINT(geom) AS startp, ENDPOINT(geom) AS endp
FROM "lines_split";

SELECT DropGeoTable('nodes2');
CREATE TABLE nodes2
(pk_uid integer PRIMARY KEY autoincrement, id_nodes_all text);
SELECT AddGeometryColumn ('nodes2','geom',3045,'POINT','XY');

INSERT INTO nodes2 (pk_uid,geom)
SELECT NULL, t.a AS geom 
FROM
(SELECT DISTINCT t1."startp" AS a FROM "tmp_roads2" t1
UNION
SELECT DISTINCT t2."endp" AS a FROM "tmp_roads2" t2) t;

SELECT 'Creazione indice spaziale su ', 'nodes2','geom',
coalesce(checkspatialindex('nodes2','geom'),CreateSpatialIndex('nodes2','geom'));

update nodes_all set id_nodes =
(select fid
from(
select fid, p.pk_uid
FROM knn k, nodes_all p
WHERE k.f_table_name = 'nodes2' 
AND k.ref_geometry = p.geom
AND k.max_items = 1) m
where m.pk_uid = nodes_all.pk_uid);
-- 
CREATE TABLE "lines_split_all"
(pk_uid integer PRIMARY KEY autoincrement,id_civ_saf TEXT);
SELECT AddGeometryColumn ('lines_split_all','geom',3045,'LINESTRING','XY');

INSERT INTO "lines_split_all" (pk_uid,id_civ_saf,geom)
SELECT NULL,NULL,ls.geom
FROM "lines_split" ls;
-- aggiunge tratto di strada tra il civico/saf e la strada
INSERT INTO "lines_split_all" (pk_uid, id_civ_saf, geom)
select NULL,na.id_civ_saf, st_shortestline(na.geom, n.geom) as geom
from nodes2 n, nodes_all na
where n.pk_uid = na.id_nodes;
-- 
CREATE VIEW "tmp_roads" AS
SELECT geom,STARTPOINT(geom) AS startp, ENDPOINT(geom) AS endp
FROM "lines_split_all";

SELECT DropGeoTable('nodes');
CREATE TABLE nodes
(pk_uid integer PRIMARY KEY autoincrement NOT NULL, id_nodes_all text);
SELECT AddGeometryColumn ('nodes','geom',3045,'POINT','XY');

INSERT INTO nodes (pk_uid,geom)
SELECT NULL, t.a AS geom 
FROM
(SELECT DISTINCT t1."startp" AS a FROM "tmp_roads" t1
UNION
SELECT DISTINCT t2."endp" AS a FROM "tmp_roads" t2) t;

SELECT 'Creazione indice spaziale su ', 'nodes','geom',
coalesce(checkspatialindex('nodes','geom'),CreateSpatialIndex('nodes','geom'));

SELECT DropGeoTable('roads_network');
CREATE TABLE "roads_network"
(pk_uid integer PRIMARY KEY autoincrement NOT NULL,"start_id" INTEGER, "end_id" INTEGER);

SELECT AddGeometryColumn ('roads_network','geom',3045,'LINESTRING','XY');

INSERT INTO "roads_network" (pk_uid,"start_id","end_id",geom)
SELECT NULL,s.pk_uid ,e.pk_uid,r.geom
FROM "tmp_roads" r
JOIN "nodes" AS s ON (r.startp = s.geom)
JOIN "nodes" AS e ON (r.endp = e.geom);

DROP VIEW "tmp_roads2";
DROP VIEW "tmp_roads";

update nodes_all set id_nodes =
(select fid
from(
select fid, p.pk_uid
FROM knn k, nodes_all p
WHERE k.f_table_name = 'nodes' 
AND k.ref_geometry = p.geom
AND k.max_items = 1) m
where m.pk_uid = nodes_all.pk_uid);

update nodes set id_nodes_all =
(select nn.pk_uid
from nodes n join nodes_all nn on (nn.id_nodes = n.pk_uid)
where nodes.pk_uid = n.pk_uid);