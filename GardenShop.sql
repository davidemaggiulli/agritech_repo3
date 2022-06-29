-- CLIENTE (codice, nome, indirizzo, tipo, piva*, cf*)
-- PIANTA (codice, nomeLat, nomeCom, giardino, esotico, fiorita, FORNITORE:codice)
-- FORNITORE (codice, nome, cf, indirizzo)
-- COLORAZIONE (codice, nome)
-- LISTINO (data_inizio, PIANTA:codice ,prezzo, data_fine*)
-- VENDITA (PIANTA:codice, CLIENTE:codice, data, quantità)
-- PIANTA_COLORAZIONE(PIANTA:codice, COLORAZIONE:codice)


CREATE DATABASE GardenShop DEFAULT CHARSET utf8mb4;
USE GardenShop;

CREATE TABLE Sale(
	CustomerId INT NOT NULL,
    PlantId INT NOT NULL,
    Date DATETIME NOT NULL,
    Quantity MEDIUMINT UNSIGNED NOT NULL,
    PRIMARY KEY(CustomerId, PlantId, Date),
    CONSTRAINT ck_quantity CHECK (Quantity > 0)
);

-- CLIENTE (codice, nome, indirizzo, tipo, piva*, cf*)
CREATE TABLE Customer(
	Id INT NOT NULL AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Type CHAR(1) NOT NULL,
    VatNumber CHAR(11) NULL,
    FiscalCode CHAR(16) NULL,
    PRIMARY KEY(Id),
    CONSTRAINT ck_type CHECK (Type IN ('C','R')),
    CONSTRAINT ck_type_piva_cf CHECK ( (Type = 'C' AND FiscalCode IS NOT NULL AND VatNumber IS NULL) OR (Type = 'R' AND VatNumber IS NOT NULL AND FiscalCode IS NULL)  ) ,
    CONSTRAINT uc_fiscalcode UNIQUE(FiscalCode),
    CONSTRAINT uc_vatnumber UNIQUE(VatNumber)
);

-- PIANTA (codice, nomeLat, nomeCom, giardino, esotico, fiorita, FORNITORE:codice)
CREATE TABLE Plant(
	Id INT NOT NULL AUTO_INCREMENT,
    LatName VARCHAR(100) NOT NULL,
    ComName VARCHAR(100) NOT NULL,
    Garden BIT NOT NULL,
    Exotic BIT NOT NULL, 
    Flowered BIT NOT NULL,
    SupplierId INT NOT NULL,
    PRIMARY KEY(Id)
);

-- FORNITORE (codice, nome, cf, indirizzo)
CREATE TABLE Supplier(
	Id INT NOT NULL AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    FiscalCode CHAR(16) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    PRIMARY KEY(Id)
);

-- COLORAZIONE (codice, nome)
CREATE TABLE FlowerColor(
	Id MEDIUMINT NOT NULL AUTO_INCREMENT,
    Name VARCHAR(50) NOT NULL,
    PRIMARY KEY(Id)
);

-- LISTINO (data_inizio, PIANTA:codice, prezzo, data_fine*)
CREATE TABLE PriceList(
	StartDate DATE NOT NULL,
    PlantId INT NOT NULL,
    Price DECIMAL(8,4) NOT NULL,
    EndDate DATE NULL,
    PRIMARY KEY(StartDate, PlantId),
    CONSTRAINT ck_price_greather_zero CHECK(Price > 0)
);

-- PIANTA_COLORAZIONE(PIANTA:codice, COLORAZIONE:codice)
CREATE TABLE Plant_FlowerColor(
	PlantId INT NOT NULL,
    FlowerColorId MEDIUMINT NOT NULL,
    PRIMARY KEY(PlantId, FlowerColorId),
    CONSTRAINT fk_plantflowercolor_plant FOREIGN KEY (PlantId) REFERENCES Plant(Id),
    CONSTRAINT fk_plantflowercolor_flowercolor FOREIGN KEY(FlowerColorId) REFERENCES FlowerColor(Id)
);

ALTER TABLE Sale
ADD CONSTRAINT fk_sale_customer FOREIGN KEY(CustomerId) REFERENCES Customer(Id);
-- ALTER TABLE Sale
-- DROP CONSTRAINT fk_sale_customer

ALTER TABLE Sale
ADD CONSTRAINT fk_sale_plant FOREIGN KEY(PlantId) REFERENCES Plant(Id);

ALTER TABLE Plant
ADD CONSTRAINT fk_plant_supplier FOREIGN KEY(SupplierId) REFERENCES Supplier(Id);

ALTER TABLE PriceList
ADD CONSTRAINT fk_pricelist_plant FOREIGN KEY(PlantId) REFERENCES Plant(Id);


INSERT INTO plant_flowercolor VALUES
(1, 5),(1,3),(2,1),(2,4)

