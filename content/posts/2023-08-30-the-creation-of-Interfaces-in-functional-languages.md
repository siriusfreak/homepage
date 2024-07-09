---
title: "The Creation of Interfaces in Functional Languages"
date: 2023-08-30T12:00:00+00:00
author: sirius
draft: false
lightgallery: true
---

In the previous installment of this series, I discussed the rationale behind using interfaces and how they can be defined across various programming languages. Now, we shift our focus to functional programming. This topic may appear more intricate, primarily because its roots are deeply tied to mathematical concepts. Such mathematical nuances give rise to certain prerequisites. Before diving deep, let's establish a foundational understanding by defining some key terms.

**Note:** Regrettably, the Go language is somewhat limiting in certain respects. Specifically, it lacks the traditional object-oriented concept of classes. Due to this limitation, we'll be using Kotlin for our examples and demonstrations.

## Pure functions

Firstly, we'll discuss **pure functions**. The term "pure" in this context refers to a category of functions whose outcomes are solely determined by their input arguments and which produce no side effects. In essence, a pure function:

- Does not rely on global variables, external databases, or external computations.
- Does not modify values passed by reference or alter any global state.
- Does not interact with input/output streams, network connections, and so forth.

Consider the following as an example of a pure function:

```kotlin
fun pure(x: Int, y: Int): Int {
    return x * y
}
```

And this not:

```kotlin
fun notPure(x: Int, y: Int): Int {
    println("Computate $x * $y")
    return x * y
}
```

At first glance, this might seem rather restrictive. Even simple actions like logging or tracing transition us back to standard functions. So, how can we realistically integrate this into a production setting, especially amidst the various layers of abstraction? The upcoming concept will shed light on this and introduce even more depth.

## Monads

Let's discuss **monads**. What exactly are they? Monads are mathematical structures that encapsulate side effects. To understand this, consider a function that divides one integer by another. Given input arguments *a* and *b*, the output is *c*. Mathematically, this can be represented as:

```go
c = a / b
```

All is good.

Let’s try to write code for this function:

```kotlin
fun div(a: Int, b: Int): Int {
    return a / b
}
```

All seems well, right? Not quite. When **`b == 0`**, an exception is thrown. This halts our program and reverts control back to the operating system, assuming no exception handling is in place. Clearly, this is an undesirable side effect. So, how can we circumvent it?

Let’s write the next code:

```go
fun div(a: Int, b: Int): Pair<Int, Boolean> {
    return if (b == 0) {
        Pair(0, false) 
    } else {
        Pair(a / b, true)
    }
}
```

Now, devoid of side effects, it's pure!

We've introduced a new type to represent results, creating a new **domain**: a set of possible values. This domain encompasses all **`Int`** numbers and a **`Boolean`** to indicate the outcome.

To summarize situations where a value might be absent, we can introduce a monad that allows us to enhance the behavior of a type for instances where a specific value is missing.

```kotlin
sealed class Maybe<out T> {

    data class Just<out T>(val value: T) : Maybe<T>()
    object None : Maybe<Nothing>()

    fun <R> flatMap(fn: (T) -> Maybe<R>): Maybe<R> = when (this) {
        is Just -> fn(value)
        is None -> None
    }
}
```

What it means?

- A **`sealed class`** allows subclassing but restricts all its subclasses to be declared within the same file.
- A **`data class`** is designed purely for data storage. You can think of it as a struct for clarity. Here, we create a **`Maybe<T>`** subclass to hold a single, immutable value.
- **`object`** denotes a singleton, enabling us to fix the monad's value when no underlying value exists.
- The **`flatMap`** function takes a function as an argument to process the value encapsulated by the monad, minimizing boilerplate when working with monads.

How to use it? Very simple:

```kotlin
fun safeDivide(numerator: Maybe<Int>, denominator: Maybe<Int>): Maybe<Int> {
    return numerator.flatMap { num ->
        denominator.flatMap { denom ->
            if (denom == 0) {
                Maybe.None
            } else {
                Maybe.Just(num / denom)
            }
        }
    }
}
```

In Kotlin, when you see curly brackets following a function name, it's a shorthand for passing a function as the last parameter to the function.

To invoke this function, we need to encapsulate the integer within this monad:

```kotlin
fun main() {
    val result1 = safeDivide(Maybe.Just(10), Maybe.Just(2))
    val result2 = safeDivide(Maybe.Just(10), Maybe.Just(0))

    printResult(result1)
    printResult(result2)
}

fun printResult(result: Maybe<Int>) {
    when (result) {
        is Maybe.Just -> println(result.value)
        is Maybe.None -> println("Failed to divide!")
    }
}
```

We can apply this code for any scenario where we might encounter an unexpected value and only need to verify it in the primary function.

In Kotlin, the **`Maybe`** monad is integrated into the language through the **`?`** type extension. Hence, we can reframe the **`main`** function as follows:

