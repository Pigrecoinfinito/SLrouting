## Ricerca errori sui dati di input

### ricerca duplicati **codice_asc**

* civici_cesbamed

```
SELECT Count(*) AS "[dupl-count]", codice_asc
FROM "civici_cesbamed"
GROUP BY codice_asc
HAVING "[dupl-count]" > 1
ORDER BY "[dupl-count]" DESC
```

* civici-residenti-eta

```
SELECT Count(*) AS "[dupl-count]", codice_asc
FROM "civici-residenti-eta"
GROUP BY codice_asc
HAVING "[dupl-count]" > 1
ORDER BY "[dupl-count]" DESC
```

[<-- HOME](/README.md 'Home')