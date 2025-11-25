
resource "kubernetes_deployment" "backend" {
  metadata {
    name = "notes-api" 
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "notes-api"
      }
    }
    template {
      metadata {
        labels = {
          app = "notes-api"
        }
      }
      spec {
        container {
      
          image = "ilyaslog/notes-api:latest"
          name  = "notes-api"
          image_pull_policy = "Always"

    

          port {
            container_port = 5000
          }
          
          
          env {
            name  = "DB_HOST"
            value = "notes-db"
          }
          env {
             name = "DB_PASSWORD"
             value = "password"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "notes-api"
  }
  spec {
    selector = {
      app = "notes-api"
    }
    port {
      port        = 5000
      target_port = 5000
    }
  }
}
