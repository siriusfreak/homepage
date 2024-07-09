---
title: "The Creation of Interfaces in Imperative Languages"
date: 2023-08-15T12:00:00+00:00
author: sirius
draft: false
lightgallery: true
---

This article continues the previous one, where I delved into the significance of interfaces, highlighting their benefits and issues. In the present article, we'll examine interfaces through practical examples to understand how they're organized from a language design perspective and explore their advantages and disadvantages. Additionally, I'll explain how interfaces can be implemented in those programming languages that lack them (as a keyword).

## **Go**

Indeed, in the Go programming language, support for interfaces is inherent from the get-go, as its creators intended to design a language that allows developers to rediscover the joy of programming. To create an interface in Go, you need to define it:

```go
// Define the interface
type MyInterface interface {
    Method1() int
    Method2(string) bool
}
```

As of Go 1.18, Generics can be used:

```go
// Define the interface with a generic type T
type MyInterface[T any] interface {
    Method1() T
    Method2(T) bool
}
```

Indeed, the utilization of interfaces in programming enables the division of code into more independent components and reduces the degree of coupling between them (decoupling). This simplification not only facilitates testing but also enhances the overall structure of the application.

For testing code that utilizes interfaces, a common practice is the creation of mock objects — stand-ins for real objects that simulate their behavior within the testing framework. Specific libraries are available for creating mock objects in Go, such as mockery or go-mock. These libraries allow the creation of interface substitutes that can be configured to return certain values or invoke specific methods in response to given parameters. This aids in conducting more comprehensive and accurate code testing and enhances its quality.

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

As can be seen, this approach allows us to declaratively define what the function will return in response to a particular request, thus liberating us from the necessity of implementing the function during testing. This clear delineation makes it easier to test and verify the behavior of the code, contributing to a more robust development process.

Here's a list of some of the most common default interfaces in Go:

- **fmt.Stringer**: This interface defines a single method `String() string`, which returns a string representation of the object. Any type that has a method `String() string` automatically implements the `fmt.Stringer` interface.
- **error**: This interface defines a single method `Error() string`, returning a string that describes an error. Any type with a method `Error() string` automatically implements the `error` interface.
- **io.Reader**: This interface defines a single method `Read(p []byte) (n int, err error)`, reading up to `len(p)` bytes into `p`, and returning the number of bytes read and an error if present.
- **io.Writer**: This interface defines a single method `Write(p []byte) (n int, err error)`, writing `len(p)` bytes from `p` into the underlying data stream.
- **io.Closer**: This interface defines a single method `Close() error`, closing the underlying data stream and returning an error if present.
- **sort.Interface**: This interface defines three methods `Len() int`, `Less(i, j int) bool`, and `Swap(i, j int)`, used to implement sorting algorithms.
- **context.Context**: This interface defines several methods that are used for managing the context of a request or operation, including methods for handling deadlines, cancellations, and storing and retrieving values.

When it comes to interfaces in Go, they are typically designed to be as minimal and compact as possible. This design philosophy promotes flexibility and ease of use, enabling developers to construct more modular and maintainable code. By adhering to small, single-responsibility interfaces, Go fosters a programming environment where code can be easily tested, extended, and reused, aligning with the principle of composition over inheritance.

I would like to highlight the `context.Context` interface, widely used in Go for passing execution context between goroutines and for canceling operations. Its definition is as follows:

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <-chan struct{}
    Err() error
    Value(key interface{}) interface{}
}

