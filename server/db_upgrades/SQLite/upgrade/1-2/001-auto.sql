-- Convert schema 'db_upgrades\_source\deploy\1\001-auto.yml' to 'db_upgrades\_source\deploy\2\001-auto.yml':;

;
BEGIN;

;
ALTER TABLE entries ADD COLUMN ttl integer;

;
ALTER TABLE entries ADD COLUMN created integer;

;
ALTER TABLE entries ADD COLUMN check_url varchar;

;
ALTER TABLE entries ADD COLUMN check_freq integer;

;
ALTER TABLE entries ADD COLUMN check_flap integer;

;

COMMIT;

