-- Run after mock_data is loaded and sql/01_DDL.sql is applied

INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name FROM mock_data WHERE customer_country IS NOT NULL AND customer_country <> ''
    UNION
    SELECT seller_country FROM mock_data WHERE seller_country IS NOT NULL AND seller_country <> ''
    UNION
    SELECT store_country FROM mock_data WHERE store_country IS NOT NULL AND store_country <> ''
    UNION
    SELECT supplier_country FROM mock_data WHERE supplier_country IS NOT NULL AND supplier_country <> ''
) AS countries;

INSERT INTO dim_pet_category (category_name)
SELECT DISTINCT pet_category
FROM mock_data
WHERE pet_category IS NOT NULL AND pet_category <> '';

INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category IS NOT NULL AND product_category <> '';

INSERT INTO dim_pet (pet_type, pet_name, pet_breed, pet_category_id)
SELECT DISTINCT
    m.customer_pet_type,
    m.customer_pet_name,
    m.customer_pet_breed,
    pc.pet_category_id
FROM mock_data m
LEFT JOIN dim_pet_category pc ON pc.category_name = m.pet_category;

INSERT INTO dim_customer (
    source_customer_id,
    first_name,
    last_name,
    age,
    email,
    postal_code,
    country_id,
    pet_id
)
SELECT DISTINCT ON (m.sale_customer_id)
    m.sale_customer_id,
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    NULLIF(m.customer_postal_code, ''),
    c.country_id,
    p.pet_id
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.customer_country
LEFT JOIN dim_pet_category pc ON pc.category_name = m.pet_category
LEFT JOIN dim_pet p
    ON p.pet_type = m.customer_pet_type
   AND p.pet_name = m.customer_pet_name
   AND p.pet_breed = m.customer_pet_breed
   AND p.pet_category_id = pc.pet_category_id
ORDER BY m.sale_customer_id, m.id;

INSERT INTO dim_seller (
    source_seller_id,
    first_name,
    last_name,
    email,
    postal_code,
    country_id
)
SELECT DISTINCT ON (m.sale_seller_id)
    m.sale_seller_id,
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    NULLIF(m.seller_postal_code, ''),
    c.country_id
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.seller_country
ORDER BY m.sale_seller_id, m.id;

INSERT INTO dim_product (
    source_product_id,
    product_name,
    price,
    weight,
    color,
    size,
    brand,
    material,
    description,
    rating,
    reviews,
    release_date,
    expiry_date,
    category_id
)
SELECT DISTINCT ON (m.sale_product_id)
    m.sale_product_id,
    m.product_name,
    m.product_price,
    m.product_weight,
    m.product_color,
    m.product_size,
    m.product_brand,
    m.product_material,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    TO_DATE(NULLIF(m.product_release_date, ''), 'MM/DD/YYYY'),
    TO_DATE(NULLIF(m.product_expiry_date, ''), 'MM/DD/YYYY'),
    pc.product_category_id
FROM mock_data m
LEFT JOIN dim_product_category pc ON pc.category_name = m.product_category
ORDER BY m.sale_product_id, m.id;

INSERT INTO dim_supplier (name, contact, email, phone, address, city, country_id)
SELECT DISTINCT
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    m.supplier_city,
    c.country_id
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.supplier_country;

INSERT INTO dim_store (name, location, city, state, phone, email, country_id)
SELECT DISTINCT
    m.store_name,
    m.store_location,
    m.store_city,
    m.store_state,
    m.store_phone,
    m.store_email,
    c.country_id
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.store_country;

INSERT INTO fact_sales (
    source_row_id,
    sale_date,
    customer_id,
    seller_id,
    product_id,
    store_id,
    supplier_id,
    quantity,
    total_price
)
SELECT
    m.id,
    TO_DATE(m.sale_date, 'MM/DD/YYYY'),
    dc.customer_id,
    ds.seller_id,
    dp.product_id,
    dst.store_id,
    dsup.supplier_id,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
JOIN dim_customer dc ON dc.source_customer_id = m.sale_customer_id
JOIN dim_seller ds ON ds.source_seller_id = m.sale_seller_id
JOIN dim_product dp ON dp.source_product_id = m.sale_product_id
LEFT JOIN dim_store dst
    ON dst.name = m.store_name
   AND dst.email = m.store_email
   AND dst.phone = m.store_phone
LEFT JOIN dim_supplier dsup
    ON dsup.name = m.supplier_name
   AND dsup.email = m.supplier_email
   AND dsup.phone = m.supplier_phone;
