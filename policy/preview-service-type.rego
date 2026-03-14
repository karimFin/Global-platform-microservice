package main

deny[msg] {
  input.kind == "Service"
  startswith(input.metadata.namespace, "pr-")
  input.spec.type == "LoadBalancer"
  input.metadata.name != "api-gateway"
  msg := sprintf("service %s in namespace %s cannot be LoadBalancer in preview", [input.metadata.name, input.metadata.namespace])
}
