all: up

up: build
	@docker run -d --name dragonmintz -p 3000:3000 dragonmintz:latest && docker logs -f dragonmintz || true

build:
	@docker build -t dragonmintz .

down:
	@docker stop dragonmintz

clean: down
	@docker rm -f dragonmintz

re: clean up

prune:
	@docker system prune -a

status:
	@clear
	@docker ps -a
	@echo ""
	@docker image ls
	@echo ""

.PHONY: all build down clean re prune status