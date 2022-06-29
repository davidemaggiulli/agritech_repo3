-- PIZZA (code, name, price)
-- INGREDIENT (code, name, cost, stock)
-- COMPOSITION (PIZZA: codePizza, INGREDIENT: codeIngredient, quantity)

-- Il prezzo della pizza, il costo dell’ingrediente e la quantità di un ingrediente presente in una pizza è un numero positivo (> 0)


CREATE DATABASE Pizzeria DEFAULT CHARSET utf8
use Pizzeria

CREATE TABLE Pizza(
	Code INT NOT NULL AUTO_INCREMENT,
    Name VARCHAR(20) NOT NULL,
    Price DECIMAL(5,2) NOT NULL,
    CONSTRAINT pk_code PRIMARY KEY (Code),
    CONSTRAINT ck_price CHECK(Price > 0)
);

CREATE TABLE Ingredient(
	Code INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    Cost DECIMAL(5,2) NOT NULL,
    Stock DECIMAL(6,2) NOT NULL,
    CONSTRAINT ck_cost CHECK (Cost > 0)
);

CREATE TABLE Composition(
	CodePizza INT NOT NULL,
    CodeIngredient INT NOT NULL,
    Quantity DECIMAL(4,2) NOT NULL,
    PRIMARY KEY(CodePizza, CodeIngredient),
    CONSTRAINT ck_quantity CHECK (Quantity > 0),
    CONSTRAINT fk_composition_pizza FOREIGN KEY (CodePizza) REFERENCES Pizza(Code),
    CONSTRAINT fk_composition_ingredient FOREIGN KEY (CodeIngredient) REFERENCES Ingredient(Code)
);

-- Implementare un indice per la ricerca delle pizze per nome, ed uno per la ricerca dell’ingrediente utilizzando il codice.
CREATE INDEX IX_Pizza_Name
ON Pizza (Name)

-- Popola il DB
-- Ingredient
INSERT INTO Ingredient(Code,Name,Cost,Stock)
VALUES 
( NULL, 'Pomodoro', 1 , 1),
( NULL, 'Mozzarella', 1 , 1),
( NULL, 'Mozzarella di Bufala', 1 , 1),
( NULL, 'Spianata piccante', 1 , 1),
( NULL, 'Funghi', 1 , 1),
( NULL, 'Carciofi', 1 , 1),
( NULL, 'Cotto', 1 , 1),
( NULL, 'Olive', 1 , 1),
( NULL, 'Funghi porcini', 1 , 1)

INSERT INTO Pizza(Code,Name,Price)
VALUES
(NULL,'Margherita',5),
(NULL, 'Bufala', 7),
(NULL, 'Diavola', 6),
(NULL, 'Quattro stagioni', 6.5),
(NULL, 'Porcini', 7),
(NULL, 'Dioniso', 8),
(NULL, 'Ortolana', 8),
(NULL, 'Patate e salsiccia', 6),
(NULL, 'Pomodorini', 6),
(NULL, 'Quattro Formaggi', 7.5),
(NULL, 'Caprese', 7.5),
(NULL, 'Zeus', 7.5)

INSERT INTO Composition(CodePizza, CodeIngredient, Quantity)
VALUES 
(1,1,1), 
(1,2,1),

(2,1,1),
(2,3,2),

(3,1,1),
(3,2,1),
(3,4,1),

(4,1,1),
(4,2,1),
(4,5,1),
(4,6,1),
(4,7,1),
(4,8,1),

(5,1,1),
(5,2,1),
(5,9,1)



INSERT INTO Pizza VALUES(NULL,'Patate sals, funghi',9);
INSERT INTO Ingredient VALUES (NULL,'Patate',2,1),(NULL,'Salsiccia',3,1)
INSERT INTO Composition VALUES (13,2,1),(13,10,1),(13,11,1),(13,5,1)



SELECT * FROM Pizza;
SELECT * From Ingredient;
SELECT * FROM Composition;

-- Indicare quali sono gli ingredienti della Margherita (solo nome ingrediente) ordinati per quantità crescente
SELECT I.Name AS Ingrediente
FROM Composition AS C
JOIN Pizza AS P ON P.Code = C.CodePizza
JOIN Ingredient AS I ON I.Code = C.CodeIngredient
WHERE P.Name = 'Margherita'
ORDER BY C.Quantity DESC

