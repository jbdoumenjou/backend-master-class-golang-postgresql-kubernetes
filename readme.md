This repository contains all notes and experimentation
following the Udemy course [Backend Master Class [Golang + Postgres + Kubernetes + gRPC]](https://www.udemy.com/course/backend-master-class-golang-postgresql-kubernetes/)

# DataBase

* Use https://dbdiagram.io/ to create a schema, then export it in SQL
* Chose a client like:
    * [psql cli](https://www.postgresql.org/docs/13/app-psql.html)
    * [dbeaver](https://dbeaver.io/)
    * Goland data source
* A docker command line has been configured in the Makefile.
  Following this configuration,
  the attributes to use in the DB client are: `basename: root`, `user: root`, `password: secret`, `url: localhost:5432`

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

# References

* https://dbdiagram.io/
* https://dbeaver.io/
* https://github.com/golang-migrate/migrate
* https://github.com/holistics/dbml/
* https://github.com/techschool/simplebank
* https://go.dev/tour/
* https://hub.docker.com/_/postgres
* https://tableplus.com (not supported on Linux anymore)

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





