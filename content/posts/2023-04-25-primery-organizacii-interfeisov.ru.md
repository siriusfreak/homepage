---
title: "Примеры организации интерфейсов"
date: 2023-04-25T12:00:00+00:00
author: sirius
draft: false
lightgallery: true
---

Данная статья будет продолжением предыдущей, в которой я рассказывал о значимости интерфейсов, их преимуществах и проблемах. В этой статье мы рассмотрим интерфейсы на практических примерах, чтобы понять, как они организованы с точки зрения дизайна языка, их преимущества и недостатки. Также я расскажу, как можно внедрить интерфейсы в те языки программирования, где их нет (как ключевого слова).

## Go

Действительно, в языке программирования Go поддержка интерфейсов встроена изначально, поскольку его создатели стремились сделать язык, который позволяет программистам снова наслаждаться процессом программирования. Для создания интерфейса в Go необходимо определить его:

```go
// Define the interface
type MyInterface interface {
    Method1() int
    Method2(string) bool 
}
```

С Go 1.18 можно использовать Generic’и:

```go
// Define the interface with a generic type T
type MyInterface[T any] interface {
    Method1() T
    Method2(T) bool 
}
```

Действительно, использование интерфейсов в программировании позволяет разделить код на более независимые компоненты и снизить степень связанности между ними (decoupling), что облегчает тестирование и улучшает общую структуру приложения.

Для тестирования кода, использующего интерфейсы, часто применяют механизм создания mock-объектов - заменителей реальных объектов, которые имитируют их поведение в рамках тестов. Существуют специальные библиотеки для создания mock-объектов в Go, такие как `mockery` или `go-mock`. Они позволяют создавать заменители интерфейсов, которые могут быть настроены на возвращение определенных значений или вызов определенных методов в ответ на заданные параметры. Это помогает проводить более полное и точное тестирование кода и улучшать его качество.

```go
package main

import (
    "fmt"
    "net/http" 

    "github.com/golang/mock/gomock"
)

// Define an interface for the HTTP client
type HTTPClient interface {
    Do(req *http.Request) (*http.Response, error)
}

// Define a function that depends on the HTTP client
func MyFunction(client HTTPClient) error {
    req, _ := http.NewRequest("GET", "https://example.com", nil)
    _, err := client.Do(req)
    if err != nil {
        return err
    }
    return nil
}

func main() {
    // Create a new Go-Mock controller
    ctrl := gomock.NewController(nil)
    defer ctrl.Finish()

    // Create a mock HTTP client
    mockClient := NewMockHTTPClient(ctrl)

    // Define the expected behavior of the mock client
    mockClient.EXPECT().Do(gomock.Any()).Return(&http.Response{StatusCode: 404, Body: nil}, nil)

    // Call the function with the mock client
    err := MyFunction(mockClient)
    if err != nil {
        fmt.Println("Error:", err)
    }
}
```

Как видно, это позволяет декларативно определить что вернёт функция в ответ на какой запрос, отвязывая нас при тестировании от необходимости реализации функции.

Вот список некоторых наиболее распространенных интерфейсов по умолчанию в Go:

1. **`fmt.Stringer`** - Этот интерфейс определяет единственный метод **`String() string`**, который возвращает строковое представление объекта. Любой тип, у которого есть метод **`String() string`**, автоматически реализует интерфейс **`fmt.Stringer`**;
2. **`error`** - Этот интерфейс определяет единственный метод **`Error() string`**, который возвращает строку, описывающую ошибку. Любой тип, у которого есть метод **`Error() string`**, автоматически реализует интерфейс **`error`**;
3. **`io.Reader`** - Этот интерфейс определяет единственный метод **`Read(p []byte) (n int, err error)`**, который читает до len(p) байт в p и возвращает количество прочитанных байтов и ошибку, если есть;
4. **`io.Writer`** - Этот интерфейс определяет единственный метод **`Write(p []byte) (n int, err error)`**, который записывает len(p) байтов из p в базовый поток данных;
5. **`io.Closer`** - Этот интерфейс определяет единственный метод **`Close() error`**, который закрывает базовый поток данных и возвращает ошибку, если есть;
6. **`sort.Interface`** - Этот интерфейс определяет три метода **`Len() int`**, **`Less(i, j int) bool`** и **`Swap(i, j int)`**, которые используются для реализации алгоритмов сортировки;
7. **`context.Context`** - Этот интерфейс определяет множество методов, которые используются для управления контекстом запроса или операции, включая методы для управления сроками, отмены и хранения и извлечения значений.

