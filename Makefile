DB_URL=postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable

help: ## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST) | column -tl 2

pull-images: ## Pull the needed docker images.
	docker pull postgres:15-alpine

create-network: ## Create the bank-network.
	docker network create bank-network

create-db: ## Create the database.
	docker exec -it postgres15 createdb --username=root --owner=root simple_bank

drop-db: ## Drop the database.
	docker exec -it postgres15  dropdb simple_bank

migrate-up: ## Apply all up migrations.
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrate-up-1: ## Apply the last up migration.
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migrate-down: ## Apply all down migrations.
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migrate-down-1: ## Apply the last down migration.
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

# https://hub.docker.com/_/postgres
start-postgres: ## Start postgresql database docker image.
	docker run --name postgres15 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:15-alpine

stop-postgres: ## Stop postgresql database docker image.
	docker stop postgres15

run-postgres-cli:    ## Run psql on the postgres15 docker container.
	docker exec -it -u root postgres15 psql

db-docs: ## Generate the database documentation.
	dbdocs build doc/db.dbml

db-schema: ## Generate the database schema.
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

sqlc: ## sqlc generate.
	sqlc generate

docker-system-clean: ## Docker system clean.
	docker system prune -f

test: ## Test go files and report coverage.
	go test -v -cover ./...

server: ## Run the application server.
	go run main.go

mock: ## Generate a store mock.
	mockgen -package mockdb -destination db/mock/store.go github.com/jbdoumenjou/simplebank/db/sqlc Store

proto: ## Generate the protobuf files.
	rm -rf pb/*.go
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
	--go-grpc_out=pb --go-grpc_opt=paths=source_relative \
	proto/*.proto


build-docker-image: ## Build the Docker image.
	docker build -t simplebank:latest .

.PHONY: start-postgres stop-postgres create-db drop-db migrate-up migrate-down run-postgres-cli \
 docker-system-clean sqlc test mock migrate-up-1 migrate-down-1 db-docs db-schema proto
