help: ## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST) | column -tl 2

pull-images: ## Pull the needed docker images.
	docker pull postgres:15-alpine

create-db: ## Create the database.
	docker exec -it postgres15  createdb --username=root --owner=root simple_bank

drop-db: ## Drop the database.
	docker exec -it postgres15  dropdb simple_bank

migrate-up: ## Apply all up migrations.
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up

migrate-down: ## Apply all down migrations.
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose down

# https://hub.docker.com/_/postgres
start-postgres: ## Start postgresql database docker image.
	docker run --name postgres15 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:15-alpine

stop-postgres: ## Stop postgresql database docker image.
	docker stop postgres15

run-postgres-cli:    ## Run psql on the postgres15 docker container.
	docker exec -it -u root postgres15 psql

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

.PHONY: start-postgres stop-postgres create-db drop-db migrate-up migrate-down run-postgres-cli docker-system-clean sqlc test mock
