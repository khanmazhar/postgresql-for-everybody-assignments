-- Altering table schemas
CREATE TABLE account (
    id SERIAL,
    email VARCHAR(128) UNIQUE,
    created_at DATE NOT NULL DEFAULT NOW(),
    updated_at DATE NOT NULL DEFAULT NOW(),
    PRIMARY KEY(id)
);

CREATE TABLE post (
    id SERIAL,
    title VARCHAR(128) UNIQUE NOT NULL,
    content VARCHAR(1024), --will extent in ALTER
    account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEy(id)
);

--altering
ALTER TABLE post ALTER COLUMN content TYPE TExT;


-- DATES
-- Date Types: 
-- 1) DATE - 'YYYY:MM:DD'
-- 2) TIME - 'HH:MM:SS'
-- 3) TIMESTAMP - 'YYYY:MM:DD HH:MM:SS'
-- 4) TIMESTAMPTZ - 'TIMESTAMP with timezone'
-- Built-in Postgresql function - NOW()

-- casting in psql
SELECT NOW()::DATE, CAST(NOW() AS DATE), CAST(NOW() AS TIME);

-- date interval arthmetic
SELECT NOW(), NOW() - INTERVAL '2 days', (NOw() - INTERVAL '2 days')::DATE;

-- Date_trunc: Sometimes we want to truncate some of the accuracy in a data 
SELECT id, content, created_at 
FROM post
WHERE created_at >= DATE_TRUNC('day', NOW()) AND 
created_at <= DATE_TRUNC('day', NOW() + INTERVAL '1 day');

--Performance: Table Scans - Not all equivalent queries have the same performance
SELECT id, content, created_at 
FROM comment 
WHERE created_at::DATE = NOW()::DATE;

-- IN the above two queries, the second one is elegant to write but its performance is slow. The fast one runs faster than the second one. This has to do with the scond one doing a full table scan whereas the first one doing scan based on indexes



--DISTINCT/GROUP BY: 
--- DISTINCT: only returns the unique rows in a result set - and row will appear only once
--- DISTINCT ON - limits duplicate removal to a set of columns 
--- GROUP BY: combined with aggregate functions like SUM(), MAX(), MIN()
--EXAMPLES:
SELECT DISTINCT model FROM racing;
SELECT DISTINCT ON (model) model, make FROM racing;

SELECT COUNT(abbrev), abbrev FROM pg_timezone_names GROUP BY abbrev;
--Having clause
SELECT COUNT(abbrev), abbrev 
FROM pg_timezone_names
WHERE is_dist = 't'
GROUP BY abbrev
HAVING COUNT(abbrev) > 10;

--DEMONSTRATION: SELECT DISTINCT
CREATE TABLE racing (
    make VARCHAR,
    model VARCHAR,
    year INTEGER,
    price INTEGER
);

INSERT INTO racing (make, model, year, price)
VALUES 
    ('Nissan', 'Stanza', 1990, 2000),
    ('Dodge', 'Neon', 1995, 800),
    ('Dodge', 'Neon', 1998,2500),
    ('Dodge', 'Neon', 1999, 3000),
    ('Ford', 'Mustang', 2001, 1000),
    ('Ford', 'Mustang', 2005, 2000),
    ('Subaru', 'Impreza', 1997, 1000),
    ('Mazda', 'Miata', 2001, 5000),
    ('Mazda', 'Miata', 2001, 3000),
    ('Mazda', 'Miata', 2001, 2500),
    ('Mazda', 'Miata', 2002, 5500),
    ('Opel', 'GT', 1972, 1500),
    ('Opel', 'GT', 1969, 7500),
    ('Opel', 'Cadet', 1973,500);
    
SELECT DISTINCT make FROM racing;
SELECT DISTINCT make, model FROM racing;
SELECT DISTINCT ON (model) make, model,year FROM racing;

--SUBQUERIES: queries within queries
SELECT COUNT(abbrev) AS ct, abbrev FROM pg_timezone_names
WHERE is_dst='t' GROUP BY abbrev HAVING COUNT(abbrev) > 10;

-- writing the above query as a subquery
SELECT ct, abbrev FROM 
(
  SELECT COUNT(abbrev) AS ct, abbrev
  FROM pg_timezone_names
  WHERE is_dst = 't'
  GROUP BY abbrev
) AS zap
WHERE ct > 10;