INSERT INTO Customer(Id,Name,Address,Type,VatNumber,FiscalCode) VALUES
(NUll, 'Davide Maggiulli', 'Via Fosse Ardeatine', 'C', NULL, 'MGGDVD87H27E815Y'),
(NUll, 'Martina Bettoni', 'Via Delle Rose', 'C', NULL, 'MRTBTN96H27E815Y'),
(NUll, 'Gardenia', 'Via Delle Rose', 'R', '01234567890', NULL);

INSERT INTO PriceList(StartDate,PlantId,Price,EndDate) VALUES
( '2022-01-01' ,1, 10, '2022-05-31'),
( '2022-06-01' ,1, 12, NULL),
( '2022-01-01' ,2, 5, '2022-04-30'),
( '2022-05-01' ,2, 6, '2022-06-30'),
( '2022-07-01' ,2, 7, NULL);

INSERT INTO Sale (CustomerId,PlantId,Date, Quantity) VALUES
(1,1,'2022-6-27',5),
(1,1,'2022-6-28',10),
(2,1,'2022-6-29 14:00:00',2),
(2,1,'2022-6-29 16:00:00',20),
(2,2,'2022-6-29 16:00:00',5)

-- Dato un articolo, es PlantId = 1 e una certa data, es. 2022-06-27 00:00:00
-- qual è il prezzo di vendita di tale pianta in quella data
SELECT Price
FROM PriceList
WHERE PlantId = 1 AND ( (EndDate Is NULL AND '2024-06-27' > StartDate) OR (EndDate IS NOT NULL AND '2024-06-27' BETWEEN StartDate AND EndDate)  )
ORDER BY StartDate DESC
LIMIT 1


-- Inserire questa query in una STORED FUNCTION riutilizzabile
DROP FUNCTION GetItemPrice
DELIMITER $$
CREATE FUNCTION GetItemPrice(pId INT, oDate DATETIME) RETURNS DECIMAL(8,4) DETERMINISTIC
BEGIN
		
		DECLARE p DECIMAL(8,4);
        SET p = NULL;
        IF (SELECT COUNT(*) FROM Plant WHERE Id = pId) = 0 THEN
			RETURN p;
		END IF;
		
		SET p = (SELECT Price
		FROM PriceList
		WHERE PlantId = pId AND ( (EndDate Is NULL AND DATE(oDate) >= StartDate) OR (EndDate IS NOT NULL AND DATE(oDate) BETWEEN StartDate AND EndDate)  )
		ORDER BY StartDate DESC
		LIMIT 1);
        
        RETURN IFNULL(p,0);
END $$
DELIMITER ;

SELECT GetItemPrice(2,'2019-6-27')


-- Martina Bettoni è un buon cliente?  --> Quanto ho venduto a Martina Bettoni in totale?
-- Più in generale: per ogni cliente, quanto ho venduto?

SELECT C.Id As CustId, C.Name AS CustName, SUM(GetItemPrice(S.PlantId, DATE(S.Date)) * S.Quantity) As Total
FROM Customer C 
JOIN Sale S ON S.CustomerId = C.Id
GROUP BY C.Id, C.Name;

-- E se volessi solo i clienti a cui ho venduto oltre x euro ?
SELECT C.Id As CustId, C.Name AS CustName, SUM(GetItemPrice(S.PlantId, DATE(S.Date)) * S.Quantity) As Total
FROM Customer C 
JOIN Sale S ON S.CustomerId = C.Id
GROUP BY C.Id, C.Name
HAVING Total >= 300;


SELECT *, GetItemPrice(S.PlantId, S.Date)
FROM Customer C 
JOIN Sale S ON S.CustomerId = C.Id

-- Indica quali sono le piante (fiorite) che includono una colorazione rosa. Indicare il nome della pianta (tra parentesi il nome latino)

SELECT CONCAT(P.ComName,' (',P.LatName,')') As Pianta
FROM plant_flowercolor PF
JOIN Plant P ON P.Id = PF.PlantId
JOIN FlowerColor FC ON FC.Id = PF.FlowerColorId
WHERE FC.Name = 'rosa'

-- Report Vendite (per ogni cliente, il totale venduto) del mese corrente
SELECT C.Id As CustId, C.Name AS CustName, SUM(GetItemPrice(S.PlantId, DATE(S.Date)) * S.Quantity) As Total
FROM Customer C 
JOIN Sale S ON S.CustomerId = C.Id
WHERE S.Date BETWEEN ADDDATE(LAST_DAY(SUBDATE(now(), INTERVAL 1 MONTH)), 1) AND LAST_DAY(NOW())
GROUP BY C.Id, C.Name;


-- Creare una procedura che permetta l'inserimento di una pianta nel sistema
-- Ingressi: Nome comune, nome latino, giardino, esotica, floreale, codice fornitore, prezzo di vendita
-- nb: deve essere inserito di default un listino per la nuova pianta (da oggi a NULL) con il prezzo passato

-- Creare una procedura che permetta di associare ad una pianta un colore 
-- Ingressi: codice pianta, codice colore


