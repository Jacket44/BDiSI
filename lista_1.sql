-- Intro, import bazy

--  Trochę bajzel, archiwum bezpośrednio z linku ma w środku dziwne rzeczy, więc zaimportowałem plik Chinook_MySql.sql z githuba projektu

CREATE DATABASE Chinook;
mysql -u rppt -p Chinook < Chinook_MySql.sql

-- Nowy user z uprawnieniami do bazy

CREATE USER 'jkt44'@'localhost' IDENTIFIED BY 'dupa123';
GRANT ALL PRIVILEGES ON Chinook . * TO 'jkt44'@'localhost';

USE Chinook;

/*
    

    Początek listy zadań


*/

-- 1. Wypisz wszystkie znajdujące się w bazie tabele.

SHOW TABLES;

-- 2. Sprawdź schemat (liczbę, nazwę i typ kolumn) tabeli track.

DESCRIBE Track;

-- 3. Dla każdego zespołu wypisz wszystkie pary (nazwa zespołu, tytuł albumu).

    SELECT Artist.Name, Album.Title
    FROM Album
        INNER JOIN Artist ON Album.ArtistId = Artist.ArtistId;

-- 4. Wypisz wszystkie albumy ’Various Artists’.

    SELECT Artist.Name, Album.Title
    FROM Album
        INNER JOIN Artist ON Album.ArtistId = Artist.ArtistId
    WHERE Artist.Name = 'Various Artists';

-- 5. Wypisz wszystkie pliki audio trwające powyżej 250 000 milisekund.

    SELECT *
    FROM Track
    WHERE Milliseconds > 250000;

-- 6. Wypisz wszystkie utwory trwające pomiędzy 152 000 ms a 2 583 000 ms.

    SELECT *
    FROM Track
    WHERE Milliseconds BETWEEN 152000 AND 2583000;

-- 7. Wypisz zawartość playlisty90’s Music. Schemat wyjściowy powinien zawierać jedynie nazwę utworu, nazwę albumu, nazwę zespołu oraz rodzaj muzyki.

    SELECT T.Name AS Track, A.Title AS Album, ART.Name AS Artist, G.Name AS Genre
    FROM Playlist AS P 
        INNER JOIN PlaylistTrack AS PT ON P.PlaylistId = PT.PlaylistId
        INNER JOIN Track  AS T   ON PT.TrackId = T.TrackId
        INNER JOIN Album  AS A   ON T.AlbumId = A.AlbumId
        INNER JOIN Artist AS ART ON A.ArtistId = ART.ArtistId
        INNER JOIN Genre  AS G   ON T.GenreId = G.GenreId
    WHERE P.Name = "90’s Music" 

-- 8. Z tabeli customer wybierz imiona i nazwiska wszystkich klientów z Niemiec.

    SELECT FirstName, LastName
    FROM Customer 
    WHERE Country = "Germany";

-- 9. Wypisz miasta oraz kraje, w których mieszkają klienci o znanym kodzie pocztowym.

    SELECT DISTINCT City, Country
    FROM Customer
    WHERE PostalCode IS NOT NULL;

-- 10. Dla każdego artysty wypisz liczbę oferowanych przez sklep albumów. Dane wynikowe powinny mieć format (nazwa zespołu,liczba albumów).

    SELECT Artist.Name, COUNT(Album.AlbumId)
    FROM Artist
        LEFT JOIN Album ON Album.ArtistId = Artist.ArtistId
    GROUP BY Artist.ArtistId;

-- 11. Na podstawie wystawionych faktur, znajdź miasto, z którego łącznie zamówiono najdroższe produkty.

    SELECT I.BillingCity, SUM((IL.UnitPrice * IL.Quantity)) AS TotalPrice -- Debug, domyślnie zostaje tylko miasto
    FROM Invoice AS I
        INNER JOIN InvoiceLine AS IL ON I.InvoiceId = IL.InvoiceId
    GROUP BY I.BillingCity
    ORDER BY TotalPrice DESC LIMIT 1;

    -- To na górze jest zrobione bez sensu, bo Total wylicza już koszt każdej faktury, ale zostawię, bo w sumie śmieszne

    SELECT BillingCity
    FROM Invoice
    GROUP BY BillingCity
    ORDER BY SUM(Total) DESC
    LIMIT 1;

