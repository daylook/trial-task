output "nginx_ingress_release_name" {
  description = "Name of the NGINX Ingress Helm release"
  value       = helm_release.nginx_ingress.name
}

output "nginx_ingress_namespace" {
  description = "Namespace where NGINX Ingress is deployed"
  value       = helm_release.nginx_ingress.namespace
}

output "metrics_server_release_name" {
  description = "Name of the Metrics Server Helm release"
  value       = helm_release.metrics_server.name
}

output "metrics_server_namespace" {
  description = "Namespace where Metrics Server is deployed"
  value       = helm_release.metrics_server.namespace
}
