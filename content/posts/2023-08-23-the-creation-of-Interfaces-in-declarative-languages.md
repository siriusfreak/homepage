---
title: "The Creation of Interfaces in Declarative Languages"
date: 2023-08-23T12:00:00+00:00
author: sirius
draft: false
lightgallery: true
---

In the previous article, we looked at how interfaces look in an imperative approach. In this one, we will explore how we can hide something behind an interface when we have declarative code.

## **Helm (YAML)**

Although we can write a program to create entities in k8s, using available APIs and libraries in different languages, the most common way is to write configuration files in YAML language. These files describe the requests to the k8s API, executed with the kubectl program.

To create interfaces for the front-end, template languages such as jinja or text/template are also used. They allow substituting predefined variables and creating dynamic pages. We will need something similar, but for configurations in YAML.

Alongside Helm, there is a tool called Kustomize, which also allows creating interfaces for deploying applications in k8s. Kustomize treats YAML files as structures and applies patches to them, which override their content. It is important to mention that examples of such patches are described in RFC 6902 regarding JSON (**[https://datatracker.ietf.org/doc/html/rfc6902](https://datatracker.ietf.org/doc/html/rfc6902)**), which is also supported in Kustomize. This allows for more flexible configuration for different environments and makes their maintenance easier.

Next, let's look at using Helm specifically. Suppose we have several services that we want to deploy in k8s, and we want to standardize their deployment process. We can create the following template:

```yaml
yamlCopy code
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.appName }}-deployment
spec:
  selector:
    matchLabels:
      app: {{ .Values.appName }}
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        app: {{ .Values.appName }}
    spec:
      containers:
        - name: {{ .Values.appName }}-container
          image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
          ports:
            - containerPort: {{ .Values.containerPort }}
          env:
            {{- range $env := .Values.env }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{- end }}

# templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.appName }}-service
spec:
  selector:
    app: {{ .Values.appName }}
  ports:
    - name: http
      port: {{ .Values.servicePort }}
      targetPort: {{ .Values.containerPort }}
  type: {{ .Values.serviceType }}

# templates/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Values.appName }}-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: {{ .Values.ingress.host }}
      http:
        paths:
          - path: /{{ .Values.ingress.path }}
            pathType: Prefix
            backend:
              service:
                name: {{ .Values.appName }}-service
                port:
                  name: http

```

This segment introduces how Helm and Kustomize can be used to create interfaces for deploying applications in Kubernetes, by utilizing templating techniques in YAML files. It shows the flexibility and maintainability these tools offer in the deployment process.

To use this template, we will need to build a Helm package. For this, we will define the file Chart.yaml:

```yaml
apiVersion: v2
name: my-chart
description: A Helm chart for my application
version: 0.1.0

```

To build it:

```bash
helm init
helm package my-chart/

```

This will create the file my-chart-0.1.0.tgz. After that, we can define the following values file:

```yaml
# values.yaml
appName: my-app
replicaCount: 3
image:
  repository: my-docker-repo/my-app
  tag: 1.0
containerPort: 8080
servicePort: 80
serviceType: ClusterIP
ingress:
  host: my-app.example.com
  path: my-app

```

And install it in k8s:

```bash
helm install my-release my-chart-0.1.0.tgz -f values.yaml

```

If we need to update to a new chart version, we will do the following:

```bash
helm upgrade my-release my-chart-0.2.0.tgz -f values.yaml

```

However, we should consider where to draw the line between what the system should decide and what the user who will be using this system may decide. Let's examine the contents of the values.yaml file. Some of the fields seem redundant:

- `containerPort` – we can assume that all services will use port 80 and not explicitly specify this parameter;
- `servicePort` – similarly, we can assume that all services will be accessible on port 80;
- `serviceType` – this parameter can significantly vary the availability of the service at different levels, so it can be excluded;
- Ingress settings can also be considered standardized and not explicitly specified in values.yaml.

Thus, by removing these redundant parameters, we can simplify the system setup for the user:

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.appName }}-deployment
spec:
  selector:
    matchLabels:
      app: {{ .Values.appName }}
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        app: {{ .Values.appName }}
    spec:
      containers:
        - name: {{ .Values.appName }}-container
          image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
          ports:
            - containerPort: 80
          env:
            {{- range $env := .Values.env }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{- end }}

# templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.appName }}-service
spec:
  selector:
    app: {{ .Values.appName }}
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: ClusterIP

# templates/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Values.appName }}-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: {{ .Values.appName }}.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ .Values.appName }}-service
                port:
                  name: http
appName: my-app
replicaCount: 3
image:
  repository: my-docker-registry/my-app
  tag: 1.0.0
