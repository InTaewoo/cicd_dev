resource "kubernetes_service" "this" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = {
      app = var.label
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
