# Live streaming Oracle -> PostgreSQL

## Demo setup
As usual you can provision the environment by using: `./00-provision.sh`. 

This will create the following:

![architecture](/images/arch.jpg)

| Container | Port | Purpose | User | Password |
| --- | --- | --- | --- | --- |
| zookeeper | 2181 | | | |
| kafka | 9092 | | | |
| connect | 8083 | | | |
| oracle | 1521 | | oracle | password |
| | | | debezium | password |
| | | | demo | demo |
| postgres | 5432 | | postgres | password |

On Oracle a database called `demo` is created:
```
CREATE TABLE demo.customers (
  id NUMBER PRIMARY KEY,
  name VARCHAR2(100)
);
```

After everything is provisioned, wait at least 30 seconds to Kafka to create the topic. You can check if the topic is created by running: `docker exec -it kafka /kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic oracle.DEMO.CUSTOMERS --from-beginning`.

If you get the following message, then the topic is not created yet. Just try again.
```
[2025-12-17 12:58:11,664] WARN [Consumer clientId=console-consumer, groupId=console-consumer-40212] 
The metadata response from the cluster reported a recoverable issue with correlation id 2 : 
{oracle.DEMO.CUSTOMERS=LEADER_NOT_AVAILABLE} (org.apache.kafka.clients.NetworkClient)
```
When running the above command there should be no output unless a new record has been created in the Oracle `demo.customers` table.

## Demo flow
### Data replication
- Open two panes, one connecting to the Oracle container (`docker exec -it oracle sqlplus demo/demo@//localhost:1521/XEPDB1`),  one connecting to the Postgres container (`docker exec -it postgres psql -U postgres`).
- In the Oracle container, run `select * from customers;` to show that there are no records in the table.
- In the Postgres container, run `\dt` to see if the table is already created. It isn't and that is expected. Debezium is a DATA-driven solution. It will detect changes in DATA, not in SCHEMA.
- In the Oracle container, create a new record using `INSERT INTO customers VALUES (1, 'James');`and then `commit;`.
- In the Postgres container, run `\dt` again. Notice that the table is being created.
- In the Postgres container, run `select * from customers;` If you want you can follow this up with a `\watch` because we will be using this for a while.
- In the Oracle container, update the record using `update customers set name = 'Pepe' where id = 1;`and then `commit;`.
- In the Postgres container, run `select * from customers;` again.
- In the Oracle container, add a record using ìnser into customers values (2, 'Nancy');` and then `commit;`
- In the Postgres container, run `select * from customers;` again.
- In the Oracle container, run `delete from customers where id = 2;` and then `commit;`
- In the Postgres container, run `select * from customers;` again.

### Schema changes
- In the Oracle container, add a column to the customer table using `alter table customers add address varchar2(50);`
- Again, until you enter new data, the schema in Postgres doesn't get updated. On the Oracle contianer, insert a new record using `insert into customers values (2, 'Daniel', 'Street 12');` and then `commit;`

### Creation of new table
- In the Oracle container, create a new table using `create table products (id int primary key, description varchar2(50));`, then `insert into products values (1, 'Product 1');` and `commit;`
- In the Postgres container, enter `\dt` and then `select * from products;`.

## Demo deprovisioning
Use `./99-deprovision.sh` to deprovision this demo. 

> [!WARNING]
> Be carefull with `./99-deprovision.sh` because i do a `docker volume purge -f` which deletes all volumes from your docker environment.
> I do this because i could not make `docker compose down -v` to delete the volumes properly.
