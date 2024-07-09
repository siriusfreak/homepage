---
title: "The Fundamental Role of Interfaces in Programming Languages"
date: 2023-05-31T12:00:00+00:00
author: sirius
draft: false
featuredImagePreview: https://images.siriusfrk.me/posts/2024-05-31-the-fundamental-role-of-interfaces-in-programming-languages/fig-2-lego-bricks.png
lightgallery: true
---

In this article, I'll explain the main reasons why interfaces exist and how we use them in programming. My main goal is to create a helpful guide for people who often ask me about interfaces. I'll use simple examples and comparisons to show why programming languages need interfaces and how they can help programmers. I'll also share some examples to demonstrate what interfaces can do, as well as some common problems to avoid.

## Analogies

Software engineering can often be compared to working on an assembly line. Of course, in most cases, we have to strip away the mystical allure and aspirations of rocket science when we're simply creating yet another food delivery app. Let's start from this analogy. Like an assembly line producing engineering goods, software can also be seen as an engineered product. However, there's a key difference: workers in the software industry can not only produce goods, but also create their own tools of production. These tools can generally boost productivity. But, for them to work, we need to be able to integrate them into the production pipeline. Similarly, in the software world, we often use components and tools from various vendors. And we need to integrate all of them into a single, seamless production line. So, how do we address this challenge in the world of engineering?

In the engineering world, there are different standards that allow combining similar parts from different vendors. Also, there might be compatible variations of one standard.

{{< figure src="https://images.siriusfrk.me/posts/2024-05-31-the-fundamental-role-of-interfaces-in-programming-languages/fig-1-din-standards.png" caption="Standards of some metallic products with numbers of DIN and ISO standards" >}}

That's why we don't need to hunt down necessary components in various stores, commission them from blacksmiths, or invent something new. We can simply draw from established standards and use them. These standards not only define the shape of something, but also the materials, physical properties, and so on. This is why standardized parts provide the ability to create repeatable and replicable processes. Of course, there may be defective components, but we can still monitor the production process with acceptance tests to understand the level of errors during this process.

In software development, we have a similar concept: libraries. However, the abstraction provided by a library is not enough to replicate the consistency of standards. Imagine if we had a new version of an M6 screw every year, requiring us to adapt our products and processes to these changes. Of course, we could stick with the previous version or only update our M6 to version 1.9.2 instead of 2.4.1, but this can result in a growing technical debt. Cloud services may also demand that we update our libraries to newer versions to avoid security or performance issues. Different components might depend on these new versions. Eventually, this can disrupt the repeatability and replicability of software and build processes.

Software development is akin to a LEGO set with numerous pieces. Our goal is to assemble a functioning system from these diverse elements. It's crucial to maintain repeatability and replicability, even in unpredictable situations. This is why I believe LEGO serves as an excellent analogy. Why? Because all LEGO pieces can connect via a single interface that is consistent across all components.

{{< figure src="https://images.siriusfrk.me/posts/2024-05-31-the-fundamental-role-of-interfaces-in-programming-languages/fig-2-lego-bricks.png" caption="LEGO blocks can be combined in different ways through the same interfaces [(source)](https://bricks.stackexchange.com/questions/2828/how-to-put-lego-together-upside-down)" >}}

The interface of a LEGO block consists of cylindrical protrusions coupled with corresponding holes, allowing us to connect blocks with each other. Thanks to this standardized interface, we can construct various structures from the same set of parts. Our limitations are only defined by the dimensions of the parts, not their type. Of course, if we need to create something specific, we need a deeper understanding of the individual blocks.

## Interfaces

Applying this LEGO analogy to IT, we find that interfaces can greatly simplify our work. By hiding the implementation details behind an interface, we're able to reveal only the necessary information required for interaction. Hence:

**The interface determines a process of information exchange and possible use-case scenarios of some object.**

Let's take a look at two of the SOLID principles, which are frequently discussed in technical interviews: Interface Segregation (I) and Dependency Inversion (D). These principles allow us to manage the complexity of large systems, extract only the necessary components, and eliminate dependencies on specific implementations.

{{< figure src="https://images.siriusfrk.me/posts/2024-05-31-the-fundamental-role-of-interfaces-in-programming-languages/fig-3-lego-bricks-wrong-connection.png" caption="It is important to remind that wrong usage interfaces may lead to problems, but it is still possible [(source)](https://bricks.stackexchange.com/questions/17335/plate-perpendicular-to-bottom-of-square-brick-plate-is-this-connection-legal)" >}}

Thus, we can alter the system's internals without changing the interface, revealing only essential elements. Of course, these changes should not affect expected behavior unless we plan to release a new version of our library. Interfaces give us the flexibility to make such changes.

