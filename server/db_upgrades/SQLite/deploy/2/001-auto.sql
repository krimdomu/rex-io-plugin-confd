-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Wed Dec  2 19:44:07 2015
-- 

;
BEGIN TRANSACTION;
--
-- Table: entries
--
CREATE TABLE entries (
  id varchar(500) NOT NULL,
  value varchar(5000) NOT NULL,
  ttl integer,
  created integer,
  check_url varchar,
  check_freq integer,
  check_flap integer,
  PRIMARY KEY (id)
);
COMMIT;