-- 12. Na podstawie wystawionych faktur, wypisz dla każdego kraju wartość średniej wystawionej faktury.

    SELECT BillingCity, AVG(Total) AS AvgTotal
    FROM Invoice
    GROUP BY BillingCity;

-- 13. Na podstawie tabel customer i employee, wypisz tych pracowników, którzy nieodpowiadają aktualnie za obsługę klientów.

    SELECT FirstName, LastName
    FROM Employee
    WHERE EmployeeId NOT IN (SELECT SupportRepId FROM Customer);

-- 14. Wypisz wszystkich pracowników, którzy nie obsługują żadnego klienta ze swojego miasta.

    SELECT FirstName, LastName
    FROM Employee
    WHERE EmployeeId NOT IN (SELECT C.City, E.City
                             FROM Customer AS C
                                INNER JOIN Employee AS E ON C.SupportRepId = E.EmployeeId
                             WHERE C.City = E.City;);

    -- Sprawdziłem ręcznie, nie ma takich pracowników, którzy obsługują kogoś ze swojego miasta
    -- TODO:Wprowadzić takiego typa ręcznie i sprawdzić, czy query działa.

--  2:15, spanie

-- 15. Na podstawie tabel track, artist oraz album, wyświetl informacje o najdroższych albumach.
--     Schemat wynikowy powinien zawierać nazwę zespołu, tytuł albumu, liczbę utworów oraz łączną cenę.

        -- (Tu nie jestem pewien, co się dzieje w bazie. Istnieje na przykład album "The Best of Beethoven" z tylko jednym utworem w bazie. 
        --  Widocznie Bethoven nagrał tylko jeden dobry kawałek, albo baza jest niekompletna.)

    SELECT Ar.Name, A.Title, COUNT(TrackId) AS Tracks, SUM(UnitPrice) AS AlbumCost
    FROM Track AS T
        INNER JOIN Album AS A ON T.AlbumId = A.AlbumId
        INNER JOIN Artist AS Ar ON A.ArtistId = Ar.ArtistId
    GROUP BY A.Title
    ORDER BY AlbumCost DESC;

-- 16. Wyświetl wszystkie oferowane produkty należące do Sci Fi & Fantasy lub ScienceFiction. Wyświetlane dane powinny zawierać tytuł oraz cenę.

    SELECT T.Name, T.UnitPrice AS Price
    FROM Track AS T
        INNER JOIN Genre AS G ON T.GenreId = G.GenreId
    WHERE G.Name = "Sci Fi & Fantasy" OR G.Name = "Science Fiction";

-- 17. Zbadaj, który zespół ma na swoim koncie najwięcej utworów Metalowych i HeavyMetalowych (łącznie). Wyświetl nazwę zespołu oraz liczbę utworów.

    SELECT Ar.Name, COUNT(TrackId) AS NoAlbums
    FROM Track AS T
        INNER JOIN Genre  AS G  ON T.GenreId = G.GenreId
        INNER JOIN Album  AS A  ON T.AlbumId = A.AlbumId
        INNER JOIN Artist AS Ar ON A.ArtistId = Ar.ArtistId
    WHERE G.Name = "Heavy Metal" OR G.Name = "Metal"
    GROUP BY Ar.Name
    ORDER BY NoAlbums DESC
    LIMIT 1;

-- 18. Wyświetl wszystkie oferowane odcinki Battlestar Galactica, uwzględnij wszystkie sezony.

    SELECT  T.Name, A.Title
    FROM Track AS T
        INNER JOIN Album  AS A  ON T.AlbumId = A.AlbumId
    WHERE A.Title LIKE '%Battlestar Galactica%';

