--
--
--
CREATE VIEW v_civici_residenti AS
SELECT c.pk_elem,c."codice_asc",c."nome_strad",c."num_civ",r."residenti" AS residenti,n.id_nodes,n.pk_uid as id_nodes_all,c."geom"
FROM "civici_cesbamed" c left join "civici_residenti" r USING (codice_asc)
JOIN nodes_all n ON (n.id_civ_saf = c.codice_asc)
ORDER BY "codice_asc";


INSERT INTO views_geometry_columns
(view_name, view_geometry, view_rowid, f_table_name, f_geometry_column, read_only)
VALUES ('v_civici_residenti', 'geom', 'pk_elem', 'civici_cesbamed', 'geom',1);

CREATE VIEW v_nodeto_civ_servizi_01 as
SELECT t.nodeto,t.id_nodes_all,k.id_civ_saf, t.nro,t.nodefrom_all
FROM
(SELECT "nodeto",n.id_nodes_all, count (*) as nro, group_concat (s.nodefrom) as nodefrom_all
FROM "shortestpath_01" s, nodes n
where s.nodeto = n.pk_uid group by 1,2) t , "nodes_all" k
WHERE t.id_nodes_all = k.pk_uid
order by 4 desc;

CREATE VIEW v_nodefrom_servizi_01_civ as
SELECT t.nodefrom,t.id_nodes_all,k.id_civ_saf,t.nro
FROM
(SELECT "nodefrom",n.id_nodes_all, count(*) as nro
FROM "shortestpath_01" s, nodes n
where s.nodefrom = n.pk_uid
group by 1,2) t , "nodes_all" k
WHERE t.id_nodes_all = k.pk_uid
ORDER BY 3;

CREATE VIEW v_tabella_percorsi_minimi_01 AS
SELECT t1."codice_asc", t1."nome_strad", t1."num_civ", t1."residenti",t1.nodefrom,t1.nodeto,t1.cost,t1.geometry,t2.id_nodes_all,t2.id_civ_saf,t2.nro,t2.nodefrom_all
FROM
(
(SELECT * FROM "v_civici_residenti" JOIN  "nodes_all" ON (codice_asc = id_civ_saf)) t 
JOIN 
(SELECT * FROM "shortestpath_01") k ON (t.id_nodes = k.nodeto) 
) t1
JOIN "v_nodeto_civ_servizi_01" t2 ON (t1.codice_asc=t2.id_civ_saf)
ORDER BY 1;

CREATE VIEW "v_saf_residenti" AS
SELECT sp."nodefrom", count(sp."nodeto"), avg(sp."cost"),nf."id_civ_saf",count(nt."id_civ_saf"), st_union(sp."geometry") as geom,sum(cr.residenti)
FROM "shortestpath_01" sp JOIN "v_nodefrom_servizi_01_civ" nf USING (nodefrom)
JOIN "v_nodeto_civ_servizi_01" nt USING (nodeto) JOIN "v_civici_residenti" cr ON (nt."id_civ_saf" = cr."codice_asc" )
group by 1,4
order by 4;