Если говорить об интерфейсах в Go, то они обычно создаются максимально компактными для обеспечения их гибкости и удобства использования.

Хочу отметить интерфейс **`context.Context`**, который широко используется в Go для передачи контекста выполнения между горутинами (goroutines) и для отмены операций. Его определение следующее:

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <-chan struct{}
    Err() error
    Value(key interface{}) interface{}
}
```

**`context.Context`** содержит четыре метода: **`Deadline()`**, **`Done()`**, **`Err()`** и **`Value()`**, которые позволяют определять время выполнения операции, отслеживать состояние выполнения операции, получать ошибки и передавать значения между функциями, связанными с одним контекстом.

В большинстве функций в Go используется **`context.Context`**, который позволяет определить, когда нужно прекратить выполнение и какие данные еще могут быть доступны в контексте. Использование **`context.Context`** является важной частью разработки в Go, поскольку позволяет эффективно управлять ресурсами и предотвращать утечки горутин, обеспечивая более стабильную и безопасную работу приложений.

То есть контекст одновременно является средством синхронизации и описания произвольного контекста. И если первое понятно, то ко второму есть некоторые вопросы. Зачем в строго типизированном Go со всеми его возможностями такая сущность для переноса нетипизированных данных?

Контекст в Go предназначен для передачи значений и метаданных между различными компонентами системы, включая горутины. Аналогией к этому можно привести протокол HTTP. Если вы создадите простое приложение, которое возвращает ответ на запрос, и поставите перед ним NGINX, балансировщик и другие сервисы, то вы увидите, что запрос и ответ содержат заголовки (Headers). В заголовках могут содержаться пользовательские данные (например, данные для аутентификации), а также служебные данные, сгенерированные промежуточными компонентами (например, идентификаторы трейсов и имена серверов). Точно так же, контекст в Go может содержать пользовательские значения и служебную информацию, которая необходима для выполнения задачи.

Контекст в Go позволяет передавать значения между функциями вверх и вниз по стеку вызовов, включая функцию, описанную в интерфейсе, и функции выше и ниже неё. Для доступа к этим значениям необходимо правильно проверить наличие значения с определенным ключом в контексте. Контекст также может содержать интерфейсы для доступа к базе данных, логированию или телеметрии в зависимости от условий.

Ещё он позволяет избежать использования синглтонов, которые в последнее время признаны антипаттерном. Однако за этим стоит динамическая проверка типов и необходимость явно указывать, какую информацию ожидает функция в контексте.

Важный вопрос ещё о том, где происходить извлечения из контекста той информации, которая точно нужна в функции. К примеру, если контекст несёт себе информацию о логировании (к примеру файл для вывода логов), то где мы должны её извлечь? В функции, которая вызывает логирование или в функции, которая производит запись в лог?

То есть, если:

```go
type Logger interface {
    Log(msg string)
}

type MyLogger struct {}

func main() {
    // Create a context object with a logging object
    ctx := context.WithValue(context.Background(), "logger", MyLogger{})

    // Call the DoSomething function with the context
    DoSomething(ctx)
}
```

То:

```go
func (l MyLogger) Log(msg string) {
    log.Println(msg)
}

