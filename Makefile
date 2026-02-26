SERVICES := api-gateway identity seller catalog search pricing inventory cart checkout payments orders fulfillment notifications reviews analytics

dev:
	docker compose up --build

down:
	docker compose down -v

test:
	@set -e; \
	for svc in $(SERVICES); do \
		echo "Running tests for $$svc"; \
		( cd services/$$svc && npm ci && npm test ); \
	done
