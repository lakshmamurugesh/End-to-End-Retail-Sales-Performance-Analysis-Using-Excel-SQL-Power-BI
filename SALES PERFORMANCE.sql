CREATE TABLE shipments (
    shipmentid VARCHAR,
    spid VARCHAR,
    pid VARCHAR,
    gid VARCHAR,
    shipdate DATE,
    amount NUMERIC,
    boxes INT,
    order_status VARCHAR
);
select*from shipments;


CREATE TABLE region (
    geo VARCHAR,
    region VARCHAR,
    gid VARCHAR
);
CREATE TABLE sales_person_details (
    sales_person VARCHAR,
    team VARCHAR,
    spid VARCHAR
);

CREATE TABLE products (
    product VARCHAR,
    category VARCHAR,
    cost_per_box VARCHAR,
    pid VARCHAR
);

select* from products;
select*from region;
select*from sales_person_details;

CREATE TABLE shipment_clean AS
SELECT DISTINCT
    TRIM(ShipmentID)            AS shipment_id,
    TRIM(SPID)                  AS spid,
    TRIM(PID)                   AS pid,
    TRIM(GID)                   AS gid,
    Shipdate::DATE              AS ship_date,
    ROUND(Amount::NUMERIC, 2)   AS amount,
    Boxes::INT                  AS boxes,
    INITCAP(TRIM(Order_Status)) AS order_status
FROM shipments
WHERE ShipmentID IS NOT NULL;

CREATE TABLE products_clean AS
SELECT DISTINCT
    TRIM(PID)                   AS pid,
    INITCAP(TRIM(Product))      AS product_name,
    INITCAP(TRIM(Category))     AS category,
    ROUND (
        REPLACE(TRIM(Cost_per_box), '$', '')::NUMERIC,
        2
    ) AS cost_per_box
FROM products
WHERE PID IS NOT NULL;

CREATE TABLE region_clean AS
SELECT DISTINCT
    TRIM(GID)              AS gid,
    INITCAP(TRIM(Geo))     AS country,
    INITCAP(TRIM(Region))  AS region
FROM region
WHERE GID IS NOT NULL;

CREATE TABLE sales_person_clean AS
SELECT DISTINCT
    TRIM(SPID)                     AS spid,
    INITCAP(TRIM(Sales_person))    AS sales_person,
    INITCAP(TRIM(Team))            AS team
FROM sales_person_details
WHERE SPID IS NOT NULL;

ALTER TABLE shipment_clean ADD PRIMARY KEY (shipment_id);
ALTER TABLE products_clean ADD PRIMARY KEY (pid);
ALTER TABLE region_clean ADD PRIMARY KEY (gid);
ALTER TABLE sales_person_clean ADD PRIMARY KEY (spid);

ALTER TABLE shipment_clean
ADD CONSTRAINT fk_product FOREIGN KEY (pid) REFERENCES products_clean(pid);

ALTER TABLE shipment_clean
ADD CONSTRAINT fk_region FOREIGN KEY (gid) REFERENCES region_clean(gid);

ALTER TABLE shipment_clean
ADD CONSTRAINT fk_sales_person FOREIGN KEY (spid) REFERENCES sales_person_clean(spid);

SELECT COUNT(*) FROM shipment_clean;

SELECT MIN(ship_date), MAX(ship_date) FROM shipment_clean;

SELECT
    COUNT(*) FILTER (WHERE amount IS NULL) AS null_amounts,
    COUNT(*) FILTER (WHERE boxes IS NULL) AS null_boxes
FROM shipment_clean;

SELECT order_status, COUNT(*)
FROM shipment_clean
GROUP BY order_status;

SELECT
    DATE_TRUNC('month', ship_date) AS month,
    SUM(amount) AS revenue
FROM shipment_clean
GROUP BY month
ORDER BY month;

SELECT SUM(amount) AS total_revenue FROM shipment_clean;

SELECT SUM(boxes) AS total_boxes FROM shipment_clean;

SELECT ROUND(AVG(amount), 2) AS avg_order_value
FROM shipment_clean;

SELECT
    sp.sales_person,
    SUM(s.amount) AS total_sales
FROM shipment_clean s
JOIN sales_person_clean sp ON s.spid = sp.spid
GROUP BY sp.sales_person
ORDER BY total_sales DESC;

SELECT
    SUM(s.amount) AS revenue,
    SUM(s.boxes * p.cost_per_box) AS total_cost,
    SUM(s.amount - (s.boxes * p.cost_per_box)) AS profit
FROM shipment_clean s
JOIN products_clean p ON s.pid = p.pid;

SELECT
    r.region,
    SUM(s.amount) AS revenue
FROM shipment_clean s
JOIN region_clean r ON s.gid = r.gid
GROUP BY r.region
ORDER BY revenue DESC;

SELECT
    p.product_name,
    SUM(s.amount) AS revenue
FROM shipment_clean s
JOIN products_clean p ON s.pid = p.pid
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;













