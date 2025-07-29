resource "kubernetes_namespace" "this" {
  metadata {
    annotations = {
      name = var.namespace
    }

    name = var.namespace
  }
}