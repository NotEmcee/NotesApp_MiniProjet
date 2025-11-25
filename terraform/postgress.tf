
resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name = "postgres-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "notes-db" # 
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "notes-db"
      }
    }
    template {
      metadata {
        labels = {
          app = "notes-db"
        }
      }
      spec {
        container {
          image = "postgres:13-alpine"
          name  = "postgres"
          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "password"
          }
          env {
            name  = "POSTGRES_DB"
            value = "notesdb"
          }
          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }
        }
        volume {
          name = "postgres-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_pvc.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "notes-db"
  }
  spec {
    selector = {
      app = "notes-db"
    }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}
