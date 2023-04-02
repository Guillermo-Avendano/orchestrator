resource "helm_release" "rteweb" {
  name       = "rteweb"
  chart      = "${path.module}/helm/rte-10.05"
  namespace  = "bna"
  create_namespace = true

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "ingress.hosts[0].host"
    value = "rte.bna.com"
  }
  values = [
    "${file("${path.module}/helm/rte-10.05/values-test.yaml")}"
  ]
}
