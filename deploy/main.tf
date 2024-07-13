resource "kubernetes_namespace" "homepage" {
    metadata {
        name = "homepage"
    }
}

data "external" "git" {
    program = [
        "git",
        "log",
        "--pretty=format:{ \"sha\": \"%H\" }",
        "-1",
        "HEAD"
    ]
}

locals {
    name = "homepage"
    tag = data.external.git.result.sha
    image = "registry.i.siriusfrk.ru/${local.name}:${local.tag}"
}

resource "docker_image" "image" {
    name = local.image
    build {
        context    = ".."
        dockerfile = "deploy/Dockerfile"
        platform = "linux/amd64"
    }
}

resource "docker_registry_image" "pushed" {
    name = local.image
    depends_on = [docker_image.image]
    keep_remotely = false
}


resource "kubernetes_deployment_v1" "homepage" {
    depends_on = [docker_image.image]
    metadata {
        name = "homepage"
        namespace = kubernetes_namespace.homepage.metadata[0].name
    }

    spec {
        replicas = 1

        selector {
            match_labels = {
                app = local.name
            }
        }

        template {
            metadata {
                labels = {
                    app = local.name
                }
            }

            spec {
                node_selector = {
                    "siriusfrk.me/location" = "berlin"
                }
                container {
                    image = local.image
                    name = local.name
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
