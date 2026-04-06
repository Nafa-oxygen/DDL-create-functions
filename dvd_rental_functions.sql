/* =========================================================
   TASK 1: VIEW - sales_revenue_by_category_qtr
   ========================================================= */

-- This view calculates total revenue per category
-- for the CURRENT QUARTER of the CURRENT YEAR

CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT 
    c.category_id,
    c.name AS category_name,
    SUM(p.amount) AS total_revenue
FROM payment p
INNER JOIN rental r ON p.rental_id = r.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film_category fc ON i.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
WHERE 
    EXTRACT(QUARTER FROM p.payment_date) = EXTRACT(QUARTER FROM CURRENT_DATE)
    AND EXTRACT(YEAR FROM p.payment_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY c.category_id, c.name
HAVING SUM(p.amount) > 0
ORDER BY total_revenue DESC;

-- Usage example:
SELECT * FROM sales_revenue_by_category_qtr;

-- Sample output:
-- category_id | category_name | total_revenue
-- 15          | Sports        | 14306.22
-- 2           | Animation     | 13864.00


/* =========================================================
   TASK 2: FUNCTION - get_sales_revenue_by_category_qtr
   ========================================================= */

-- This function returns revenue by category for a given quarter (1–4)
-- for the CURRENT YEAR

CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(qtr INT)
RETURNS TABLE (
    category_id INT,
    category_name TEXT,
    total_revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.category_id,
        c.name AS category_name,
        SUM(p.amount) AS total_revenue
    FROM payment p
    INNER JOIN rental r ON p.rental_id = r.rental_id
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film_category fc ON i.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
    WHERE 
        EXTRACT(QUARTER FROM p.payment_date) = qtr
        AND EXTRACT(YEAR FROM p.payment_date) = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY c.category_id, c.name
    HAVING SUM(p.amount) > 0
    ORDER BY total_revenue DESC;
END;
$$;

-- Usage example:
SELECT * FROM get_sales_revenue_by_category_qtr(2);

-- Sample output:
-- category_id | category_name | total_revenue
-- 1           | Action        | 12000.50


/* =========================================================
   TASK 3: PROCEDURE - new_movie
   ========================================================= */

-- This procedure inserts a new movie with random values
-- and validates that "Klingon" language exists

CREATE OR REPLACE PROCEDURE new_movie(movie_title TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    lang_id INT;
BEGIN
    -- Check if Klingon language exists
    SELECT language_id INTO lang_id
    FROM language
    WHERE name = 'Klingon';

    IF lang_id IS NULL THEN
        RAISE EXCEPTION 'Klingon language does not exist in language table';
    END IF;

    -- Insert new movie with required random values
    INSERT INTO film (
        title,
        rental_rate,
        rental_duration,
        replacement_cost,
        release_year,
        language_id
    )
    VALUES (
        movie_title,
        (random() * 99 + 1)::NUMERIC(5,2),   -- 1 to 100
        (floor(random() * 10) + 1)::INT,     -- 1 to 10
        (random() * 49 + 1)::NUMERIC(5,2),   -- 1 to 50
        EXTRACT(YEAR FROM CURRENT_DATE),     -- current year
        lang_id
    );
END;
$$;

-- Usage example:
CALL new_movie('My New Film');

-- Verify insertion:
SELECT title, release_year FROM film WHERE title = 'My New Film';
