USE tempdb DROP DATABASE IF EXISTS SalesDB;

CREATE DATABASE SalesDB;

GO
    USE SalesDB;

GO
    CREATE TABLE Clients (
        client_id INT NOT NULL IDENTITY(1, 1),
        name NVARCHAR(200) NOT NULL,
        address NVARCHAR(500) NULL,
        CONSTRAINT PK_Clients PRIMARY KEY (client_id)
    );

CREATE TABLE Shipment_notes (
    shipment_note_id INT NOT NULL IDENTITY(1, 1),
    shipment_date DATE NOT NULL,
    client_id INT NOT NULL,
    CONSTRAINT PK_Shipment_notes PRIMARY KEY (shipment_note_id),
    CONSTRAINT FK_Shipment_notes_Clients FOREIGN KEY (client_id) REFERENCES Clients (client_id)
);

CREATE TABLE Payment_notes (
    payment_note_id INT NOT NULL IDENTITY(1, 1),
    date DATE NOT NULL,
    client_id INT NOT NULL,
    CONSTRAINT PK_Payment_notes PRIMARY KEY (payment_note_id),
    CONSTRAINT FK_Payment_notes_Clients FOREIGN KEY (client_id) REFERENCES Clients (client_id)
);

CREATE TABLE Goods (
    goods_id INT NOT NULL IDENTITY(1, 1),
    goods_name NVARCHAR(200) NOT NULL,
    unit NVARCHAR(50) NOT NULL,
    current_price_per_unit DECIMAL NOT NULL,
    CONSTRAINT PK_Goods PRIMARY KEY (goods_id)
);

CREATE TABLE Shipped_goods (
    shipped_goods_id INT NOT NULL IDENTITY(1, 1),
    [units_shipped] INT NOT NULL,
    factual_price_per_unit DECIMAL NOT NULL,
    goods_id INT NOT NULL,
    shipment_note_id INT NOT NULL,
    CONSTRAINT PK_Shipped_goods PRIMARY KEY (shipped_goods_id),
    CONSTRAINT FK_Shipped_goods_Goods FOREIGN KEY (goods_id) REFERENCES Goods (goods_id),
    CONSTRAINT FK_Shipped_goods_Shipment_notes FOREIGN KEY (shipment_note_id) REFERENCES Shipment_notes (shipment_note_id)
);

CREATE TABLE Payment_notes_Shipped_goods (
    payment_note_id INT NOT NULL,
    shipped_goods_id INT NOT NULL,
    units_paid INT NOT NULL,
    CONSTRAINT PK_Payment_notes_Shipped_goods PRIMARY KEY (payment_note_id, shipped_goods_id),
    CONSTRAINT FK_PmtShp_Payment_notes FOREIGN KEY (payment_note_id) REFERENCES Payment_notes (payment_note_id),
    CONSTRAINT FK_PmtShp_Shipped_goods FOREIGN KEY (shipped_goods_id) REFERENCES Shipped_goods (shipped_goods_id)
)