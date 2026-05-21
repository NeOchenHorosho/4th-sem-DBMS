USE SalesDB;

GO
    DECLARE @goods_id INT = 1;

DECLARE @report_date DATE = '2024-02-10';

-- форма выходного отчёта 1
WITH Paid AS (
    SELECT
        pnsg.shipped_goods_id,
        SUM(pnsg.units_paid) AS units_paid
    FROM
        Payment_notes_Shipped_goods pnsg
    GROUP BY
        pnsg.shipped_goods_id
),
ReportRows AS (
    SELECT
        sn.shipment_note_id,
        c.name AS client_name,
        sn.shipment_date,
        sg.units_shipped,
        p.units_paid,
        CASE
            WHEN sg.units_shipped - p.units_paid > 0 THEN (sg.units_shipped - p.units_paid) * sg.factual_price_per_unit
            ELSE 0
        END AS underpayment
    FROM
        Shipped_goods sg
        JOIN Shipment_notes sn ON sg.shipment_note_id = sn.shipment_note_id
        JOIN Clients c ON sn.client_id = c.client_id
        LEFT JOIN Paid p ON sg.shipped_goods_id = p.shipped_goods_id
    WHERE
        sg.goods_id = @goods_id
),
OutputRows AS (
    SELECT
        0 AS sort_order,
        shipment_date AS sort_date,
        shipment_note_id AS sort_note_id,
        CAST(shipment_note_id AS NVARCHAR(20)) AS [Накладная №],
        client_name AS [Заказчик],
        shipment_date AS [Дата],
        units_shipped AS [Отгружено, штук],
        units_paid AS [Оплачено, штук],
        underpayment AS [Недооплата]
    FROM
        ReportRows
    UNION
    ALL
    SELECT
        1 AS sort_order,
        NULL AS sort_date,
        NULL AS sort_note_id,
        N'Итого' AS [Накладная №],
        NULL AS [Заказчик],
        NULL AS [Дата],
        SUM(units_shipped) AS [Отгружено, штук],
        SUM(units_paid) AS [Оплачено, штук],
        SUM(underpayment) AS [Недооплата]
    FROM
        ReportRows
)
SELECT
    [Накладная №],
    [Заказчик],
    [Дата],
    [Отгружено, штук],
    [Оплачено, штук],
    [Недооплата]
FROM
    OutputRows
ORDER BY
    sort_order,
    sort_date;

-- форма выходного отчёта 2
WITH Paid AS (
    SELECT
        pnsg.shipped_goods_id,
        SUM(pnsg.units_paid) AS units_paid
    FROM
        Payment_notes_Shipped_goods pnsg
        JOIN Payment_notes pn ON pnsg.payment_note_id = pn.payment_note_id
    WHERE
        pn.date <= @report_date
    GROUP BY
        pnsg.shipped_goods_id
),
ReportRows AS (
    SELECT
        sn.shipment_note_id,
        c.name AS client_name,
        c.address,
        sn.shipment_date,
        g.goods_name,
        sg.units_shipped,
        p.units_paid AS units_paid,
        CASE
            WHEN sg.units_shipped - p.units_paid > 0 THEN (sg.units_shipped - p.units_paid) * sg.factual_price_per_unit
            ELSE 0
        END AS underpayment
    FROM
        Shipped_goods sg
        JOIN Goods g ON sg.goods_id = g.goods_id
        JOIN Shipment_notes sn ON sg.shipment_note_id = sn.shipment_note_id
        JOIN Clients c ON sn.client_id = c.client_id
        LEFT JOIN Paid p ON sg.shipped_goods_id = p.shipped_goods_id
    WHERE
        sn.shipment_date <= @report_date
        AND sg.units_shipped > p.units_paid
),
OutputRows AS (
    SELECT
        0 AS sort_order,
        client_name AS sort_client,
        shipment_date AS sort_date,
        shipment_note_id AS sort_note_id,
        CAST(shipment_note_id AS NVARCHAR(20)) AS [Накладная №],
        client_name AS [Заказчик],
        address AS [Адрес],
        shipment_date AS [Дата отгрузки],
        goods_name AS [Наименование изделия],
        underpayment AS [Недооплата]
    FROM
        ReportRows
    UNION
    ALL
    SELECT
        1 AS sort_order,
        NULL AS sort_client,
        NULL AS sort_date,
        NULL AS sort_note_id,
        N'Итого' AS [Накладная №],
        NULL AS [Заказчик],
        NULL AS [Адрес],
        NULL AS [Дата отгрузки],
        NULL AS [Наименование изделия],
        SUM(underpayment) AS [Недооплата]
    FROM
        ReportRows
)
SELECT
    [Накладная №],
    [Заказчик],
    [Адрес],
    [Дата отгрузки],
    [Наименование изделия],
    [Недооплата]
FROM
    OutputRows
ORDER BY
    sort_order,
    sort_client,
    sort_date;

-- не оплаченные доставленные товары и их стоимость
SELECT
    sg.shipped_goods_id,
    c.name AS client_name,
    g.goods_name,
    sg.units_shipped,
    SUM(pnsg.units_paid) AS total_units_paid,
    sg.units_shipped - SUM(pnsg.units_paid) AS units_unpaid,
    sg.factual_price_per_unit,
    (
        sg.units_shipped - SUM(pnsg.units_paid)
    ) * sg.factual_price_per_unit AS unpaid_amount
