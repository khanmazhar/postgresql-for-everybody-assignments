-- This application will create two tables, and hand-load a small amount of data in the the tables while properly normalizing the data. 
-- creating tables
CREATE TABLE make (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE model (
  id SERIAL,
  name VARCHAR(128),
  make_id INTEGER REFERENCES make(id) ON DELETE CASCADE,
  PRIMARY KEY(id)
);

-- inserting data into the tables
INSERT INTO make(name) VALUES ('Lexus');
INSERT INTO make(name) VALUES ('Lincoln'); 

INSERT INTO model(name, make_id) VALUES ('RX 300',1);   
INSERT INTO model(name, make_id) VALUES ('RX 300 4WD',1);
INSERT INTO model(name, make_id) VALUES ('RX 330 2WD',1);
INSERT INTO model(name, make_id) VALUES ('Navigator 2WD FFV',2);  
INSERT INTO model(name, make_id) VALUES ('Navigator 4WD',2);  

-- selecting data from the two created tables using a JOIN statement
SELECT make.name, model.name
    FROM model
    JOIN make ON model.make_id = make.id
    ORDER BY make.name LIMIT 5;
