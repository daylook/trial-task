# NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.11.3"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [
    yamlencode({
      controller = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"                              = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
          }
        }
        ingressClassResource = {
          name            = "nginx"
          enabled         = true
          default         = true
          controllerValue = "k8s.io/ingress-nginx"
        }
        metrics = {
          enabled = true
        }
      }
    })
  ]

  depends_on = [var.cluster_ready]
}

# Metrics Server
resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = "3.12.2"
  namespace        = "kube-system"
  create_namespace = false

  values = [
    yamlencode({
      args = [
        "--kubelet-insecure-tls",
        "--kubelet-preferred-address-types=InternalIP"
      ]
      metrics = {
        enabled = true
      }
    })
  ]

  depends_on = [var.cluster_ready]
}