```kotlin
fun safeDivide(numerator: Int?, denominator: Int?): Int? {
    if (denominator == null || numerator == null || denominator == 0) {
        return null
    }
    return numerator / denominator
}

fun main() {
    val result1 = safeDivide(10, 2)
    val result2 = safeDivide(10, 0)

    println(result1 ?: "Failed to divide!")  // Outputs: 5
    println(result2 ?: "Failed to divide!")  // Outputs: Failed to divide!
}
```

## More monads

Monads can extend behavior for code with side effects. For instance, we can use a monad for logging purposes.

```kotlin
data class Logged<A>(val value: A, val log: List<String>) {

    fun <B> flatMap(f: (A) -> Logged<B>): Logged<B> {
        val result = f(value)
        return Logged(result.value, log + result.log)
    }

    // Helper function to append a log message without changing the value
    fun log(message: String): Logged<A> {
        return Logged(value, log + message)
    }
}

fun <A> pure(value: A): Logged<A> = Logged(value, emptyList())
```

And use it:

```kotlin
fun addWithLog(x: Int, y: Int): Logged<Int> {
    return Logged(x + y, listOf("Added $x and $y"))
}

fun multiplyWithLog(x: Int, y: Int): Logged<Int> {
    return Logged(x * y, listOf("Multiplied $x and $y"))
}

fun main() {
    val result = pure(5)
        .flatMap { addWithLog(it, 3) }
        .flatMap { multiplyWithLog(it, 2) }
        .log("Final transformation done!")

    println("Result: ${result.value}")
    result.log.forEach { println(it) }
}
```

Looks very strange for imperative style but it cover all logs functions and allow us to use it.

```kotlin
Result: 16
Added 5 and 3
Multiplied 8 and 2
Final transformation done!
```

We could create a composition of monads. Obviously, it will be like:

```kotlin
fun safeDivide(numerator: Int, denominator: Int): Logged<Maybe<Int>> {
    return if (denominator == 0) {
        Logged(Maybe.None, listOf("Tried to divide $numerator by 0."))
    } else {
        Logged(Maybe.Just(numerator / denominator), listOf("Successfully divided $numerator by $denominator."))
    }
}
```

And use:

```kotlin
fun main() {
    val result = safeDivide(10, 0)

    println("Result: ${when (result.value) {
        is Maybe.Just -> result.value.value.toString()
        is Maybe.None -> "Division by zero"
    }}")

    result.log.forEach { println(it) }
}
```

## Pure functional interfaces

Now we could define pure functional interfaces.  When we have a pure functions we could define them:

```kotlin
interface SafeArithmetic<M, L> {
    fun safeDivide(numerator: L<M<Int>>, denominator: L<M<Int>>): L<M<Int>>
}
```

```kotlin
class SafeArithmeticImpl : SafeArithmetic<Maybe, Logged> {
    override fun safeDivide(numerator: Logged<Maybe<Int>>, denominator: Logged<Maybe<Int>>): Logged<Maybe<Int>> {
        return denominator.flatMap { denom ->
            if (denom is Maybe.None || (denom as Maybe.Just).value == 0) {
                Log(Maybe.None, listOf("Division by zero or null"))
            } else {
                numerator.map { num ->
                    num.flatMap { n -> Maybe.Just(n / (denom as Maybe.Just).value) }
                }
            }
        }
    }
}
```

Example of usage:

```kotlin
fun main() {
    val arithmetic = SafeArithmeticImpl()

    val result1 = arithmetic.safeDivide(pure(Maybe.Just(10)), pure(Maybe.Just(2)))
    val result2 = arithmetic.safeDivide(pure(Maybe.Just(10)), pure(Maybe.Just(0)))

    printResult(result1) // Outputs: 5
    printResult(result2) // Outputs: Division by zero or null
}

fun printResult(result: Logged<Maybe<Int>>) {
    when (val value = result.value) {
        is Maybe.Just -> println(value.value)
        is Maybe.None -> println(result.log.joinToString(", "))
    }
}
```

Is this approach useful? Imagine working with production-grade code, where we want the capability to incorporate tracing, logs, and metrics. We could define our interface as follows:

```kotlin
interface ProductionService<L, M, T> {
    fun getUsers(numerator: L<M<T<Int>>>): L<M<T<Int>>>
}
```

This approach lets us encapsulate our functional computations within the necessary monads and utilize them implicitly.

However, such a methodology isn't widely adopted or even deemed suitable, especially when the goal is simply to write code.

## Conclusion

In the discussions above, we explored the use of a functional approach in designing interfaces, aiming to integrate pure functions. However, this introduces boilerplate. How can we circumvent this?

At their core, monads handle context and manage errors. So, how do we address contexts and errors when crafting abstractions?

These techniques will be unveiled in the upcoming articles. Stay tuned!
