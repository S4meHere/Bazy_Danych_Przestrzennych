--2. Utwórz pustą bazę danych
CREATE DATABASE spatialdb
--3. Dodaj funkcjonalności PostGIS’a do bazy poleceniem CREATE EXTENSION postgis;
CREATE EXTENSION postgis;
--4. Na podstawie poniższej mapy utwórz trzy tabele: buildings (id, geometry, name),
--   roads (id, geometry, name), poi (id, geometry, name)
CREATE TABLE buildings(building_id SERIAL PRIMARY KEY, geometry GEOMETRY, building_name NAME);
CREATE TABLE roads(road_id SERIAL PRIMARY KEY, geometry GEOMETRY, road_name NAME);
CREATE TABLE poi(poi_id SERIAL PRIMARY KEY, geometry GEOMETRY, poi_name NAME);

-- wypelnianie tabel
INSERT INTO buildings(geometry, building_name) VALUES(ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', 0), 'BuildingA');
INSERT INTO buildings(geometry, building_name) VALUES(ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', 0), 'BuildingB');
INSERT INTO buildings(geometry, building_name) VALUES(ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', 0), 'BuildingC');
INSERT INTO buildings(geometry, building_name) VALUES(ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', 0), 'BuildingD');
INSERT INTO buildings(geometry, building_name) VALUES(ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', 0), 'BuildingF'); 

INSERT INTO roads(geometry, road_name) VALUES(ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)', 0), 'RoadX');
INSERT INTO roads(geometry, road_name) VALUES(ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)', 0), 'RoadY');

INSERT INTO poi(geometry, poi_name) VALUES(ST_GeomFromText('POINT(1 3.5)', 0), 'G');
INSERT INTO poi(geometry, poi_name) VALUES(ST_GeomFromText('POINT(5.5 1.5)', 0), 'H');
INSERT INTO poi(geometry, poi_name) VALUES(ST_GeomFromText('POINT(9.5 6)', 0), 'I');
INSERT INTO poi(geometry, poi_name) VALUES(ST_GeomFromText('POINT(6.5 6)', 0), 'J');
INSERT INTO poi(geometry, poi_name) VALUES(ST_GeomFromText('POINT(6 9.5)', 0), 'K');

-- Zapytania

--a. Wyznacz całkowitą długość dróg w analizowanym mieście. 

SELECT SUM(ST_Length(geometry)) FROM roads;

--b. Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego budynek o nazwie BuildingA. 

SELECT ST_GeometryType(geometry), ST_Area(geometry), ST_Perimeter(geometry) FROM buildings WHERE building_name = 'BuildingA';

--c. Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki posortuj alfabetycznie.  

SELECT building_name, ST_Area(geometry) FROM buildings ORDER BY building_name;

--d. Wypisz nazwy i obwody 2 budynków o największej powierzchni.  

SELECT building_name, ST_Perimeter(geometry) FROM buildings ORDER BY ST_Perimeter(geometry) DESC LIMIT 2;

--e. Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G.  

SELECT ST_Distance(buildings.geometry, poi.geometry) FROM buildings, poi
WHERE buildings.building_name = 'BuildingC' AND poi.poi_name = 'G';

--f. Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w odległości większej niż 0.5 od budynku BuildingB. 

SELECT ST_Area(ST_Difference(C.geometry, ST_Buffer(B.geometry, 0.5) )) FROM buildings B, buildings C
WHERE B.building_name = 'BuildingB' AND C.building_name = 'BuildingC'

--g. Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi o nazwie RoadX.  

SELECT building_name FROM buildings
WHERE ST_Y(ST_Centroid(buildings.geometry)) > ST_Y(ST_PointN((SELECT geometry FROM roads WHERE road_name = 'RoadX'), 1));

--h. Oblicz pole powierzchni tych części budynku BuildingC i poligonu o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7),
--   które nie są wspólne dla tych dwóch obiektów.

SELECT ST_Area(ST_SymDifference(buildings.geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 0))) FROM buildings
WHERE building_name = 'BuildingC'