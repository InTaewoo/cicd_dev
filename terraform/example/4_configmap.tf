locals {
  configmap_data = templatefile("${path.module}/index.html.tpl", {
    content = var.content
  })
}

resource "kubernetes_config_map" "this" {
  metadata {
    name      = "nginx-html"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    "index.html" = local.configmap_data
  }
}
