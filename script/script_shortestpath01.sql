--
-- the present SQL script is intended to be executed from SpatiaLite_gui
--
-- initializing the output db-file
--
SELECT InitSpatialMetadata(1);

--
-- attaching the input DB-file
--
ATTACH DATABASE "./db_cesbamed.sqlite" AS input;

--
-- cloning the "nodes_all" table
--
SELECT CloneTable('input', 'nodes_all', 'nodes_all', 1);

--
-- creating the "saf" TEMPORARY table
--
CREATE TEMPORARY TABLE saf AS
SELECT id_nodes FROM nodes_all WHERE length(id_civ_saf) = 3;

--
-- creating the "punti_a" output table
--
CREATE TABLE main.punti_a (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	nodefrom INTEGER NOT NULL, 
	nodeto INTEGER NOT NULL, 
	cost DOUBLE NOT NULL);
	
--
-- adding a POINT Geometry to "punti_a"
--
SELECT AddGeometryColumn('punti_a', 'geometry', 3045, 'POINT', 'XY');

--
-- populating "punti_a" NB: <= 400 m
--
INSERT INTO main.punti_a
SELECT NULL, nodefrom, nodeto, cost, geometry 
FROM input.r_network_net
WHERE NodeFrom IN (SELECT id_nodes FROM temp.saf) AND Cost <= 400;

--
-- creating the "civ" TEMPORARY table
--
CREATE TEMPORARY TABLE civ AS
SELECT p.nodeto 
FROM main.punti_a AS p, main.nodes_all AS n 
WHERE NodeFrom  IN (SELECT id_nodes FROM temp.saf) 
  AND n.id_nodes= p.nodeto AND length(n.id_civ_saf) > 3;

--
-- creating the "shortestpath" output table
--
CREATE TABLE main.shortestpath (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	nodefrom INTEGER NOT NULL, 
	nodeto INTEGER NOT NULL, 
	cost DOUBLE NOT NULL);
	
--
-- adding a LINESTRIBG Geometry to "shortestpath"
--
SELECT AddGeometryColumn('shortestpath', 'geometry', 3045, 'LINESTRING', 'XY');
  
--
-- creating the "sp" TEMPORARY table
--
CREATE TEMPORARY TABLE sp AS
SELECT nodefrom, nodeto, cost, geometry
FROM input.r_network_net
WHERE NodeFrom IN (SELECT id_nodes FROM temp.saf)
AND NodeTo IN (SELECT nodeto FROM temp.civ);

--
-- populating "shortestpath"
--
INSERT INTO main.shortestpath
SELECT NULL, nodefrom, nodeto, cost, geometry
FROM temp.sp
WHERE cost < 400 AND geometry IS NOT NULL;

-- detaching the input db-file
--
DETACH DATABASE input;

--
-- vacuuming the output db-file
--
VACUUM;