func DoSomething(ctx context.Context) {
    // Extract the logger object from the context
    logger, ok := ctx.Value("logger").(Logger)
    if !ok {
        logger = MyLogger{}
    }

    // Use the logger object to write log messages
    logger.Log("Starting to do something...")

    // ...
    
    logger.Log("Finished doing something.")
}
```

Или:

```go
func (l MyLogger) Log(msg string) {
    // Extract the logger object from the context
    ctx := context.Background()
    logger, ok := ctx.Value("logger").(Logger)
    if !ok {
        logger = MyLogger{}
    }

    logger.Log(msg)
}

func DoSomething() {
    // Use the logger object to write log messages
    MyLogger{}.Log("Starting to do something...")

    // ...
    
    MyLogger{}.Log("Finished doing something.")
}
```

При решении такого вопроса, нам надо просто постараться обеспечить прозрачность. То есть будет лучше написать две функции: одна будет явно извлекать из контекста, а вторая писать в лог.

```go
type Logger interface {
    Log(msg string)
    FromContext(ctx context.Context) Logger
}

type MyLogger struct {}

func (l MyLogger) FromContext(ctx context.Context) Logger {
    logger, ok := ctx.Value("logger").(Logger)
    if !ok {
        return MyLogger{}
    }
    return logger
}

func DoSomething(ctx context.Context) {
    // Extract the logger object from the context using the FromContext method
    logger := MyLogger{}.FromContext(ctx)

    // Use the logger object to write log messages
    logger.Log("Starting to do something...")

    // ...
    
    logger.Log("Finished doing something.")
}
```

Здесь можно логирование убрать в отдельный пакет, тогда вызов его сведётся к чему-то вроде:

```go
log.FromContext(ctx).Log("Something")
```

Или реализовать функцию, которая производит логирование через информацию в контектсе:

```go
func LogViaContext(ctx context.Context, msg string) {
	logger := FromContext(ctx).Log(msg)
}
```

Что сократит количество бойлерплейта.

Итого:

1. Интерфейсы строго типизированные, не предполагают наличия какой-либо реализации или полей;
2. Стремятся к тому, чтобы быть очень маленькими;
3. Часто несут `context`, который используется как средство передачи информации о синхронизации и другой служебной информации;
4. Надо стараться как можно более явно описать тот факт что будет в интерфейсе, так как это сократит количество телодвижений при отладке.

## Python

В прошлом разделе мы смотрели на типизированный язык. Но что насчёт если у нас нет строгих типов?

Поскольку Python предоставляет большие возможности по мета-программированию, то в нём есть абстрактные классы, которые могут быть использованы для расширения возможностей языка.

```python
import abc