```

`context.Context` contains four methods: `Deadline()`, `Done()`, `Err()`, and `Value()`, which allow for determining the time of operation execution, tracking the state of an operation, obtaining errors, and passing values between functions associated with the same context.

In most functions in Go, `context.Context` is utilized, enabling the determination of when to halt execution and what data may still be accessible within the context. Utilizing `context.Context` is a crucial part of development in Go, as it enables efficient resource management and prevents goroutine leaks, thus ensuring more stable and secure application operation.

The context simultaneously serves as a means of synchronization and a description of an arbitrary context. While the former is understandable, there are some questions about the latter. Why, in strictly typed Go with all its capabilities, is such an entity needed for the transfer of untyped data?

The context in Go is designed to convey values and metadata between different system components, including goroutines. An analogy can be drawn with the HTTP protocol. If you create a simple application that returns a response to a request and place NGINX, a load balancer, and other services in front of it, you'll find that both the request and response contain headers. These headers may hold user-specific data (such as authentication details) as well as ancillary data generated by intermediate components (like trace identifiers and server names). Similarly, the context in Go may contain both user-defined values and auxiliary information essential for performing a task.

The decision to allow untyped data in the context may seem unorthodox in a language like Go, but it is rooted in a pragmatic approach. By facilitating the propagation of metadata across the boundaries of different system components, it allows for more flexible orchestration of operations and interactions, something akin to attaching metadata to a network protocol. This pattern provides a standardized way to convey essential execution parameters without enforcing a rigid structure, allowing for both innovation and integration with diverse system components. It's a trade-off that prioritizes flexibility and interoperability at the cost of strong typing in this specific aspect of the language.

The context in Go allows values to be passed between functions up and down the call stack, including the function described in the interface and functions above and below it. To access these values, it's necessary to properly check for the presence of a value with a specific key in the context. The context can also contain interfaces for access to databases, logging, or telemetry, depending on the conditions.

Moreover, it enables the avoidance of singletons, which have recently been recognized as an anti-pattern. However, this comes with the cost of dynamic type checking and the need to explicitly specify the information a function expects to find in the context.

An important question also arises regarding where the extraction from the context of the information specifically needed in a function should take place. For instance, if the context carries information about logging (such as a file for log output), where should we extract it? In the function that initiates the logging or in the function that actually writes to the log?

So, if:

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

Or:

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

To solve such a question, we simply need to try to ensure transparency. That is, it would be better to write two functions: one will explicitly extract from the context, and the other will write to the log.

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

Here, you can move logging into a separate package, then its call will be reduced to something like:

```go
log.FromContext(ctx).Log("Something")

```

Or implement a function that logs via information in the context:

```go
func LogViaContext(ctx context.Context, msg string) {
    logger := FromContext(ctx).Log(msg)
}

```

Which will reduce the amount of boilerplate.

In summary:

- Interfaces are strictly typed, do not assume the presence of any implementation or fields;
- They strive to be as small as possible;
- They often carry a context, which is used as a means of conveying information about synchronization and other auxiliary information;
- Efforts should be made to describe as explicitly as possible what will be in the interface, as this will reduce the amount of fuss during debugging.

## Python

In the previous section, we looked at a typed language. But what if we don't have strict types?

Since Python provides extensive metaprogramming capabilities, it has abstract classes that can be used to extend the language's capabilities.

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

Of course, this can be rewritten using type annotations and thus obtain checks before the program starts running:

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

However, even the use of the `abc` library is not mandatory:

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

But for type checking, inheritance from a higher-level entity is still necessary. When using the `typing` library, it would be `Protocol`.

```python
from typing import Protocol

class Shape(Protocol):
    def area(self) -> float:
        pass

```

The `abc` library also allows combining the definition of an abstract method with `property` and `classmethod`:

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

Dependency inversion in Python looks like this:

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

Since Python offers many possibilities for metaprogramming, there are more ways you can shoot yourself in the foot when using abstractions than in Go.

For instance:

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

Despite the syntactic correctness, we defined a method in an abstract class, leading to the emergence of a chimera that is not only a declaration but also partially defines an abstraction.

Of course, for abstractions to be fully effective, we need to have type checking. For example, the `*` operator multiplies and also duplicates strings, so the following code is correct if we don't have type checking:

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
    rectangle = Rectangle("kitty", 10)
    print(rectangle.area())

```

In summary:

- Interfaces (abstract classes) can be made using various methods, with different libraries (or without them).
- They become truly powerful only with type annotations.
- There are many ways to make mistakes when using them.
