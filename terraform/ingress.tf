resource "kubernetes_ingress_v1" "notes_ingress" {
  metadata {
    name = "notes-ingress"
    annotations = {
       
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      
      host = "notes.192.168.49.2.nip.io" 
      http {
       
        path {
          path = "/api(/|$)(.*)"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "notes-api"
              port {
                number = 5000
              }
            }
          }
        }
     
        path {
          path = "/()(.*)"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "notes-frontend"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}