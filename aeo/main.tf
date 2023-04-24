resource "helm_release" "postgres" {
  name       = "postgres"
  repository = "bitnami/postgresql"
  
  namespace  = var.NAMESPACE
  create_namespace = true

  set {
    name  = "global.postgresql.auth.postgresPassword"
    value = var.POSTGRESQL_PASSWORD
  }

  set {
    name  = "global.postgresql.auth.username"
    value = var.POSTGRESQL_USERNAME
  }

 set {
    name  = "global.postgresql.auth.password"
    value = var.POSTGRESQL_PASSWORD
  }

   set {
    name  = "global.postgresql.auth.database"
    value = "postgres"
  }
  set {
    name  = "primary.initdb.scripts.create-database\\.sql"
    value = "${file("database/aeo_4.3.1.60.sql")}"
   }
} 
/*
resource "helm_release" "aeo_4.3.1.61" {
  name       = "aeo_4.3.1.61"
  chart      = "${path.module}/helm/aeo-4.3.1"
  namespace  = var.NAMESPACE
  create_namespace = true

  set {
    name  = "scheduler.image"
    value = "${var.KUBE_LOCALREGISTRY_HOST}:${var.KUBE_LOCALREGISTRY_PORT}/${var.IMAGE_SCHEDULER_NAME}:${var.IMAGE_SCHEDULER_VERSION}"
  }

 set {
    name  = "scheduler.enabled"
    value = "true"
  }  

  set {
    name  = "clientmgr.image"
    value = "${var.KUBE_LOCALREGISTRY_HOST}:${var.KUBE_LOCALREGISTRY_PORT}/${var.IMAGE_CLIENTMGR_NAME}:${var.IMAGE_CLIENTMGR_VERSION}"
  }
  set {
    name  = "database.driver"
    value = "org.postgresql.Driver"
  }

  set {
    name  = "database.type"
    value = "POSTGRESQL"
  }
  set {
    name  = "database.url"
    value = "jdbc:postgresql://${var.POSTGRESQL_HOST}:${var.POSTGRESQL_PORT}/${var.POSTGRESQL_DBNAME}"
  }
  set {
    name  = "database.name"
    value = var.POSTGRESQL_DBNAME
  }
  set {
    name  = "database.server"
    value = var.POSTGRESQL_HOST
  }
   set {
    name  = "database.password"
    value = var.POSTGRESQL_PASSENCR
  }
   depends_on = [helm_release.postgres]
}
*/
