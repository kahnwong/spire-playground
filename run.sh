#!/bin/bash

kubectl apply -f manifests/01-spire-namespace.yaml

kubectl apply \
	-f manifests/02-server-account.yaml \
	-f manifests/02-spire-bundle-configmap.yaml \
	-f manifests/02-server-cluster-role.yaml

kubectl apply \
	-f manifests/03-server-configmap.yaml \
	-f manifests/03-server-statefulset.yaml \
	-f manifests/03-server-service.yaml

kubectl apply \
	-f manifests/04-agent-account.yaml \
	-f manifests/04-agent-cluster-role.yaml

kubectl apply \
	-f manifests/05-agent-configmap.yaml \
	-f manifests/05-agent-daemonset.yaml

# node registration
kubectl exec -n spire spire-server-0 -- \
	/opt/spire/bin/spire-server entry create \
	-spiffeID spiffe://example.org/ns/spire/sa/spire-agent \
	-selector k8s_psat:cluster:demo-cluster \
	-selector k8s_psat:agent_ns:spire \
	-selector k8s_psat:agent_sa:spire-agent \
	-node

# workload registration
kubectl exec -n spire spire-server-0 -- \
	/opt/spire/bin/spire-server entry create \
	-spiffeID spiffe://example.org/ns/default/sa/default \
	-parentID spiffe://example.org/ns/spire/sa/spire-agent \
	-selector k8s:ns:default \
	-selector k8s:sa:default

# Configure a Workload Container to Access SPIRE
kubectl apply -f manifests/06-client-deployment.yaml

# verify that container can access the socket
kubectl exec -it $(kubectl get pods -o=jsonpath='{.items[0].metadata.name}' \
	-l app=client) -- /opt/spire/bin/spire-agent api fetch -socketPath /run/spire/sockets/agent.sock
