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

--CONCURRENCY: Databases are designed to accept SQL commands from a variety of sources simultaneously and make them atomically.
--To implement atomicity, PostgreSQL command that might change an area of the database
--All other access to that area must wait until the area is unlocked
CREATE TABLE account (
  id SERIAL,
  email VARCHAR(128) UNIQUE,
  created_at DATE NOT NULL DEFAULT NOW(),
  updated_at DATE NOT NULL DEFAULT NOW(),
  PRIMARY KEY(id)
);

CREATE TABLE post (
  id SERIAL,
  title VARCHAR(128) UNIQUE NOT NULL, -- Will extend with ALTER
  content TEXT,
  account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY(id)
);

-- Allow multiple comments
CREATE TABLE comment (
  id SERIAL,
  content TEXT NOT NULL,
  account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
  post_id INTEGER REFERENCES post(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY(id)
);

CREATE TABLE fav (
  id SERIAL,
  post_id INTEGER REFERENCES post(id) ON DELETE CASCADE,
  account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(post_id, account_id),
  PRIMARY KEY(id)
);

-- Do this twice
INSERT INTO fav (post_id, account_id, howmuch)
  VALUES (1,1,1)
RETURNING *;

UPDATE fav SET howmuch=howmuch+1
  WHERE post_id = 1 AND account_id = 1
RETURNING *;

INSERT INTO fav (post_id, account_id, howmuch)
  VALUES (1,1,1)
  ON CONFLICT (post_id, account_id) 
  DO UPDATE SET howmuch = fav.howmuch + 1;

INSERT INTO fav (post_id, account_id, howmuch)
  VALUES (1,1,1)
  ON CONFLICT (post_id, account_id) 
  DO UPDATE SET howmuch = fav.howmuch + 1
RETURNING *;

--SINGLE SQL statements are also atomic
-- All the inserts will work and get a unique primary key
-- Which account gets which key is not predictable
-- The insert statementss has to line up. The database will process these one at a time
-- TRANSACTIONS (try in two windows)

BEGIN;
SELECT howmuch FROM fav WHERE account_id=1 AND post_id=1 FOR UPDATE OF fav;
-- Time passes... 
UPDATE fav SET howmuch=999 WHERE account_id=1 AND post_id=1;
SELECT howmuch FROM fav WHERE account_id=1 AND post_id=1;
ROLLBACK;
SELECT howmuch FROM fav WHERE account_id=1 AND post_id=1;

BEGIN;
SELECT howmuch FROM fav WHERE account_id=1 AND post_id=1 FOR UPDATE OF fav;
-- Time passes... 
UPDATE fav SET howmuch=999 WHERE account_id=1 AND post_id=1;
SELECT howmuch FROM fav WHERE account_id=1 AND post_id=1;
COMMIT;
SELECT howmuch FROM fav WHERE account_id=1 AND post_id=1;
-- Transactions and Performance: The implementation of transactions make a big difference in database performance

--STORED PROCEDURES:
--- A stored procedure is a bit of resuable code that runs inside of the database server.
---- Technically there are multiple language choices but just use 'plpqsql'
---- Generally quite non-portable
---- Usually the goal is to have fever SQL statements
---- You should have a strong reason to use a stored procedure 
----- Majore performance problem
----- Harder to test/modify
----- No database portability
----- Some rule that must be enforced

CREATE TABLE keyvalue ( 
  id SERIAL,
  key VARCHAR(128) UNIQUE,
  value VARCHAR(128) UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY(id)
);

--create a stored procedure
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON keyvalue
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();
--each time a value in keyvalue is changed, the updated_at value changes




