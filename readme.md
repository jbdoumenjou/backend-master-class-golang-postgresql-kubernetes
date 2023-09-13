![Tests](https://github.com/jbdoumenjou/backend-master-class-golang-postgresql-kubernetes/actions/workflows/ci.yml/badge.svg)

This repository contains all notes and experimentation
following the Udemy course [Backend Master Class [Golang + Postgres + Kubernetes + gRPC]](https://www.udemy.com/course/backend-master-class-golang-postgresql-kubernetes/)

# Usage

Use the Makefile to launch and use the database.
```shell
$make help
help:                 Show this help.
pull-images:          Pull the needed docker images.
create-db:            Create the database.
drop-db:              Drop the database.
migrate-up:           Apply all up migrations.
migrate-up-1:         Apply the last up migration.
migrate-down:         Apply all down migrations.
migrate-down-1:       Apply the last down migration.
start-postgres:       Start postgresql database docker image.
stop-postgres:        Stop postgresql database docker image.
run-postgres-cli:     Run psql on the postgres15 docker container.
sqlc:                 sqlc generate.
docker-system-clean:  Docker system clean.
test:                 Test go files and report coverage.
server:               Run the application server.
mock:                 Generate a store mock.
```

# DataBase

* Use https://dbdiagram.io/ to create a schema, then export it in SQL
* Chose a client like:
    * [psql cli](https://www.postgresql.org/docs/13/app-psql.html)
    * [dbeaver](https://dbeaver.io/)
    * Goland data source
* A docker command line has been configured in the Makefile.
  Following this configuration,
  the attributes to use in the DB client are: `basename: root`, `user: root`, `password: secret`, `url: localhost:5432`

## ORM or Not ?

There are several choices to interact with the database from the code:
* using database/sql package and writing SQL requests by hand.
* using an orm like [gorm](https://github.com/go-gorm/gorm).
* slqx an in-between, providing some function but is not an ORM
* [sqlc](https://github.com/sqlc-dev/sqlc) another in-between but well suited for postgresql.

In this course, we will use sqlc.

## Driver

* https://github.com/lib/pq
```shell
go get github.com/lib/pq
```

## Migration 

Install [golang-migrate](https://github.com/golang-migrate/migrate) 
```shell
 go install github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

I had an issue with this installation: ` error: database driver: unknown driver postgresql (forgotten import?)`.  
I re-install with the following [command](https://github.com/golang-migrate/migrate/tree/master/cmd/migrate#versioned):
```shell
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```
It seems to fix the issue.

Create a folder db/migration to store migration.
Initialize schema migration management:
```shell
migrate create -ext sql -dir db/migration -seq init_schema
```

Add users:

```shell
migrate create -ext sql -dir db/migration -seq add_users
```

## Manage DB locks

Add log/data inside code to identify the queries order, then you can replay this sequence in another client.
Then, you can use specific [psql query](https://wiki.postgresql.org/wiki/Lock_Monitoring) to find the deadlock and some data about it.
```sql
  SELECT blocked_locks.pid     AS blocked_pid,
         blocked_activity.usename  AS blocked_user,
         blocking_locks.pid     AS blocking_pid,
         blocking_activity.usename AS blocking_user,
         blocked_activity.query    AS blocked_statement,
         blocking_activity.query   AS current_statement_in_blocking_process
   FROM  pg_catalog.pg_locks         blocked_locks
    JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
    JOIN pg_catalog.pg_locks         blocking_locks 
        ON blocking_locks.locktype = blocked_locks.locktype
        AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
        AND blocking_locks.pid != blocked_locks.pid

    JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
   WHERE NOT blocked_locks.granted;
```
Query adapted for our use case. We are searching for the first account balance deadlock.
We only have one base with 2 concurrents queries.
```sql
SELECT a.datname,
        a.application_name,
         l.relation::regclass,
         l.transactionid,
         l.mode,
         l.locktype,
         l.GRANTED,
         a.usename,
         a.query,
         a.pid
FROM pg_stat_activity a
JOIN pg_locks l ON l.pid = a.pid
ORDER BY a.pid;
```

## Isolation Level

>In database systems, isolation determines how transaction integrity is visible to other users and systems.
>
>A lower isolation level increases the ability of many users to access the same data at the same time,
but increases the number of concurrency effects (such as dirty reads or lost updates) users might encounter.
Conversely, a higher isolation level reduces the types of concurrency effects that users may encounter,
but requires more system resources and increases the chances that one transaction will block another.
>
>Isolation is typically defined at database level as a property that defines how or when the changes made by one operation become visible to others.
On older systems, it may be implemented systemically, for example through the use of temporary tables.
In two-tier systems, a transaction processing (TP) manager is required to maintain isolation.
In n-tier systems (such as multiple websites attempting to book the last seat on a flight),
a combination of stored procedures and transaction management is required to commit the booking and send confirmation to the customer.
Isolation is one of the four ACID properties, along with atomicity, consistency and durability.

https://en.wikipedia.org/wiki/Isolation_(database_systems)


| Read phenomenon </br>____________</br>Isolation level | Dirty read | Non-repeatable read | 	Phantom read |
|-------------------------------------------------------|------------|---------------------|---------------|
| Serializable 	                                        | no         | 	no                 | 	no           |
| Repeatable read                                       | 	no        | 	no                 | 	yes          |
| Read committed                                        | 	no        | 	yes                | 	yes          |
| Read uncommitted                                      | 	yes       | 	yes                | 	yes          |

https://www.postgresql.org/docs/15/transaction-iso.html


# References

* https://dbdiagram.io/
* https://dbeaver.io/
* https://en.wikipedia.org/wiki/ACID
* https://en.wikipedia.org/wiki/American_National_Standards_Institute
* https://github.com/golang-migrate/migrate
* https://github.com/holistics/dbml/
* https://github.com/techschool/simplebank
* https://github.com/uber-go/mock
* https://go.dev/tour/
* https://hub.docker.com/_/postgres
* https://www.postgresql.org/docs/15/transaction-iso.html
* https://sqlc.dev/
* https://tableplus.com (not supported on Linux anymore)
* https://wiki.postgresql.org/wiki/Lock_Monitoring

# Notes

## DataBase Client installation

I chose dbeaver instead of Tableplus because it is no longer supported on Linux.
I had an issue with my arch Linux with the JDK version.
To fix it, check the available JDK then set the right one by using the following commands:
```shell
$archlinux-java status                                                                                      ✔ 
Available Java environments:
  java-20-OpenJDK
  java-8-openjdk/jre (default)
$sudo archlinux-java set java-20-openjdk
$archlinux-java status
Available Java environments:
  java-20-openjdk (default)
  java-8-OpenJDK/jre
```

