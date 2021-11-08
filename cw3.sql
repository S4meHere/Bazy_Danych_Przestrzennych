CREATE DATABASE cw4db;
CREATE EXTENSION postgis;

--1. Podaj pole powierzchni wszystkich lasów o charakterze mieszanym.

SELECT SUM(area_km2) FROM trees WHERE vegdesc = 'Mixed Trees';

SELECT * FROM trees;

--3. Oblicz długość linii kolejowych dla regionu Matanuska-Susitna.

--SELECT * FROM railroads;
--SELECT * FROM regions WHERE name_2 = 'Matanuska-Susitna';

--SELECT SUM(ST_Length(geom)) FROM railroads;

SELECT SUM(ST_Length(railroads.geom)) FROM railroads, regions m
WHERE ST_Within(railroads.geom, m.geom) and m.name_2 ='Matanuska-Susitna';

--4. Oblicz, na jakiej średniej wysokości nad poziomem morza położone są lotniska o charakterze
--militarnym. Ile jest takich lotnisk? Usuń z warstwy airports lotniska o charakterze militarnym,
--które są dodatkowo położone powyżej 1400 m n.p.m. Ile było takich lotnisk?

SELECT * FROM airports;

SELECT AVG(elev) FROM airports
WHERE use='Military';

SELECT COUNT(gid) FROM airports
WHERE use='Military';

SELECT * FROM airports
WHERE use='Military' AND elev > 1400;

--5. Utwórz warstwę, na której znajdować się będą jedynie budynki położone w regionie Bristol Bay
--(wykorzystaj warstwę popp). Podaj liczbę budynków. Na warstwie zostaw tylko te budynki, które są
--położone nie dalej niż 100 km od rzek (rivers). Ile jest takich budynków?

SELECT * FROM popp;

SELECT popp.* FROM popp, regions b
WHERE ST_Within(popp.geom, b.geom) and b.name_2 ='Bristol Bay';

SELECT COUNT(popp.*) FROM popp, regions b
WHERE ST_Within(popp.geom, b.geom) and b.name_2 ='Bristol Bay';

--6. Sprawdź w ilu miejscach przecinają się rzeki (majrivers) z liniami kolejowymi (railroads).

SELECT COUNT((XD.dpoints).geom) 
FROM (SELECT ST_DumpPoints(ST_Intersection(majrivers.geom, railroads.geom)) AS dpoints 
	  FROM majrivers, railroads
	  WHERE ST_Intersects(majrivers.geom, railroads.geom) = 'TRUE') AS XD;

--7. Wydobądź węzły dla warstwy railroads. Ile jest takich węzłów?

--SELECT COUNT(ST_Intersects(railroads.geom)) FROM railroads;

--8. Wyszukaj najlepsze lokalizacje do budowy hotelu. Hotel powinien być oddalony od lotniska nie
--więcej niż 100 km i nie mniej niż 50 km od linii kolejowych. Powinien leżeć także w pobliżu sieci
--drogowej.
SELECT ST_Intersection(ST_Intersection(ST_Buffer(airports.geom,300000),ST_Buffer(railroads.geom,150000)),regions.geom)
FROM airports, railroads, regions;

