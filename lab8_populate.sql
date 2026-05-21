USE SalesDB;

GO
INSERT INTO
    Clients (name, address)
VALUES
    (
        N'Alpine Retail',
        N'12 Mountain Road, Denver, CO'
    ),
    (
        N'Blue Harbor Foods',
        N'88 Dock Street, Seattle, WA'
    ),
    (
        N'City Market',
        N'45 Central Avenue, Chicago, IL'
    ),
    (
        N'Delta Wholesale',
        N'190 Industrial Park, Dallas, TX'
    ),
    (
        N'Evergreen Cafe',
        N'77 Pine Street, Portland, OR'
    );

INSERT INTO
    Goods (goods_name, unit, current_price_per_unit)
VALUES
    (N'Coffee Beans', N'kg', 12),
    (N'Sugar', N'kg', 2),
    (N'Flour', N'kg', 1),
    (N'Olive Oil', N'liter', 8),
    (N'Rice', N'kg', 3),
    (N'Tea Boxes', N'box', 15);

INSERT INTO
    Shipment_notes (shipment_date, client_id)
VALUES
    ('2023-01-05', 1),
    ('2023-01-08', 2),
    ('2023-02-03', 1),
    ('2024-02-10', 3),
    ('2024-03-01', 4),
    ('2025-03-12', 5);

INSERT INTO
    Shipped_goods (
        units_shipped,
        factual_price_per_unit,
        goods_id,
        shipment_note_id
    )
VALUES
    -- Shipment 1: Alpine Retail
    (10, 11, 1, 1),
    (25, 2, 2, 1),
    -- Shipment 2: Blue Harbor Foods
    (100, 1, 3, 2),
    (50, 3, 5, 2),
    -- Shipment 3: Alpine Retail
    (5, 14, 6, 3),
    (12, 8, 4, 3),
    -- Shipment 4: City Market
    (40, 2, 2, 4),
    (20, 12, 1, 4),
    -- Shipment 5: Delta Wholesale
    (200, 3, 5, 5),
    (150, 1, 3, 5),
    (30, 8, 4, 5),
    -- Shipment 6: Evergreen Cafe
    (10, 15, 6, 6),
    (15, 12, 1, 6);

INSERT INTO
    Payment_notes ([date], client_id)
VALUES
    ('2024-01-20', 1),
    ('2024-02-15', 1),
    ('2024-01-25', 2),
    ('2024-02-20', 3),
    ('2024-03-15', 4),
    ('2024-03-25', 5);

INSERT INTO
    Payment_notes_Shipped_goods (
        payment_note_id,
        shipped_goods_id,
        units_paid
    )
VALUES
    -- Payment 1: Alpine Retail pays for Shipment 1 fully
    (1, 1, 10),
    (1, 2, 25),
    -- Payment 2: Alpine Retail pays Shipment 3, olive oil partially
    (2, 5, 5),
    (2, 6, 6),
    -- Payment 3: Blue Harbor Foods pays Shipment 2 fully
    (3, 3, 100),
    (3, 4, 50),
    -- Payment 4: City Market pays Shipment 4 partially
    (4, 7, 40),
    (4, 8, 10),
    -- Payment 5: Delta Wholesale pays part of Shipment 5
    (5, 9, 150),
    (5, 10, 100),
    (5, 11, 15),
    -- Payment 6: Evergreen Cafe pays Shipment 6 fully
    (6, 12, 10),
    (6, 13, 15);