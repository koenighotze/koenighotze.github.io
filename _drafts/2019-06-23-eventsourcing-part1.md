---
title: Event sourcing with Eventstore
description: The first part of a series of short articles about event sourcing using Eventstore.
date:   2019-06-23
categories: eventsourcing ddd microservices
permalink: /eventsourcing/part1.html
---

In the last  months, I was invited to a couple of conference to give a talk about event sourcing and some general patterns and anti-patterns. Here is a [video](https://www.youtube.com/watch?v=rdB9Q8GouKI) of that talk at Devoxx Poland. The discussions after the talks showed two things:

* there is a general thirst for tutorials and documentation into actual practical event sourcing, and
* a decent step-by-step introduction to using Eventstore as an event source is missing as of this writing.

So I decided to try closing both issues, or at least work on closing the cap a little.

This is intended as a series of short articles about event sourcing using [Eventstore](https://eventstore.org). This series will follow the agenda of the talk:

* Introduction and event sourcing bootcamp
* Aggregate and stream design
* Versioning and event design
* Dealing with transactions and validation rules
* Projections and queries
* Handling errors and correcting errors
* Refactoring event sourced systems
* GDPR and „[Datensparsamkeit](https://martinfowler.com/bliki/Datensparsamkeit.html)“

Enough introduction, let‘s get started with event sourcing using Eventstore.

——

**A side note on the coding examples**

I will use the [HTTP API](https://eventstore.org/docs/http-api/index.html) of Eventstore in all examples. There are however many different [clients](https://eventstore.org/downloads/) for many different languages. So, feel free to experiment.

All examples use [NodeJS](https://nodejs.org) and [Express](https://expressjs.com/) without any additional complex frameworks. The reason is, that I just want to focus on the essential parts of event-sourcing.

——****

This part defines some terms we will be using. Note that these definitions might differ from terms used in other articles. Furthermore the goal is not to be an in-depth introduction into event-sourcing, [CQRS](https://martinfowler.com/bliki/CQRS.html) and related concepts. I will describe just enough to get going.

## The event driven business

Before we even go one step further into event sourcing, we need to make one thing very clear: Realizing that your business domain is event driven is the very starting point.

Take for example a typical coffee shop „Barstucks“.

As a customer I enter the stop and order a coffee. This results in a new _event_ „Coffee ordered“. This is a _fact_. Facts never change, events do not change. Note that facts are usually stated in simple past. They have happened. Nothing can change that.

A fact also contains some _payload_ describing the fact. In the event „Coffee ordered“ this might be „a large coffee with extra cream but no sugar“.

Since the event „Coffee ordered“ was emitted, some employee that _subscribed_ to such events can now react to that event. The employee can start preparing the coffee by looking into the event‘s payload. We call reacting to an event _event handling_. After the coffee is prepared a new event can be emitted, „Coffee prepared“, which might again trigger other _subscribers_.

A different employee might also react to the „Coffee ordered“ event in parallel, triggering the „payment“ process which might then result in an „Order payed“ event - you get the idea.

Finally observe, that the customer does not need to wait for the coffee to be prepared in order to pay. These processes are _decoupled_ and can be executed in parallel (_asynchronously_). Just imagine if all „Barstucks“ customers had to wait for someone to order, then that order to be prepared and payed and finally to be served. This would clearly be a very unsatisfactory experience.

This short example already allows us to draw a couple of important observations:

* business operations and process result in one or more facts, which we represent as events
* facts and events do not change 
* other business entities can react to these events and trigger new operations and processes which in turn result in one or more events
* events and event handling allow parallel execution of business process and decouple the different lines of business

But how does one get from a business case to actual events? Well, this is also a great topic for an extra article. In the mean time, allow me to refer you to something called [Eventmodeling](https://www.eventmodeling.org/posts/what-is-event-modeling/).

## Event sourcing as an implementation detail

Based on this simple business example we might wonder about its technical implementation. In this section we will look at how we could implement „Barstucks“ and introduce additional concepts along the way.

Let‘s consider an architecture for „Barstucks“. We might follow the [microservice](https://martinfowler.com/articles/microservices.html) approach and setup - for now — three different services

* Coffee order service
* Coffee preparation service
* Coffee payment service

Each service needs to hold some state. And each service needs to be informed of certain state changes within other services.

So the question arises: _how do we represent this data and how do we represent the real-world dynamics in our microservice architecture?_

One approach is a shared database, illustrated by the following diagram.

![Microservice collaboration using a shared database](/assets/images/eventsourcing1/shared_db.PNG){:
.img-responsive}

We could also allow microservices that call each other as illustrated below.

![Microservices call each other](/assets/images/eventsourcing1/runtime_called_db.PNG){:
.img-responsive}

A different way is using event sourcing. Each microservice publishes events of a type like „Coffee ordered“ and may subscribe to multiple different event types. E.g. the Coffee preparation service may subscribe to „Coffee ordered“ events to trigger a new preparation task.

In general I like to model services in a way, that events of a certain type can only originate in a single service. Ownership and domain-fit is achieved more easily that way.

Be it as it may, events are alway ordered in direction of time. „Coffee ordered“ _must_ come before „Coffee prepared“. This ordered sequence of events are stored in _streams_. These streams in turn must be stored in some kind of datastore, if we want to have some long-term persistence going on. This datastore is called an _event-store_, and yes Eventstore is such an event-store. But you could also roll your own using e.g. MongoDB - we certainly did that in the past.

With all those pieces in place, one question comes to mind. _How do we get the "coffee order" that one customer placed?_ In other words: we only store facts about a coffee order. But what is the coffee order itself?

In a non-event sourced system, we would turn to the database and maybe `SELECT * FROM COFFEE_ORDER WHERE ORDER_NUMBER=123`. This is not an option in an event sourced system. Here we have to read and interpret the events.

For example, let's say we have the following sequence of three events about a coffee order. Also notice, the syntax.

```json
[
    {
        type: 'coffee ordered',
        event_number: 0,
        timestamp: '2019-06-23T10:56:14',
        payload: {
            order_number: '323',
            type: 'Iced Caffe Latte',
            size: 'regular',
            price: 5.2
        }
    },
    {
        type: 'coffee order payed',
        event_number: 1,
        timestamp: '2019-06-23T11:00:00',
        payload: {
            payment_method: 'credit card',
            ...
        }
    },
    {
        type: 'coffee prepared',
        event_number: 2,
        timestamp: '2019-06-23T11:03:00',
        payload: {
            serving-desk: 3
        }
    }
]
```

The first thing we have to realize is, that asking _what is the state of the coffee order?_ is meaningless. We also need to consider the timeframe we are inquiring. E.g. _what is the state of the coffee order at 11:05 on 23.06.2019?_. This is not different then asking about


### Getting started with Eventstore

[Eventstore](https://eventstore.org) is an open source tool built from the ground up for event sourcing. You will struggle to use it as a general purpose database.

But before continuing, let‘s make sure all tools we need are installed.

1. Install [Docker](https://docs.docker.com/install/) if you have not already
2. Pull the Eventstore Docker image `docker pull eventstore/eventstore:release-5.0.2`
3. Install [HTTPie](https://httpie.org/), an awesome tool for dispatching HTTP requests. Think `curl`, but with better UX

I will not cover installing Docker or HTTPie, because you will find ample help on their respective sites.

——

**Why Kafka is not the best tool for eventsourcing**

TODO HIER NOCH LINK Warum Kafka kein Eventstore ist!

——

On a technical note, Eventstore is written in C# and Mono and runs on different operating systems. Since we will use the Docker version, our Eventstore runs on Ubuntu.

Once you have Docker up and running, you can start a local instance of Eventstore like this:

```bash
$ docker run \
         --tty \
         --interactive \
         --name eventstore \
         --env EVENTSTORE_START_STANDARD_PROJECTIONS=True \
         --publish 2113:2113  \
         eventstore/eventstore:release-5.0.2
#  many lines of output
```

So, what happens here?

* We run the image `eventstore/eventstore:release-5.0.2` naming the container `eventstore`
* By passing `--tty --interactive` we can stop it using `control+c` in the shell
* We publish the HTTP port of Eventstore using the same port `2113`
* Finally, we ask Eventstore to start all standard projections (`EVENTSTORE_START_STANDARD_PROJECTIONS=True`). More on this later

After a couple of seconds you should be able to access the web-UI by pointing your browser to http://localhost:2113. You have to login using `admin` as the username and `changeit` as the password. Now you should see the dashboard and a couple of menu items. Explore the UI as you see fit. We will focus on the HTTP API for the most part.

Eventstore features a comprehensive HTTP API. Let's try it out, by requesting the Eventstores info.
You need to send a `GET` request to `/info` as in the next example:

```bash
$ http localhost:2113/info
HTTP/1.1 200 OK
...

{
    "esVersion": "5.0.2.0",
    "projectionsMode": "All",
    "state": "master"
}
```

The response tells us the version of Eventstore (`5.0.2.0`), the type of node we are talking to (`master`), and if we have started the projections (`All`). As we will not discuss operations, you can ignore the meaning of those values for now.


### Aggregates and stream design

If you are applying [Domain Driven Design](TODO), finding proper and well designed _root aggregates_ is one of the main challenges. These root aggregates are vital for among others

* ensuring and upholding business invariants („each coffee order must only be prepared once“)
* transactional consistency („a payment succeeds or is rolled back“)

Both aspects will be covered in a follow up post. For now, let‘s settle on the following design:

TODO SKETCH

- Customer
    - Registered
- Coffee Order
    - Coffee ordered
    - Prepared
    - Payed
    - Served

Using Eventstore we store each aggregate in its own stream. So „Helen“ gets her own stream `customer-helen` whereas „Bruno“ gets his stream `customer-bruno`.

The advantage of this approach becomes clearer, when we compare this to more classical approaches.

### Classical storage of events

Using other tools as event-stores might force you to store all customer events in a _topic_ such as `customer-topic`. This topic then contains all events that relate to the concept of a "customer".

The following sketch illustrates this approach.

TODO SKETCH

As we see, the `customer-topic` contains all events from "Helen", "Bruno" and "Mike". The events from the different customers are  mixed. But all events that relate to "Helen" are kept in order.

So, what is the challenge here?

Think about how we read "Helen", or in other words, how would we derive the state of "Helen" an 13:12 on November the 12th 2019?

In this design we would have to handle all events of the `customer-topic` one after another. We ignore all non-"Helen" events and build up the state of "Helen" one event at a time"


Events
Storage
projections







## The example: