---
title:  Save the Optional, stop using isPresent
date:   2017-06-11 11:08:54 +0200
tags: ["Vavr", "Javaslang", "Monad"]
---

Most functional programming languages offer a concept called _Option_ or _Maybe_ to deal with the presence or absence of a value, thus avoiding `null`. Java 8 introduced `java.util.Optional`, an implementation of the _Maybe_ type for Java developers.
Sadly, due to its flexibility, `Optional` is often misused, be it because the developer does not understand its power, or be due to lack of background in functional programming.

In this post, I want to highlight a common pattern of misusing `Optional` and how to fix it.

Note that instead of `java.util.Optional`, I will use the Vavr `Option` instead.
[Vavr](http://vavr.io) is a lightweight library that brings Scala-like features to Java 8 projects. It focuses on providing a great developer experience both through consistent APIs and extensive documentation.
See [this](https://dev.to/koenighotze/in-praise-of-vavrs-option) short overview of how and why optional can help you. Head over to <http://vavr.io> if you want to know more.

But, everything here applies to either implementation.

## A real-world example

I want to start with a typical example that we can use as a refactoring candidate.

Let's consider the following use case: Load a user using a repository. If we find a user we check if the address is set, and if so, we return the street of the address, otherwise the empty string.

Using `null`s we write code similar to this:

```java
User user = repo.findOne("id");
if (user != null) {
  Address address = user.getAddress();
  if (null != address) {
    return address.getStreet();
  }
  else {
    return "";
  }
}
```

Urgs. This is what I call a _Cascading Pile of Shame_.

Fixing this is easy, just use `Option`:

```java
Option<User> opt = Option.ofNullable(user);

if (opt.isPresent()) {
  Option<Address> address = Option.of(user.getAddress());
  if (address.isPresent()) {
    return address.get().getStreet();
  }
  else {
    return "";
  }
}
```

Right?

Wrong! Each time `Option` is used like this, a microservice dies in production.
This fix is the same as above. Same complexity, same _Cascading Pile of Shame_.

Instead, we use the `map` operator.

## Map - the Swiss army knife of functional programming

`map` is your friend when using `Option`. Think of `Option` as a nice gift box with something in it.

Suppose you are a good programmer and wrote your code Test-First. You get a gift box with socks.

![Gift box](https://thepracticaldev.s3.amazonaws.com/i/88y9k39meb0fkprr2gey.png)

But who wants socks? You want a ball. So you `map` a function to the gift box, that takes _socks_ and transforms them into a _ball_. The result is then put into a new gift box. Your birthday is saved through the power of monads.

![Mapping to a ball](https://thepracticaldev.s3.amazonaws.com/i/u5pk27u7ihefn1ybaomh.png)

What if you are a bad coder and do not write unit tests at all? Well, then you won't get any nice socks. But `map` still works fine:

![Nothing from nothing](https://thepracticaldev.s3.amazonaws.com/i/1w2ynj8vnztpbrl1cs0n.png)

If the gift box is empty, then `map` won't even apply the function. So, it is "nothing from nothing".

## Fixing things

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

```java
Find a user
    if an address is available
    fetch the addresses street
    otherwise, use the empty string
```

## Summary

I hope this short post illustrates the usefulness of Vavr and its `Option` abstraction. If you remember one thing only, then please let it be _Do not use `Option#isPresent` or `Option#get`, the `map` is your friend_.

Vavr as a library offers many amazing extensions for object-functional programming in Java, even for brownfield projects. You can leverage its utilities where they make sense and need not migrate to Scala or similar platforms to reap at least some benefits of functional programming.

Of course, this is all syntactic sugar. But like any good library, Vavr fixes things, the core JDK cannot take care of so easily without breaking a lot of code.

Future posts will cover its other amazing features like pattern matching, property-based testing, collections, and other functional enhancements.
