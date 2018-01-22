---
title: In praise of Vavr's Option
published: false
description: This very short post praises an often overlooked part of Vavr, namely Option
tags: Vavr, Javaslang, Monad
cover_image: https://thepracticaldev.s3.amazonaws.com/i/gvy025i86f3ublvjj0yk.JPG
---

This short post gives praise to a little class featured by Vavr: `Option`.

# Vavr - Elevator pitch

[Vavr](http://vavr.io), previously known as [Javaslang](http://blog.vavr.io/javaslang-changes-name-to-vavr/), is a lightweight library for adding Scala-like features to Java 8 projects. It focuses on providing a great developer experience both through consistent APIs and through extensive documentation.

Vavr offers many abstractions like functional data structures, value types like `Lazy` and `Either` and structural decomposition (a.k.a. pattern matching on objects). Here we'll only highlight the Vavr `Option`.

If you have ever yearned for really good immutable and persistent collections, working value types, but could not move to Scale and friend because you are working on a brownfield project...then Vavr might just be your fix.

# Optional vs. Option?

Java 8 introduced `Optional` to handle the absence or presence of a value. Internally `Optional` represents the absence of a value as `null`, which lead to an rather awkward syntax like

```java
Optional.ofNullable(user)
```

Furthermore Optional is not serializable and should neither be used as an argument type nor stored as a field - at least according to the design goals of the JDK experts (http://mail.openjdk.java.net/pipermail/jdk8-dev/2013-September/003274.html).

Obviously, one could discuss this topic in various ways. But even using `Optional` as a return value is awkward at best, just consider the implications of using it for remote interfaces or its restricted API.

Vavr `Option` takes a different approach. See the following image, that illustrates the type hierarchy for `Option`.

![Option type hierarchy](https://thepracticaldev.s3.amazonaws.com/i/kz9iowo2wasrtd8j9nia.png)

Vavr's `Option` follows the design of other functional programming languages, representing absence and presence by distinct classes, `None` and `Some` respectively. Thus avoiding the `ofNullable` nonsense.

Furthermore, `Option` is tightly integrated with Vavr's `Value` and `Iterable` types. This allows for a very consistent API. You can basically treat an `Option` like a collection with zero or one elements.

Using [Vavr Jackson](https://github.com/vavr-io/vavr-jackson) you can even use `Option` and all other Vavr datatypes over the wire.

# Option(al) code

`Null` is sometimes considered the [billion dollar mistake](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare). One could argue about this forever, but certainly, `null` has lead to a lot of awful code.

Let's consider a simple example: Loading a user using a repository and if we find a user we check if the address is set, and if so, we return the street of the address.

Using `null`s we write code similar to this:

```java
User user = repo.findOne("id");
if (user != null) {
  Address address = user.getAddress();
  if (null != address) {
    return address.getStreet();
  }
}
```

Urgs. This is what we call a _Cascading Pile of Shame_.

Fixing this is easy, just use `Optional`:

```java
Option<User> opt = Option.ofNullable(user);

if (opt.isPresent()) {
      ...
}
```

Right?

Wrong! Each time `Optional` is used like this, a microservice dies in production.
This fix is basically the same as above. Same complexity, same _Pile of Shame_.

Instead we use the `map`. `map` is your friend when using `Optional`. Image `Option` to be a nice gift box with something in it.

Suppose you are a good programmer and wrote your code Test-First. You get a gift box with socks.

![Gift box](https://thepracticaldev.s3.amazonaws.com/i/88y9k39meb0fkprr2gey.png)

But who wants socks? You want a ball. So you `map` a function to the gift box, that takes socks and transforms them to a ball. The result is then put into a new gift box. Your birthday is saved through the power of monads.

![Mapping to a ball](https://thepracticaldev.s3.amazonaws.com/i/u5pk27u7ihefn1ybaomh.png)

What if you are a bad coder and do not write unit tests at all? Well, then you won't get any nice socks. But `map` still works fine:

![Nothing from nothing](https://thepracticaldev.s3.amazonaws.com/i/1w2ynj8vnztpbrl1cs0n.png)

If the gift box is empty, then `map` won't even apply the function. So, basically it is "nothing from nothing".

So going back to the original problem, let's refactor this using `Option`.

```java
User user = repo.findOne("id");
if (user != null) {
  Address address = user.getAddress();
  if (null != address) {
    return address.getStreet();
  }
}
```

First of all, let `findOne` return `Option<User>` instead of `null`:

```java
Option<User> user = repo.findOne("id");
...
```

Since the user's address is optional (see what I did there ;) `User#getAddress` should return `Option<Address>`. This leads to the following code:

```java
Option<User> user = repo.findOne("id");
user.flatMap(User::getAddress)
...
```

Why `flatMap`...well, I'll leave that as an exercise.

Now that we've got the `Option<Address>` we can `map` again:

```java
Option<User> user = repo.findOne("id");
user.flatMap(User::getAddress)
    .map(Address::getStreet)
...
```

Finally, we only need to decide what to do if everything else fails:

```java
Option<User> user = repo.findOne("id");
user.flatMap(User::getAddress)
    .map(Address::getStreet)
    .getOrElse("");
```

Which leaves us with the final version:

```java
repo.findOne("id")
    .flatMap(User::getAddress)
    .map(Address::getStreet)
    .getOrElse("");
```

If you read it from top to bottom, this is as literal as it gets.

```
Find a user
    if an address is available
    fetch the addresses street
    otherwise use the empty string
```

# Summary

I hope this short post, illustrates the usefulness of Vavr and its `Option` abstraction.

Vavr as a library offers many amazing extensions for object-functional programming in Java, even for brownfield projects. You can leverage its utilities where they make sense and need not migrate to Scala or similar platforms to reap at least some benefits of functional programming.

Future posts will cover its other amazing features like pattern matching, property based testing, collections and other functional sugar.