-- 19. Wyświetl nazwy artystów oraz tytuły albumów, dla przypadków kiedy ten sam tytuł nadany został przez dwa różne zespoły.
--     (Uwaga:Jeśli występuje para(X, Y), to wynik nie powinien zawierać pary (Y, X)).

    -- To samo, ale łączymy artystę Y
    SELECT ArtistX, Name AS ArtistY, Title
    FROM
    (
        -- Łączymy ID artysty X z jego nazwą
        SELECT ArtistIdY, Title, Name AS ArtistX FROM 
        (   
            -- Łączymy z tą samą tabelą, gdy nazwy albumu są takie same, a ArtistID różne
            SELECT ArtistIdX, ArtistId AS ArtistIdY, AlbumId, Title
            FROM
            (
                -- Wybieramy 1szy raz tytuł i ID artysty z tabeli Album
                SELECT Title AS TitleX, ArtistId AS ArtistIdX
                FROM Album
            ) AS TabX
            INNER JOIN Album AS TabY WHERE TabX.TitleX = TabY.Title AND TabX.ArtistIdX < TabY.ArtistId -- Nierówność załatwiam nam problem powtarząjących się par
        ) AS TabX INNER JOIN Artist ON TabX.ArtistIdX = Artist.ArtistId
    ) AS TabY INNER JOIN Artist ON TabY.ArtistIdY = Artist.ArtistId;
    


-- 20. Wyświetl wszystkie utwory, które nagrał Santana, niezależnie od tego, kto mu w danym utworze towarzyszył.

    -- Nie wiem, czy dobrze rozumiem polecenie.

    SELECT Name, Composer
    FROM Track
    WHERE Composer LIKE "%Santana%";

-- 21. Uszereguj wszystkich wykonawców malejąco względem średniego czasu trwania ich utworu rockowego.
--     Nie uwzględniaj artystów, którzy nagrali mniej niż 13 utworów z kategorii Rock

    SELECT Ar.Name, COUNT(T.TrackId) AS NoRockTracks, SEC_TO_TIME(floor(AVG(Milliseconds) / 1000)) AS AvgLength --  Bez floor() będzie dokładniej
    FROM Track AS T
        INNER JOIN Genre  AS G  ON T.GenreId = G.GenreId
        INNER JOIN Album  AS A  ON T.AlbumId = A.AlbumId
        INNER JOIN Artist AS Ar ON A.ArtistId = Ar.ArtistId
    WHERE G.Name = "Rock"
    GROUP BY Ar.Name
    HAVING (COUNT(TrackId) > 12)
    ORDER BY AvgLength DESC;
    

-- 22. Na podstawie tabeli customer, wypisz informacje w postaci pary: (domena pocztyemail,liczba klientow),
--     zliczających popularność poszczególnych serwisów. Dane powinny być uporządkowane malejąco względem liczby korzystających zdanej domeny.

    SELECT substring_index(email,'@',-1) AS service, COUNT(CustomerId) AS NoClients
    FROM Customer
    GROUP BY service
    ORDER BY NoClients DESC;

-- 23. Wprowadź 1 nowego klienta do tabeli customer, nie twórz dla niego żadnych faktur.

    -- zanim zaczniemy się bawić w zmiany w bazie:
    mysqldump -u jkt44 -p Chinook > Chinook_backup.sql

    INSERT INTO Customer (CustomerId, FirstName, LastName, Company, Address, City, Country, PostalCode, Phone, Email, SupportRepId)
    VALUES (60,"Mateusz", "Trzeciak", "PokazyHistoryczne", "Ćwiartki 3/4", "Wrocław", "Poland", "50-216", "664626230", "mateusz.trzeciak44@gmail.com", 1);

-- 24. Do tabeli customer dodaj, jako ostatnią, kolumnę FavGenre. Dla wszystkich klientów ustaw ją początkowo na NULL

    ALTER TABLE Customer
    ADD FavGenre varchar(255) DEFAULT NULL; --Bez sensu dałem varchar zamiast int, ale niech już tak

-- 25. Dla każdego klienta ustaw wartośćFavGenrena dowolne ID oferowanego gatunku.

    UPDATE Customer
    SET FavGenre = 1 + FLOOR(RAND() * 25);

-- 26. Z tabeli customer usuń kolumnę Fax

    ALTER TABLE Customer
    DROP COLUMN Fax;

-- 27. Dla każdego klienta ustaw wartość FavGenre w oparciu o dokonywane zakupy – dla klientów, którzy nic nie zamówili - wstaw NULL,
--     dla pozostałych ten gatunek,z którego zamówili najwięcej produktów (w przypadku równej liczby wybierz np.alfabetycznie).

    -- TODO obczaić, co się dzieje w przypadku gdy customer kupił taką samą ilość utworów z różnych gatunków.
    -- Najprawdopodobiej bierze pierwszy z góry, bo MAX() powinien szukać wartości lecąc od góry do dołu.

    UPDATE Customer,
        (
        -- Łączymy ze zwykłym customer, żeby spełnić warunek "dla klientów, którzy nic nie zamówili - wstaw NULL"
        SELECT C.CustomerId AS CustomerId, CustomerMax.MaxCount, CustomerMax.Genre AS FavGenre
        FROM Customer AS C
            LEFT JOIN
            (
                -- Grupujemy poprzednią tabelę, wybierając Genre z maksymalną ilością wystąpień dla każdego klienta

                SELECT CustomerId, MAX(TrackCount) AS MaxCount, CustomerCountPerGenre.GenreId AS Genre  
                FROM
                (
                    -- Tabela, gdzie dla każdych par (CustomerId, GenreId podana jest ilość kupionych Tracków)

                    SELECT I.CustomerId AS CustomerId, T.GenreId AS GenreId, COUNT(T.TrackId) AS TrackCount
                    FROM Invoice AS I
                        INNER JOIN Customer AS C ON I.CustomerId = C.CustomerId
                        INNER JOIN InvoiceLine AS IL ON I.InvoiceId = IL.InvoiceId
                        INNER JOIN Track AS T ON IL.TrackId = T.TrackId
                        GROUP BY I.CustomerId, T.GenreId
                        ORDER BY I.CustomerId, TrackCount DESC, GenreId                           --  Bez tego nie działa, nie wiem dlaczego
                ) AS CustomerCountPerGenre
                GROUP BY CustomerId
            ) AS CustomerMax ON C.CustomerId = CustomerMax.CustomerId
        ) AS FinalFavGenre
    SET Customer.FavGenre = FinalFavGenre.FavGenre
    WHERE Customer.CustomerId = FinalFavGenre.CustomerId;
    



-- 28. Z tabeli invoice usuń wszystkie faktury wystawione przed rokiem 2010.
    
    mysqldump -u jkt44 -p Chinook > Chinook_backup.sql

    DELETE FROM InvoiceLine
    WHERE InvoiceLine.InvoiceLineId IN 
    (
        SELECT *
        FROM 
        (
            SELECT InvoiceLine.InvoiceLineId
            FROM InvoiceLine
                JOIN Invoice ON Invoice.InvoiceId = InvoiceLine.InvoiceId
            WHERE Invoice.InvoiceDate < '2010-01-01'
        ) AS TMP
    );

    DELETE FROM Invoice
    WHERE Invoice.InvoiceId IN
    (
        SELECT * FROM 
        (
            SELECT Invoice.InvoiceId
            FROM Invoice
            WHERE Invoice.InvoiceDate < '2010-01-01'
        ) AS TMP
    );

-- 29. Usuń z bazy informację o klientach, którzy nie są powiązani z żadną transakcją.

    DELETE FROM Customer
    WHERE CustomerId NOT IN (SELECT CustomerId FROM Invoice);

