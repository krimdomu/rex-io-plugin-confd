-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Fri Nov 27 16:17:10 2015
-- 

;
BEGIN TRANSACTION;
--
-- Table: entries
--
CREATE TABLE entries (
  id varchar(500) NOT NULL,
  value varchar(5000) NOT NULL,
  PRIMARY KEY (id)
);
COMMIT;