-- Quali sono le pizze che contengono la mozzarella?

SELECT P.Name AS Pizza
FROM Ingredient AS I
JOIN Composition AS C ON C.CodeIngredient = I.Code
JOIN Pizza AS P ON P.Code = C.CodePizza
WHERE I.Name = 'Mozzarella'
ORDER BY P.Price

-- Quali sono le pizza che NON contengono i funghi
SELECT P.Name AS Pizza
FROM Ingredient AS I
JOIN Composition AS C ON C.CodeIngredient = I.Code
JOIN Pizza AS P ON P.Code = C.CodePizza
WHERE I.Name <> 'Funghi'
ORDER BY P.Price

SELECT P.Name
FROM Pizza AS P
WHERE Code NOT IN (
	SELECT DISTINCT C.CodePizza
	FROM Composition AS C
	JOIN Ingredient I ON I.Code = C.CodeIngredient
	WHERE I.Name = 'Funghi'
)

-- Aumenta del 10% il costo delle pizze che contengono i funghi
UPDATE Pizza
SET Price = 1.1 * Price
WHERE  Code IN (
SELECT C.CodePizza
FROM Composition AS C
JOIN Ingredient I ON I.Code = C.CodeIngredient
WHERE I.Name = 'Funghi')

-- Quale è il prezzo medio di una pizza nel ristorante?
SELECT AVG(Price) AS 'Prezzo Medio'
FROM Pizza

-- Per ogni pizza, indicare quanti ingredienti ha
-- Margherita, 2
-- Quattro Stagioni, 6
SELECT P.Name AS Pizza, COUNT(*) AS 'Num. Ingredienti'
FROM Composition AS C
JOIN Pizza AS P ON P.Code = C.CodePizza
GROUP BY P.Name

-- Per ogni ingrediente, indicare qual è il massimo prezzo a cui viene venduto in una pizza
SELECT I.Name AS Ingrediente, MAX(P.Price) AS 'Prezzo massimo'
FROM Composition AS C
JOIN Pizza AS P ON P.Code = C.CodePizza
JOIN Ingredient AS I ON I.Code = C.CodeIngredient
GROUP BY I.Name


-- Per ogni ingrediente, indicare qual è il massimo e il minimo prezzo e prezzo medio a cui viene venduto in una pizza
SELECT I.Name AS Ingrediente, MAX(P.Price) AS 'Prezzo massimo', MIN(P.Price) AS 'Prezzo minimo', AVG(P.Price) AS 'Prezzo medio'
FROM Composition AS C
JOIN Pizza AS P ON P.Code = C.CodePizza
JOIN Ingredient AS I ON I.Code = C.CodeIngredient
GROUP BY I.Name


-- Quali pizze vengono vendute con un prezzo tra i 6 e i 7 euro?
SELECT *
FROM Pizza
WHERE Price BETWEEN 6 AND 7


-- Per ogni ingrediente, indicare qual è il massimo prezzo prezzo a cui viene venduto in una pizza, ma solo quelle avente prezzo medio almeno pari a 7 euro.
SELECT I.Name AS Ingrediente, MAX(P.Price) AS 'Prezzo massimo'
FROM Composition AS C
JOIN Pizza AS P ON P.Code = C.CodePizza
JOIN Ingredient AS I ON I.Code = C.CodeIngredient
GROUP BY I.Name
HAVING AVG(Price) >= 7

-- Quali pizze hanno almeno 3 ingredienti?
SELECT CONCAT(P.Code,' - ',P.Name) AS Pizza, COUNT(*) AS 'N'
FROM Pizza AS P 
JOIN Composition AS C ON C.CodePizza = P.Code
GROUP BY P.Code, P.Name
HAVING COUNT(*) >= 3


-- Per ogni pizza che non contiene i funghi, indicare quanti ingredienti ha

SELECT *
FROM Pizza AS P

WHERE P.Code NOT IN (
	SELECT DISTINCT C.CodePizza
	FROM Composition AS C
	JOIN Ingredient I ON I.Code = C.CodeIngredient
	WHERE I.Name = 'Funghi'
)

SELECT *
FROM Composition AS C
JOIN Pizza AS P ON P.Code = C.CodePizza
JOIN Ingredient AS I ON I.Code = C.CodeIngredient