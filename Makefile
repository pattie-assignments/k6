.PHONY: run docker-run pagination pagination-offset pagination-cursor

-include .env

# .env or make VAR=value를 통한 환경변수 설정
ifndef BASE_URL
$(error BASE_URL is not set. Copy .env.example to .env or run 'make pagination BASE_URL=http://your-host')
endif

run:
	k6 run loadtest/script.js

pagination:
	@if [ -z "$(TYPE)" ]; then \
		echo "Error: TYPE is not set. Use 'make pagination TYPE=offset' or 'make pagination-offset'"; \
		exit 1; \
	fi
	k6 run \
		-e BASE_URL=$(BASE_URL) \
		-e TYPE=$(TYPE) \
		-e LIMIT=$(LIMIT) \
		-e OFFSET=$(OFFSET) \
		-e CURSOR_DEPTH_PAGES=$(CURSOR_DEPTH_PAGES) \
		loadtest/pagination.js

pagination-offset: TYPE=offset
pagination-offset: pagination

pagination-cursor: TYPE=cursor
pagination-cursor: pagination

docker-run:
	docker build -t k6-test .
	docker run --rm k6-test