class Shape(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def area(self):
        pass

class Square(Shape):
    def __init__(self, side):
        self.side = side

    def area(self):
        return self.side ** 2

class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return 3.14 * self.radius ** 2

def print_area(shape):
    print(f"The area of the shape is {shape.area()}")

if __name__ == "__main__":
    square = Square(5)
    circle = Circle(2)

    print_area(square)
    print_area(circle)
```

Разумеется, это можно переписать с использованием аннотаций типов и тем самым получить проверки перед началом исполнения программы:

```python
import abc

class Shape(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def area(self) -> float:
        pass

class Square(Shape):
    def __init__(self, side: float) -> None:
        self.side = side

    def area(self) -> float:
        return self.side ** 2

class Circle(Shape):
    def __init__(self, radius: float) -> None:
        self.radius = radius

    def area(self) -> float:
        return 3.14 * self.radius ** 2

def print_area(shape: Shape) -> None:
    print(f"The area of the shape is {shape.area()}")

if __name__ == "__main__":
    square = Square(5.0)
    circle = Circle(2.0)

    print_area(square)
    print_area(circle)
```

При этом даже использование библиотеки `abc` не является обязательным:

```python
class Shape:
    def area(self):
        raise NotImplementedError

class Square(Shape):
    def __init__(self, side):
        self.side = side

    def area(self):
        return self.side ** 2

class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return 3.14 * self.radius ** 2

def print_area(shape):
    if hasattr(shape, "area") and callable(getattr(shape, "area")):
        print(f"The area of the shape is {shape.area()}")
    else:
        print("Invalid shape")

if __name__ == "__main__":
    square = Square(5)
    circle = Circle(2)
    invalid_shape = "triangle"

    print_area(square)
    print_area(circle)
    print_area(invalid_shape)
```

Но для проверки типов потребуется всё же наследование от некоторой сущности более высокого уровня. В случае использования библиотеки `typing` это будет `Protocol`.

```python
from typing import Protocol

class Shape(Protocol):
    def area(self) -> float:
        pass 
```

Библиотека `abc` также позволяет комбинировать определение абстрактного метода с `property` и `classmethod`:

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @property
    @abstractmethod
    def area(self):
        pass

    @classmethod
    @abstractmethod
    def from_json(cls, data):
        pass

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height

    @property
    def area(self):
        return self.width * self.height

    @classmethod
    def from_json(cls, data):
        return cls(data["width"], data["height"])

if __name__ == "__main__":
    rectangle = Rectangle(5, 10)

    print(rectangle.area)

    rectangle_json = '{"width": 7, "height": 12}'

    rectangle_from_json = Rectangle.from_json(eval(rectangle_json))

    print(rectangle_from_json.area)
```

Инверсия зависимостей на Python выглядит следующим образом:

```python
class Database:
    def __init__(self, host, port, username, password):
        self.host = host
        self.port = port
        self.username = username
        self.password = password

    def query(self, sql):
        # implementation of database query
        pass

class UserService:
    def __init__(self, db):
        self.db = db

    def get_user(self, user_id):
        sql = f"SELECT * FROM users WHERE id = {user_id}"
        return self.db.query(sql)

if __name__ == "__main__":
    db = Database("localhost", 3306, "root", "password")
    user_service = UserService(db)

    user = user_service.get_user(1)

    print(user)
```

Поскольку Python даёт много возможностей для мета-программирования, то количество способов, которыми можно выстрелить себе в ногу при использовании абстракций значительно больше чем в Go.

К примеру:

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    def __init__(self, width, height):
        self.width = width
        self.height = height

    @abstractmethod
    def area(self):
        pass

class Rectangle(Shape):
    def area(self):
        return self.width * self.height

if __name__ == "__main__":
    rectangle = Rectangle(5, 10)

    print(rectangle.area())
```

При синтаксической корректности, мы определили метод в абстрактном классе, что приводит к появлению химеры, которая не только объявление, но и частично определяет абстракцию.

Разумеется, чтобы абстракции работали в полную силу нам нужно иметь проверку типов, к примеру оператор `*` и умножает и дублирует строку, поэтому следующий код верен, если у нас нет проверки типов:

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self) -> float:
        pass

class Rectangle(Shape):
    def __init__(self, width: float, height: float):
        self.width = width
        self.height = height

    def area(self) -> float:
        return self.width * self.height

if __name__ == "__main__":
    rectangle = Rectangle(5, 10)
    print(rectangle.area())
    
    rectangle = Rectangle("котик", 10)
    print(rectangle.area())
```

Итого:

1. Интерфейсы (абстрактные классы) можно делать различными методами, с использованием разных библиотек (и без них);
2. Становятся по-настоящему мощными только при наличии аннотаций типов;
3. Есть много способов как ошибиться при их использовании.

## Helm

Далее рассмотрим декларативные языки и то, как мы можем использовать их для создания интерфейсов для деплоя приложений в k8s. Хотя для создания сущностей в k8s мы можем написать программу, используя доступные API и библиотеки на разных языках, наиболее распространенным способом является написание конфигурационных файлов на языке YAML, которые описывают запросы к API k8s, выполняемые при помощи программы **`kubectl`**.

Для создания интерфейсов для фронт-енда также используются языки шаблонизаторы, такие как **`jinja`** или **`text/template`**. Они позволяют подставлять заданные переменные и создавать динамические страницы. Нам будет достаточно подобного, но для конфигураций в YAML.

Наряду с Helm, существует инструмент Kustomize, который также позволяет создавать интерфейсы для деплоя приложений в k8s. Kustomize рассматривает YAML файлы как структуры и применяет к ним патчи, которые переопределяют их содержимое. Важно упомянуть, что примеры таких патчей описаны в RFC 6902 относительно JSON (**[https://datatracker.ietf.org/doc/html/rfc6902](https://datatracker.ietf.org/doc/html/rfc6902)**), который также поддерживается в Kustomize. Это позволяет более гибко настраивать конфигурации для разных сред и облегчает их поддержку.

Далее рассмотрим использование именно Helm. Предположим, у нас есть несколько сервисов, которые мы хотим деплоить в k8s, и мы хотим унифицировать процесс их деплоя. Для этого мы можем создать следующий шаблон:

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

Для использования этого шаблона нам потребуется собрать Helm-пакет. Для этого определим файл `Chart.yaml`:

```yaml
apiVersion: v2
name: my-chart
description: A Helm chart for my application
version: 0.1.0 
```

Собрать его:

```bash
helm init
helm package my-chart/
```

Что создаст файл `my-chart-0.1.0.tgz`. После чего мы можем определить для него следующий файл переменных:

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

И установить в k8s:

```bash

helm install my-release my-chart-0.1.0.tgz -f values.yaml
```

А если нам потребуется обновить на новую версию чарта, то мы сделаем следующее:

```bash
helm upgrade my-release my-chart-0.2.0.tgz -f values.yaml
```

Однако, стоит задуматься о том, где провести границу между тем, что должно решать система, и тем, что может решить пользователь, который будет использовать эту систему. Рассмотрим содержимое файла **`values.yaml`**. Некоторые из полей кажутся избыточными:

1. **`containerPort`** – можно предположить, что все сервисы будут использовать порт 80, и не указывать этот параметр явно;
2. **`servicePort`** – аналогично, можно считать, что все сервисы будут доступны по порту 80;
3. **`serviceType`** – данный параметр может сильно варьировать доступность сервиса на разных уровнях, поэтому его можно исключить;
4. Настройки ингресса тоже можно считать стандартизированными и не указывать явно в **`values.yaml`**.

Таким образом, убрав эти избыточные параметры, мы можем упростить настройку системы для пользователя:

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
```

```yaml
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

Также, необходимо учесть версионирование. У нас есть несколько версий:

1. Версия чарта, который определяет то, что мы деплоим;
2. Версия сервиса (tag контейнера);
3. Версия **`values.yaml`**, которая определяет конфигурацию сервиса.

Как можно решить этот вопрос? **`values.yaml`** должен быть доступен для разработчиков, поскольку они определяют параметры, которые будут использоваться при развёртывании сервиса. Поэтому, версия **`values.yaml`** может совпадать с версией сервиса.

В связи с этим, можно вспомнить о семантическом версионировании: **[https://semver.org/](https://semver.org/)**.

Наконец, кажется, что наш интерфейс получился слишком сложным. Чтобы разрешить эту проблему, можно разделить интерфейс на базовые чарты, которые описывают каждый блок чарта, указанного выше.

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

Тогда мы сможем собрать индивидуальный чарт для сервиса:

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

Какие преимущества мы получим, используя версионирование и разделение интерфейсов в наших сервисах, а также принципы SOLID?

Благодаря версионированию, мы сможем гибко настраивать наши сервисы, учитывать зависимости и контролировать изменения. Мы будем иметь доступ к следующим версиям:

1. Базовых чартов;
2. Чартов сервисов;
3. Файлов **`values.yaml`**, которые соответствуют версии docker-образов.

Стоит отметить, что с помощью версионирования мы эффективно разграничиваем ответственности, вводим четкие интерфейсы и управляем зависимостями - все это основные принципы SOLID.

Итак, в результате мы получаем:

1. Для декларативных языков соблюдаются принципы SOLID;
2. Стандартизация на уровне компании/продукта позволяет сократить размеры интерфейсов;
3. Версионирование в декларативных языках происходит более явно;
4. В Helm имеются типы, которые наследованы от Go (ссылка на документацию: **[https://helm.sh/docs/chart_template_guide/data_types/](https://helm.sh/docs/chart_template_guide/data_types/)**).

## Terraform (HCL)

Как мы можем описывать интерфейсы для инфраструктуры в целом, используя Terraform, также известный как Hashicorp Config Language? Давайте рассмотрим пример и опишем деплой lambda-функции в AWS при помощи Terraform.

Мы можем использовать Terraform для создания инфраструктуры как кода и определения ее состояния. В данном случае, мы можем использовать его для создания и управления lambda-функцией в AWS.

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

Предполагаем, что функция у нас лежит в zip-архиве, функция может быть простым скриптом.

Развернём её:

```bash
zip -j path/to/lambda_function.zip path/to/lambda_function.py
terraform init
terraform plan
terraform apply
```

Что будем делать дальше? Правильно! Сделаем интерфейс, минимальный и удобный. За это в HCL отвечают модули:

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

Как можно заметить у нас осталась только одна функция, чего будет достаточно для деплоя. Теперь поместим файлы в отдельные папку и используем как модуль.

А если нам надо создать много функций, то мы можем использовать следующий синтаксис:

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

Итого:

1. Мы можем описывать инфраструктуру тоже используя принципы SOLID;
2. Создавай некоторый уровень абстракции мы должны следить за его размером и сайд-эффектами.

## Остальное

### CI/CD

CI/CD это тоже интерфейс! Чтобы успешно его внедрить, нам надо сформировать некоторые правила:

1. Пусть сервис хранится в git-репозитории;
2. Пусть конфигурация сервиса задаётся helm-чартом из примера выше;
3. Пусть сервис хранит все настройки в values.yaml;
4. Пусть сервис собирается командой `make build` в корневом каталоге;
5. Пусть образ сервиса формируется командой `make image` в корневом каталоге;
6. Сервис загружается в Container registry по своему имени;
7. В корневом каталоге лежит файл с описанием сервиса, содержащий:

```yaml
service:
	name: test
	version: 1.0.0
```

Данной информации достаточно для проведения деплоя сервиса в облако. Здесь мы можем комбинировать различные сущности и интерфейсы, используя их для последовательного процесса разворачивания сервиса.

Однако пока не существует единого языка для описания этого процесса, за исключением естественного языка. Требуется стандарт, написанный на естественном языке, чтобы определить требования к сервисам для проведения деплоя в рамках конкретного пайплайна.

### API

API может задаваться при помощи proto или OpenAPI. Что позволяет ещё и генерировать код разной сложности. Тут уже достаточно сложно добиться независимости от конкретных реализаций сторонних сервисов, но если у вас есть идеи как это сделать, то буду рад их услышать.

### Конфигурация

Конфигурация — это тоже интерфейс. При этом есть много разных мест и её способов хранения, но выработка универсального решения это тоже решение будущего.

## Выводы

Таким образом, использование интерфейсов - это мощный инструмент для разработки ПО, который может помочь обеспечить стандартизацию, повысить эффективность и упростить процесс создания и управления кодом и инфраструктурой. При этом:

1. Принципы SOLID могут применяться к интерфейсам практически везде, в зависимости от контекста;
2. Стандартизация является ключевым результатом использования интерфейсов;
3. Использование типов может сделать использование интерфейсов более эффективным;
4. Для интерфейсов необходимо версионирование, которое может быть более или менее явным в зависимости от уровня;
5. Интерфейсы могут использоваться для генерации кода, инфраструктуры и других целей;
6. Интерфейсы могут нести неявный контекст, но пользоваться им надо осторожно.