Our work is replete with interfaces. APIs are interfaces, Kubernetes provides an interface, and even configurations act as interfaces. All modules offer an interface, either implicitly or explicitly. When we use capital letters or designate something as **`public`** (depending on the language), we are creating an interface as well.

If we use interfaces correctly, our dependency graph becomes flattened and can be easily divided into different parts with a minimal number of interconnections. This process is known as decoupling.

{{< figure src="https://images.siriusfrk.me/posts/2024-05-31-the-fundamental-role-of-interfaces-in-programming-languages/fig-4-decoupling.png" caption="Decoupling according to Wikipedia" >}}

## Problems

But we are living in a complex world and often we can’t hide this complexity in a proper way. This world doesn’t guarantee a simple solution. So we have the problems.

### Domains

In most instances, we can't explicitly describe the domain of values in our interfaces. The domain of values refers to the set of permissible values for a variable. For example, the variable **`domestic_pet`** can have values **`cat`** or **`dog`**, but not **`dinosaur`**. And a **`phone_number`** variable must conform to a multitude of rules from different countries. In the context of interfaces, this limits our ability to precisely define the allowable values for input and output variables, which can lead to errors and unforeseen consequences.

As programming languages have evolved, they've moved from simple size-determined memory areas (as in Assembly language) to automatic type determination. However, in reality, strict type determination merely simplifies the development process. JavaScript was augmented by TypeScript, type assertion was incorporated into Python. But many areas still lack type definition.

Indeed, many data exchange protocols don't include the capability for strict typing. Examples include CSV, Excel, and JSON. Even in HTTP, which is used to transfer data from one potentially typed storage to potentially typed code, we don't have types.

Even strictly typed languages aren't without issues. Problems arise when our value exceeds **`int32`**, such as in the year 2038. Incorrect typing can even lead to catastrophic failures, like a rocket malfunctioning.


{{< youtube id="5tJPXYA0Nec" title="The code that exploded a rocket" >}}


These issues can be detected at compile time, provided we have a stringent methodology to specify domain values within our interfaces.

### Third-party interfaces

Another challenge arises when using third-party interfaces. While these interfaces may be open, it's essential not to overlook the need to implement our own wrapper for them. This is because when we incorporate elements developed by others, we need to ensure they will work consistently — not just now, but also five years down the line, with updated software versions, and in different cloud environments.

Creating this additional boilerplate might seem redundant, but it shields us from future issues. Essentially, during integration, we deal with two interfaces:

- Incoming interface: the interface provided by a third-party library.
- Expected interface: the interface that we anticipate and wish to utilize.

In effect, we need to tailor the library's interface to meet our requirements, which affords us flexibility in the future.

It's important to note that this holds true not only for imperative languages, but for declarative ones as well. We can obscure the interfaces of Kubernetes and cloud platforms using Helm and Terraform. This allows us to provide developers with an interface that only requires the adjustment of important variables, rather than dealing with entire configurations from Pod descriptions to Kubernetes instances.

### Limited means of expression

Even though we have strict-typing languages, in many instances we can't define interfaces in a way that can restrict potential issues. Take configuration for example; it might be considered as strict-typed. However, most configuration providers (YAML, TOML, JSON, Environment variables, Vault, Parameter stores) typically only provide strings. This can lead to problems in the validation step, which can trigger during the execution of the program, especially if you're using real-time changeable parameters.

Ideally, it would be great to describe configuration with types and domain values in **`proto`** files, but it seems that the project **[https://docs.protoconf.sh/](https://docs.protoconf.sh/)** is no longer active. So, if you have time, I believe that creating strict-typed configs in **`proto`**, with the ability to sync with cloud environments, would make for an excellent pet project.

### Implicit interfaces

The final issue to note is the implicit use of certain interfaces. These interfaces might be masked by various abstractions, but it's important to understand that all non-trivial abstractions are, to some extent, leaky (Joel Spolsky).

This implies that if we're using a connection to a service via a network, we're also implicitly using a TCP/IP connection. This connection has certain properties that will influence the characteristics of our services. For instance, if we have issues with network connectivity or signal quality, it affects our interaction with the service. Low-level abstraction leaks into our code with problems that need to be solved, not through the interface for inter-service connection.

Another example is when we iterate over a two-dimensional array. Depending on the memory allocation strategy, there might be different performance outcomes when iterating over rows and columns based on factors such as array size, memory page size, CPU cache size, etc. This could only be uncovered through in-depth investigations.

## Conclusion

Examples of interfaces in various scenarios will be presented in the following article. For now, let's wrap up this paper with a brief conclusion.

Interfaces allow us to:

- Manage complexity
- Lower the degree of coupling
- Conceal implementations
- Define contracts for interaction

However, they also present certain challenges:

- Domain validation
- Integration of third-party libraries
- Insufficient means of expression
- Implicit interfaces
