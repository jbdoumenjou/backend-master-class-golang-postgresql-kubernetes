
pull-images:
	docker pull postgres:15-alpine

# https://hub.docker.com/_/postgres
start-postgres:
	docker run --name postgres15 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:15-alpine

stop-postgres:
	docker stop postgres15 psql

run-postgres-cli:
	docker exec -it -u root postgres15 psql

docker-system-clean:
	docker system prune -f