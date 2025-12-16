-- ===========================================
-- Debezium CDC initialization for Oracle XE
-- ===========================================

-- 1. Open the PDB and save state
ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;
ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE;

-- 2. Switch to the PDB
ALTER SESSION SET CONTAINER=FREEPDB1;

-- 3. Create Debezium user if it doesn't exist
BEGIN
   EXECUTE IMMEDIATE 'CREATE USER debezium IDENTIFIED BY password';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -01920 THEN
         NULL; -- user already exists, ignore
      ELSE
         RAISE;
      END IF;
END;
/

-- 4. Grant required privileges
GRANT CREATE SESSION TO debezium;
GRANT CONNECT, LOGMINING, SELECT_CATALOG_ROLE TO debezium;

-- 5. Enable supplemental logging (required for CDC)
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;


-- Demo schema + table
CREATE USER demo IDENTIFIED BY demo;
GRANT CONNECT, RESOURCE TO demo;

ALTER USER demo QUOTA UNLIMITED ON USERS;

CREATE TABLE demo.customers (
  id NUMBER PRIMARY KEY,
  name VARCHAR2(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO demo.customers VALUES (1, 'Alice', CURRENT_TIMESTAMP);
COMMIT;

