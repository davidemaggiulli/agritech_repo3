CREATE DATABASE Banca DEFAULT CHARSET utf8;

use Banca;

-- INDIRIZZO (id, via, civico, città, prov, cap)


CREATE TABLE Address(
	Id INT NOT NULL AUTO_INCREMENT,
    StreetName VARCHAR(50) NOT NULL,
    StreetNumber VARCHAR(10) NOT NULL,
    City VARCHAR(70) NOT NULL,
    Province CHAR(2) NOT NULL,
    Cap CHAR(5) NOT NULL,
    PRIMARY KEY(Id)
);

-- CLIENTE (INDIRIZZO: codice, nome, cognome, luogo_nascita*,data_nascita, sesso)
CREATE TABLE Customer(
	Id INT NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
    BirthPlace VARCHAR(50) NULL,
    BirthDate DATE NOT NULL,
    Gender CHAR(1) NOT NULL,
    CONSTRAINT ck_gender CHECK (Gender IN ('M','F','U')),
    PRIMARY KEY(Id),
    FOREIGN KEY(Id) REFERENCES Address(Id)
);

-- CONTO (numero, iban, saldo, saldo_precedente* , data_creazione, data_aggiornamento*, CLIENTE:cliente)
CREATE TABLE BankAccount(
	`Number` INT NOT NULL AUTO_INCREMENT,
    Iban CHAR(16) NOT NULL,
    Amount DECIMAL(20,8) NOT NULL,
    PreviousAmount DECIMAL (20,8) NULL,
    CreateTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UpdateTimestamp TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
	CustomerId INT NOT NULL,
	PRIMARY KEY (`Number`),
    CONSTRAINT uc_iban UNIQUE (IBan),
    CONSTRAINT fk_bankaccount_customer FOREIGN KEY(CustomerId) REFERENCES Customer(Id)
);

-- OPERAZIONE (id, descrizione, data, importo, iban*, CONTO:numero_conto)
CREATE TABLE Operation(
	Id BIGINT NOT NULL AUTO_INCREMENT,
    Description VARCHAR(255) NOT NULL,
    Date DATETIME NOT NULL DEFAULT NOW(),
    Iban CHAR(16) NULL,
    BankAccountNumber INT NOT NULL,
    PRIMARY KEY(Id),
    CONSTRAINT fk_operation_bankaccount FOREIGN KEY(BankAccountNumber) REFERENCES BankAccount(`Number`)
);



-- Procedure
DROP PROCEDURE CREATECustomer
DELIMITER $$
CREATE PROCEDURE CreateCustomer( 
	FirstName VARCHAR(50),
    LastName VARCHAR(50),
    BirthPlace VARCHAR(50),
    BirthDate DATE,
    Gender CHAR(1),
    Iban CHAR(16),
    StreetName VARCHAR(50),
    StreetNumber VARCHAR(10),
    City VARCHAR(70),
    Province CHAR(2),
    Cap CHAR(5)
)
BEGIN
	
	INSERT INTO Address VALUES(NULL, StreetName, StreetNumber, City, Province, Cap);
	
    INSERT INTO Customer
    VALUES(LAST_INSERT_ID(), FirstName, LastName, BirthPlace, BirthDate, Gender);
    
    INSERT INTO BankAccount
    VALUES(NULL, Iban, 0, NULL, CURRENT_TIMESTAMP, NULL, LAST_INSERT_ID());
    
END $$






