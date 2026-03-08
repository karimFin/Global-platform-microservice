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

lint:
	npm run lint
	npm --prefix frontend run lint

format-check:
	npm --prefix frontend run format

format-fix:
	cd frontend && npx prettier . --write

format-fix-cart:
	cd frontend && npx prettier apps/web/app/cart/page.js --write

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

infra-cleanup-ci:
	bash scripts/devctl.sh ci-cleanup

ship-dev:
	bash scripts/devctl.sh ship-dev

up-dev:
	bash scripts/devctl.sh up

grafana-install:
	kubectl create secret generic grafana-admin -n observability --from-literal=username=admin --from-literal=password=adminadmin --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -k platform/k8s/observability/grafana

grafana-port-forward:
	kubectl -n observability port-forward svc/grafana 3000:3000

grafana-uninstall:
	kubectl delete -k platform/k8s/observability/grafana --ignore-not-found=true
