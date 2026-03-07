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

infra-init:
	bash scripts/devctl.sh init

infra-plan:
	bash scripts/devctl.sh plan

infra-apply:
	bash scripts/devctl.sh apply

infra-destroy:
	bash scripts/devctl.sh destroy

infra-status:
	bash scripts/devctl.sh status

kubeconfig-dev:
	bash scripts/devctl.sh kubeconfig

secret-kube-dev:
	bash scripts/devctl.sh secret

deploy-dev:
	bash scripts/devctl.sh deploy

infra-apply-ci:
	bash scripts/devctl.sh ci-apply

infra-destroy-ci:
	bash scripts/devctl.sh ci-destroy

ship-dev:
	bash scripts/devctl.sh ship-dev

up-dev:
	bash scripts/devctl.sh up
