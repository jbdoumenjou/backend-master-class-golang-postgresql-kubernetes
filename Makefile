.PHONY: start-postgres stop-postgres create-db drop-db migrate-up migrate-down run-postgres-cli docker-system-clean

pull-images:
	docker pull postgres:15-alpine

create-db:
	docker exec -it postgres15  createdb --username=root --owner=root simple_bank

drop-db:
	docker exec -it postgres15  dropdb simple_bank

migrate-up:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up

migrate-down:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose down

# https://hub.docker.com/_/postgres
start-postgres:
	docker run --name postgres15 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:15-alpine

stop-postgres:
	docker stop postgres15

run-postgres-cli:
	docker exec -it -u root postgres15 psql

docker-system-clean:
	docker system prune -f
