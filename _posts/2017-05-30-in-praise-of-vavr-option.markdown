---
layout: post
title:  "In praise of Vavr's Option"
date:   2017-05-30 15:08:54 +0200
categories: Vavr Javaslang Monad
---
# In praise of Vavr's Option

`Null` is sometimes considered the [billion dollar mistake](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare). One could argue about this forever, but certainly, `null` has lead to a lot of awful code.

Most functional programming languages offer a concept called _Option_ or _Maybe_ to deal with the presence or absence of a value, thus avoiding `null`. Wikipedia defines the _Option_ type as [follows](https://en.wikipedia.org/wiki/Option_type):

>In programming languages (more so functional programming languages) and type theory, an option type or maybe type is a polymorphic type that represents encapsulation of an optional value; e.g., it is used as the return type of functions which may or may not return a meaningful value when they are applied.

This short post gives praise to the Vavr version of `Option`. We show how to use it and show its advantages over JDK8 `Optional`.

# Vavr - Elevator pitch

[Vavr](http://vavr.io), previously known as [Javaslang](http://blog.vavr.io/javaslang-changes-name-to-vavr/), is a lightweight library that brings Scala-like features to Java 8 projects. It focuses on providing a great developer experience both through consistent APIs and extensive documentation.

Vavr offers many abstractions such as functional data structures, value types like `Lazy` and `Either` and structural decomposition (a.k.a. pattern matching on objects). Here we'll only highlight the Vavr `Option`.

If you have ever yearned for really good immutable and persistent collections, working value types, but could not move to Scala and friends because you are working on a brownfield project...then Vavr might just be your fix.

# Optional FTW

Java 8 introduced `Optional` to handle the absence or presence of a value. Without `Optional`, when you face a method like this

{% highlight java %}
public User findUser(String id) {
  ...
}
{% endhighlight %}

you need to rely on Javadoc or annotations like `@NotNull` to decipher if that method returns a `null`.

Using `Optional` things can be stated quite explicitly:

{% highlight java %}
public Optional<User> findUser(String id) {
  ...
}
{% endhighlight %}

This literally says _"sometimes no User is returned"_. `null`-safe. Say "adios" to `NullPointerExceptions`.

## However...

As with all of Java 8's functional interfaces, `Optionals` API is rather spartanic, just a dozen methods, with "highlights" such as

{% highlight java %}
Optional.ofNullable(user)
{% endhighlight %}

If you are used to the expressivness of Scala's `Option`, then you will find `Optional` rather disappointing.

Furthermore, `Optional` is not serializable and should neither be used as an argument type nor stored as a field - at least according to the design goals of the JDK experts (http://mail.openjdk.java.net/pipermail/jdk8-dev/2013-September/003274.html).

## Vavr `Option` to the rescue

The Vavr `Option` takes a different approach. See the following image, that illustrates the type hierarchy.

![Option type hierarchy](https://thepracticaldev.s3.amazonaws.com/i/kz9iowo2wasrtd8j9nia.png)

`Option` follows the design of other functional programming languages, representing absence and presence by distinct classes, `None` and `Some` respectively. Thus avoiding the `ofNullable` nonsense.

{% highlight java %}
Option.of(user)
{% endhighlight %}

And the result would either be a `Some<User>` or a `None<User>`.

Internally absence is represented as `null`, so you if you wanted to wrap a `null`, you need to use

{% highlight java %}
Option.some(null)
{% endhighlight %}

although I do not recommend this approach. Just try the following snippet and you will see what I mean

{% highlight java %}
Option.<String>some(null)
      .map(String::toUpperCase);
{% endhighlight %}


`Option` is tightly integrated with Vavr's `Value` and `Iterable` types. This allows for a very consistent API. You can basically treat an `Option` like a collection with zero or one elements.

This might sound like a small thing, but consider this JDK8 `Optional` example.
We have a list of users.

{% highlight java %}
List<User> users = new ArrayList<>(...);
{% endhighlight %}

And now an `Optional<User>` which we want to add to the list.

{% highlight java %}
Optional<User> optionalUser = Optional.ofNullable(user);

optionalUser.map(users::add);
{% endhighlight %}

The intention is lost in the baroque syntax enforced by JDK8 `Collection` and `Optional` API.

Vavr's `Option` allows for a much cleaner syntax (note that we are using `io.vavr.collection.List<T>` not `java.util.List<T>`).

{% highlight java %}
List<User> users = List.of(...);

Option<User> optionUser = Option.of(user);

List<User> moreUsers = users.appendAll(optionUser);
{% endhighlight %}

Vavr treats `Some<T>` as a collection with one element, and `None<T>` as an empty collection, leading to cleaner code. In addition, note that a new list is created, because Vavr collections are immutable and persistent - a topic for a different day.

`Option` has more syntactic sugar for us:

{% highlight java %}
Option<String> driverName = Option.when(age > 18, this::loadDrivingPermit)
                                  // Option<DrivingPermit>
                                  .peek(System.out::println)
                                  // Print it to the console
                                  .map(DrivingPermit::getDriverName)
                                  // Fetch the driver's name
                                  .peek(System.out::println);
                                  // Print it to the console
{% endhighlight %}

Of course, as I said, this _is_ basically sugar, but anything that reduced boilerplate code is highly appreciated.

`Option` is thightly integrated into Vavr's overall API and architecture. You can easily combine it with Vavr's `Try` monad, that helps dealing with exceptions in a functional way. Take the following example.

{% highlight java %}
Option<Configuration> config = Try.of(Configuration::load)
                                  .toOption();
{% endhighlight %}

We `Try` to load a `Configuration` and convert the result to `Option`. If an exception is thrown, then the
result is `None` otherwise it is `Some`.

Finally, you can use Vavr's pattern matching to decompose an `Option`

{% highlight java %}
Match(option).of(
   Case($Some($()), String::toUpperCase),
   Case($None(),    () -> ""));
{% endhighlight %}

If you have ever coded in a functional programming language, then this should be familiar to you. We basically `Match` the option against two patterns `$Some($())` and `$None()`. Depending on the matched pattern we either convert the string to uppercase or return an empty string.

Using [Vavr Jackson](https://github.com/vavr-io/vavr-jackson) you can even use `Option` and all other Vavr datatypes over the wire. For Spring Boot projects you only need to declare the module such as:

{% highlight java %}
@Bean
public Module vavrModule() {
    return new VavrModule();
}
{% endhighlight %}

# Summary

I hope this short post illustrates the usefulness of Vavr and its `Option` abstraction.

Vavr as a library offers many amazing extensions for object-functional programming in Java, even for brownfield projects. You can leverage its utilities where they make sense and need not migrate to Scala or similar platforms to reap at least some benefits of functional programming.

Of course, this is all syntactic sugar. But as any good library, Vavr fixes things, the core JDK cannot take care of so easily without breaking a lot of code.

Future posts will cover its other amazing features like pattern matching, property based testing, collections and other functional enhancements.