-- 30. Uzupełnij tablę track o informacje dotyczące utworów z albumów The Unforgiving oraz Gigaton,
-- uzupełnij informacje w pozostałych tabelach tak, aby baza zachowała spójność
-- (tzn. dodaj informacje o nieistniejących wcześniej zespołach,albumach etc. a dla istniejących wprowadź poprawne ID).
-- Zastanów się, jak ten proces zautomatyzować.

    SELECT * FROM Artist WHERE Name = "Within Temptation" OR Name = "Pearl Jam";

    INSERT INTO Artist
    VALUES
        (276, "Within Temptation");

    SELECT * FROM Album WHERE Title = "The Unforgiving" OR Title = "Gigaton";

    INSERT INTO Album
    VALUES  
        (348, "The Unforgiving", 276),
        (349, "Gigaton",         118);

    INSERT INTO Track 
    VALUES
        (3504, "Why Not Me",                 348, 2, 3, "den Adel Westerholt",                       34000,  100000, 0.99),
        (3505, "Shot in the Dark",           348, 2, 3, "den Adel, Westerholt, Gibson",              502000,100000, 0.99),
        (3506, "In the Middle of the Night", 348, 2, 3, "den Adel, Westerholt, Gibson",              511000,100000, 0.99),
        (3507, "Faster",                     348, 2, 3, "den Adel, Westerholt, Gibson",              423000,100000, 0.99),
        (3508, "Fire and Ice",               348, 2, 3, "den Adel, Spierenburg",                     357000,100000, 0.99),
        (3509, "Iron",                       348, 2, 3, "Gibson, Westerholt",                        540000,100000, 0.99),
        (3510, "Where Is the Edge",          348, 2, 3, "den Adel, Westerholt, Gibson",              359000,100000, 0.99),
        (3511, "Sinéad",                     348, 2, 3, "den Adel, Westerholt, Gibson, Spierenburg", 423000,100000, 0.99),
        (3512, "Lost",                       348, 2, 3, "den Adel, Westerholt, Gibson",              514000,100000, 0.99),
        (3513, "Murder",                     348, 2, 3, "dden Adel, Westerholt, Gibson",             416000,100000, 0.99),
        (3514, "A Demon's Fate",             348, 2, 3, "den Adel, Gibson",                          530000,100000, 0.99),
        (3515, "Stairway to the Skies",      348, 2, 3, "den Adel, Spierenburg",                     532000,100000, 0.99),
        (3516, "Who Ever Said",              349, 2, 4, "Vedder",                                    511000,100000, 0.99),
        (3517, "Superblood Wolfmoon",        349, 2, 4, "Vedder",                                    347000,100000, 0.99),
        (3518, "Dance of the Clairvoyants",  349, 2, 4, "Jeff Ament, Matt Cameron, Stone Gossard, Mike McCready, Vedder",  426000,100000, 0.99),
        (3519, "Quick Escape",               349, 2, 4, "Ament",                                     470000,100000, 0.99),
        (3520, "Alright",                    349, 2, 4, "Ament",                                     344000,100000, 0.99),
        (3521, "Seven O'Clock",              349, 2, 4, "Ament, Gossard, McCready, Vedder",          614000,100000, 0.99),
        (3522, "Never Destination",          349, 2, 4, "Vedder",                                    417000,100000, 0.99),
        (3523, "Take the Long Way",          349, 2, 4, "Cameron",                                   342000,100000, 0.99),
        (3524, "Buckle Up",                  349, 2, 4, "Gossard",                                   337000,100000, 0.99),
        (3525, "Comes Then Goes",            349, 2, 4, "Vedder",                                    602000,100000, 0.99),
        (3526, "Retrograde",                 349, 2, 4, "McCready",                                  522000,100000, 0.99),
        (3527, "River Cross",                349, 2, 4, "Vedder",                                    557000,100000, 0.99);
        