FROM
    Shipped_goods sg
    JOIN Goods g ON sg.goods_id = g.goods_id
    JOIN Shipment_notes sn ON sg.shipment_note_id = sn.shipment_note_id
    JOIN Clients c ON sn.client_id = c.client_id
    LEFT JOIN Payment_notes_Shipped_goods pnsg ON sg.shipped_goods_id = pnsg.shipped_goods_id
GROUP BY
    sg.shipped_goods_id,
    c.name,
    g.goods_name,
    sg.units_shipped,
    sg.factual_price_per_unit
HAVING
    sg.units_shipped > SUM(pnsg.units_paid);

-- накладные с клиентами

SELECT 
    sn.shipment_note_id,
    sn.shipment_date,
    c.client_id,
    c.name AS client_name,
    c.address
FROM Shipment_notes sn
JOIN Clients c 
    ON sn.client_id = c.client_id;

-- все товары с доставками и клиентами

SELECT 
    sg.shipped_goods_id,
    sn.shipment_note_id,
    sn.shipment_date,
    c.name AS client_name,
    g.goods_name,
    g.unit,
    sg.units_shipped,
    sg.factual_price_per_unit,
    sg.units_shipped * sg.factual_price_per_unit AS shipped_total
FROM Shipped_goods sg
JOIN Goods g 
    ON sg.goods_id = g.goods_id
JOIN Shipment_notes sn 
    ON sg.shipment_note_id = sn.shipment_note_id
JOIN Clients c 
    ON sn.client_id = c.client_id;

-- стоимость всех товаров в накладной

SELECT 
    sn.shipment_note_id,
    sn.shipment_date,
    c.name AS client_name,
    SUM(sg.units_shipped * sg.factual_price_per_unit) AS shipment_total
FROM Shipment_notes sn
JOIN Clients c 
    ON sn.client_id = c.client_id
JOIN Shipped_goods sg 
    ON sn.shipment_note_id = sg.shipment_note_id
GROUP BY 
    sn.shipment_note_id,
    sn.shipment_date,
    c.name;

-- все оплаты с клиентами

SELECT 
    pn.payment_note_id,
    pn.[date] AS payment_date,
    c.client_id,
    c.name AS client_name
FROM Payment_notes pn
JOIN Clients c 
    ON pn.client_id = c.client_id;

-- стоимость оплаты

SELECT 
    pn.payment_note_id,
    pn.[date] AS payment_date,
    c.name AS client_name,
    SUM(pnsg.units_paid * sg.factual_price_per_unit) AS payment_total
FROM Payment_notes pn
JOIN Clients c 
    ON pn.client_id = c.client_id
JOIN Payment_notes_Shipped_goods pnsg 
    ON pn.payment_note_id = pnsg.payment_note_id
JOIN Shipped_goods sg 
    ON pnsg.shipped_goods_id = sg.shipped_goods_id
GROUP BY 
    pn.payment_note_id,
    pn.[date],
    c.name;

-- стоимость доставленных товаров, всех товаров и задолженность по всем клиентам

WITH ShippedTotals AS
(
    SELECT 
        sn.client_id,
        SUM(sg.units_shipped * sg.factual_price_per_unit) AS total_shipped
    FROM Shipment_notes sn
    JOIN Shipped_goods sg 
        ON sn.shipment_note_id = sg.shipment_note_id
    GROUP BY sn.client_id
),
PaidTotals AS
(
    SELECT 
        pn.client_id,
        SUM(pnsg.units_paid * sg.factual_price_per_unit) AS total_paid
    FROM Payment_notes pn
    JOIN Payment_notes_Shipped_goods pnsg 
        ON pn.payment_note_id = pnsg.payment_note_id
    JOIN Shipped_goods sg 
        ON pnsg.shipped_goods_id = sg.shipped_goods_id
    GROUP BY pn.client_id
)
SELECT 
    c.client_id,
    c.name AS client_name,
    ISNULL(st.total_shipped, 0) AS total_shipped,
    ISNULL(pt.total_paid, 0) AS total_paid,
    ISNULL(st.total_shipped, 0) - ISNULL(pt.total_paid, 0) AS outstanding_balance
FROM Clients c
LEFT JOIN ShippedTotals st 
    ON c.client_id = st.client_id
LEFT JOIN PaidTotals pt 
    ON c.client_id = pt.client_id;

-- оплаченные и неоплаченные доставленные товары
SELECT 
    pn.payment_note_id,
    pn.[date] AS payment_date,
    c.name AS client_name,
    g.goods_name,
    pnsg.units_paid,
    sg.factual_price_per_unit,
    pnsg.units_paid * sg.factual_price_per_unit AS paid_total
FROM Payment_notes_Shipped_goods pnsg
JOIN Payment_notes pn 
    ON pnsg.payment_note_id = pn.payment_note_id
JOIN Shipped_goods sg 
    ON pnsg.shipped_goods_id = sg.shipped_goods_id
JOIN Goods g 
    ON sg.goods_id = g.goods_id
JOIN Clients c 
    ON pn.client_id = c.client_id;
