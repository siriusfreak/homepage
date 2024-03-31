resource "kubernetes_namespace" "homepage" {
    metadata {
        name = "homepage"
    }
}


resource "kubernetes_deployment_v1" "homepage" {
    metadata {
        name = "homepage"
        namespace = kubernetes_namespace.homepage.metadata[0].name
    }

    spec {
        replicas = 1

        selector {
            match_labels = {
                app = "homepage"
            }
        }

        template {
            metadata {
                labels = {
                    app = "homepage"
                }
            }

            spec {
                node_selector = {
                    "siriusfrk.me/location" = "berlin"
                }
                container {
                    image = "registry.i.siriusfrk.ru/homepage:latest"
                    name = "homepage"
                    image_pull_policy = "Always"
                }
            }
        }
    }
}

resource "kubernetes_service_v1" "homepage" {
    metadata {
        name = "homepage"
        namespace = kubernetes_namespace.homepage.metadata[0].name
    }

    spec {
        selector = {
            app = kubernetes_deployment_v1.homepage.spec[0].template[0].metadata[0].labels["app"]
        }

        port {
            port = 80
            target_port = 80
        }

        type = "NodePort"
    }
}

resource "kubernetes_ingress_v1" "homepage" {
    metadata {
        name        = "homepage"
        namespace   = kubernetes_namespace.homepage.metadata[0].name
        annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
        }
    }
    spec {
        ingress_class_name = "nginx-public"
        tls {
            hosts = ["siriusfrk.ru", "siriusfrk.me"]
            secret_name = "siriusfrk-tls"
        }
        rule {
            host = "siriusfrk.ru"
            http {
                path {
                    path = "/"
                    backend {
                        service {
                            name = kubernetes_service_v1.homepage.metadata[0].name
                            port {
                                number = kubernetes_service_v1.homepage.spec[0].port[0].port
                            }
                        }
                    }
                }
            }
        }
        rule {
            host = "siriusfrk.me"

            http {
                path {
                    path = "/"
                    backend {
                        service {
                            name = kubernetes_service_v1.homepage.metadata[0].name
                            port {
                                number = kubernetes_service_v1.homepage.spec[0].port[0].port
                            }
                        }
                    }
                }
            }
        }
    }
}
