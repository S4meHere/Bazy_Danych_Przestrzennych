-- 4. Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty) 
-- położonych w odległości mniejszej niż 1000 m od głównych rzek.
-- Budynki spełniające to kryterium zapisz do osobnej tabeli tableB.

--SELECT * FROM popp;

SELECT DISTINCT P.* INTO tableB
FROM majrivers R, popp P
WHERE  ST_DWithin(P.geom, R.geom, 1000) AND P.f_codedesc = 'Building';

SELECT COUNT(*)
FROM tableB;

--SELECT * FROM tableB ORDER BY gid;

-- 5. Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk,
-- ich geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.

--SELECT * FROM airports;

SELECT name, geom, elev
INTO airportsNew
FROM airports;

-- a) Znajdź lotnisko, które położone jest najbardziej na zachód i najbardziej na wschód

-- zachód
SELECT name 
FROM airportsNew
ORDER BY ST_X(geom) LIMIT 1;

-- wschód
SELECT name geom
FROM airportsNew
ORDER BY ST_X(geom) DESC LIMIT 1;

-- b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie środkowym drogi pomiędzy lotniskami znalezionymi w punkcie a. 
-- Lotnisko nazwij airportB. Wysokość n.p.m. przyjmij dowolną.

INSERT INTO airportsNew 
VALUES ('airportB', (SELECT ST_Centroid (ST_MakeLine(
	(SELECT geom FROM airportsNew WHERE name = 'ATKA'),
	(SELECT geom FROM airportsNew WHERE name = 'ANNETTE ISLAND')))),0);

-- 6. Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej 
-- linii łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”

-- SELECT * FROM lakes;
SELECT ST_Area(ST_Buffer(ST_ShortestLine(A.geom,B.geom),1000))
FROM lakes A, airports B
WHERE A.names = 'Iliamna Lake' and B.name = 'AMBLER';

-- 7. Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów
-- reprezentujących poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps).

--SELECT * FROM trees;

SELECT SUM(ST_Area(tree.geom)), tree.vegdesc
FROM trees tree, swamp sw, tundra tun
WHERE ST_Contains(tree.geom, sw.geom) OR ST_Contains(tree.geom, tun.geom)
GROUP BY tree.vegdesc;

