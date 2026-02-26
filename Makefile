SERVICES := api-gateway identity seller catalog search pricing inventory cart checkout payments orders fulfillment notifications reviews analytics

dev:
	docker compose up --build

down:
	docker compose down -v

test:
	@for svc in \; do \n		(cd services/E8svc && npm test) || exit 1; \n	done