env:
  - name: DB_HOST
    value: db.example.com
  - name: DB_PORT
    value: "5432"
  - name: DB_USER
    value: my_db_user
  - name: DB_PASSWORD
    value: my_db_password

```

Here, the focus is on simplifying and streamlining the Helm chart by making assumptions about the default values and removing redundant parameters. This makes the chart more user-friendly and easier to manage, particularly for those users who may not be experts in Kubernetes.

Also, it is necessary to take into account versioning. We have several versions:

- Chart version, which defines what we are deploying;
- Service version (container tag);
- Version of values.yaml, which defines the service configuration.

How can we solve this issue? The values.yaml file should be available to developers, as they define the parameters that will be used when deploying the service. Therefore, the version of values.yaml can match the service version.

In this context, we can remember semantic versioning: [https://semver.org/](https://semver.org/).

Finally, it seems that our interface has become too complex. To solve this problem, we can divide the interface into basic charts that describe each block of the chart specified above.

```yaml
# deployment/Chart.yaml
name: deployment
version: 0.1.0
description: A Helm chart for the deployment of a Kubernetes deployment
# Omitting values.yaml and helpers.tpl for brevity
files:
  - templates/template.yaml
# deployment/template.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.appName }}-deployment
spec:
...

```

Then we can build an individual chart for the service:

```yaml
# Chart.yaml
name: service
version: 0.1.0
description: A Helm chart for deploying a Kubernetes service
dependencies:
  - name: deployment
    version: 0.1.0
    repository: "deployment"
  - name: service
    version: 0.1.0
    repository: "service"
  - name: ingress
    version: 0.1.0
    repository: "ingress"

# template.yaml
{{- include "deployment.deployment" . }}
{{- include "service.service" . }}
{{- include "ingress.ingress" . }}

```

What benefits do we get by using versioning and splitting interfaces in our services, as well as the SOLID principles?

Thanks to versioning, we can flexibly configure our services, take dependencies into account, and control changes. We will have access to the following versions:

- Basic charts;
- Service charts;
- values.yaml files, which correspond to the version of docker images.

It's worth noting that with versioning, we effectively delineate responsibilities, introduce clear interfaces, and manage dependencies - all these are the core principles of SOLID.

So, in the end, we achieve:

- SOLID principles are observed for declarative languages;
- Standardization at the company/product level allows reducing interface sizes;
- Versioning in declarative languages is more explicit;
- Helm has types inherited from Go (link to documentation: [https://helm.sh/docs/chart_template_guide/data_types/](https://helm.sh/docs/chart_template_guide/data_types/)).

## Terraform (HCL)

How can we describe interfaces for the infrastructure as a whole using Terraform, also known as Hashicorp Config Language? Let's consider an example and describe deploying a lambda function in AWS using Terraform.

We can use Terraform to create infrastructure as code and define its state. In this case, we can use it to create and manage a lambda function in AWS.

```hcl
provider "aws" {
  region = "us-west-2"
  access_key = "ACCESS_KEY"
  secret_key = "SECRET_KEY"
}

variable "function_name" {
  type = string
}
resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  role = "arn:aws:iam::ACCOUNT_ID:role/LambdaRole"
  handler = "handler.lambda_handler"
  runtime = "python3.8"
  memory_size = 256
  timeout = 10
  filename = "path/to/lambda_function.zip"
}
```

We assume that the function is stored in a zip archive; the function can be a simple script.

Let's deploy it:

```bash
zip -j path/to/lambda_function.zip path/to/lambda_function.py
terraform init
terraform plan
terraform apply
```

What's next? Exactly! Let's make the interface minimal and user-friendly. In HCL, modules handle this:

```hcl
# lambda/main.tf
provider "aws" {
  region = var.region
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  role = "arn:aws:iam::ACCOUNT_ID:role/LambdaRole"
  handler = "handler.lambda_handler"
  runtime = "python3.8"
  memory_size = 256
  timeout = 10
  filename = "path/to/{{var.function_name}}.zip"
}
# lambda/variables.tf
variable "function_name" {
  type = string
}
# lambda/outputs.tf
output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function.arn
}

```

As you can see, we're left with just one function, which is sufficient for deployment. Now, let's place the files into separate folders and use them as a module.

If we need to create multiple functions, we can use the following syntax:

```hcl
variable "function_names" {
  type    = list(string)
  default = ["test1", "test2", "test3"]
}

module "lambda_functions" {
  source = "./lambda/"
  for_each = toset(var.function_names)
  function_name = each.key
}
```

In conclusion:

- We can also describe infrastructure using the SOLID principles;
- By creating a certain level of abstraction, we must monitor its size and side effects.
