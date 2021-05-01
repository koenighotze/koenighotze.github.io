---
title: Dealing with data in microservice architectures - part 1 - Shared databases
description: The first part of a series dealing with the problem of data and data ownership in microservice architectures
date:   2020-09-27
tags: ["DDD", "Development", "Microservices"]
---

This is my first article after a long project and COVID induced hiatus. I'll present different ways to deal with data and dependencies in microservice architectures.

[Microservices](https://martinfowler.com/articles/microservices.html) is a wide-spread architectural style for building distributed applications. They offer huge advantages but also some [challenges and traps](https://www.youtube.com/watch?v=X0tjziAQfNQ). Some obvious, some of a more insidious nature. In this short article, I want to focus on how to deal with data, when building microservices.

Dealing with data and dependencies in a microservice architecture is difficult. There is no one-size-fits-all solution. The trade-offs can be the difference between succeeding and utter disaster. The typical „every microservice hat its own database“ seems like good advice. But as we will see below has its challenges.

This overview compares popular patterns for dealing with data in microservice architectures. I'll focus on only four, which in my experience are the most common once. As always, experience and context matter. There are many ways to tackle this problem domain.

Four different parts focus on one specific approach:

* Sharing a database
* Synchronous calls
* Replication
* Event-driven architectures

## Sharing a database

The first pattern is one of the more common approaches to dealing with data. See the following illustration.

![Sharing a database](https://dev-to-uploads.s3.amazonaws.com/i/59k7k8as9sle5koez0ld.png)

As shown, two services A and B use and access the same database. There is no real separation on a business or technical level. As indicated by the colour-coding, the database holds data (schemas, tables,...) that belong to the domain of service A and service B and somehow extra data that neither seems to belong to A or B.

This approach may be a starting point for [brownfield implementations](https://en.wikipedia.org/wiki/Brownfield_(software_development)). Services must often use a preexisting database as-is in such environments.

But even greenfield implementations adopt this style. It is straightforward to use and most familiar to engineers.
Looking at maintenance and knowledge distribution, the advantage is clear. Knowledge sharing and reuse is far easier, if all engineers focus on a single technology. In a polyglot environment engineers must maintain, many different database technologies.

Which leads us to operations.

This approach is most familiar from an operations point of view. Operations must only cope with a single database infrastructure. Monitoring, backup, security become easier. Ask yourself the question „how many databases do you consider yourself an expert in?“.
Many engineers are at most expert in one or many two databases. Knowing how to connect to a database and issue queries does not make one an expert in that database.

But, sharing one database has some more or less severe and not obvious implications.

First of all, let's consider the technical implications.

### In-transparent schema coupling

Let's go back to the diagram above. We can see that the database contains data from at least three different services. If designed according to [DDD](https://www.dddcommunity.org/learning-ddd/what_is_ddd/) - one can presume three different domains. As an example, service A handles users. It may have a table like the following:

![User table](https://dev-to-uploads.s3.amazonaws.com/i/zttcspgzh6be0inuye4t.png)

Service B also requires some user-related data, e.g. for generating invoices. So, it relies on the name and the address columns of the user database.

Now, the product owner of the user administration requires a change to the user data. For example, the `STREET_AND_NUMBER` column are split into `STREET` and `NUMBER` columns. The team maintaining service A knows about that change. They implement it, illustrated by the following image.

![The street_and_number column is split](https://dev-to-uploads.s3.amazonaws.com/i/48e1ir4ovj2rwt9nbmzx.png)

But what about the team owning service B?

There are two cases of interest here: either they do not know about the change, or they do.

#### Scenario 1: The change surprises the team maintaining service B

Team A changes the table as required by their product owner. They apply any necessary change to their code. All tests pass and they deploy the service A and the table changes to an integration test stage.

Only then can team B discover breaking integration tests. They notice the table change. Now they have to plan extra effort for migrating data and adopting the change to the user table. This delays the implementation of features they had planed instead.

Be aware that this is the best case in this scenario. Imagine discovering such a problem in production.

#### Scenario 2: The teams communicate the schema changes

Team A plans the required change. Knowing that team B relies on the user data they approach team B and align on the changes. They come up with a mitigation strategy. The plan to maintain the previous and the new schema for some time. This allows team B to catch up and work around this disruption.

The implications are the same as in scenario 1. Team B has to conform to the change of team A. Again this leads to a delay of essential business features they had planned.

Also, one must notice that this requires team A to be aware of any consumers of _"their"_ data. Why the quotes around _"their"_? One could argue that team A does not own the user data. They have consumers relying on that data. Depending on their organizational power, even team A may not be able to proceed as they see fit.

What about a new team C, that is unaware of team A. And what about technical processes like backups and reports? The change impacts all downstream consumers of the user data.

In the worst case, you may end up with an organisational power struggle.

### Runtime coupling

But there are other challenges, too, that are not as obvious as dependency management. Multiple services relying on the same database share the underlying technical resources: Connection pools, CPU, memory,...

If one service submits a very expensive query, then this may impact other services. Debugging sessions become a game of hunting in the dark, unless monitoring is setup. Discovering such cases of service-spanning runtime couplings is not an easy feat.

The same holds for locks, too, and may lead to deadlocks. If service A locks a table column and service B needs that data, then you are in for some ugly analysis. This is like debugging race conditions in a JVM, only in a distributed scenario.

Finally, most SQL databases struggle with horizontal scalability. This means there may be an upper limit to how many services can use a database in a performant way. There are notable exceptions like Google‘s Cloud Spanner and the impact depends on the database technology (NoSQL databases scale horizontally, e.g.). But even those need a close look at the issues pointed out in this section.

## Mitigating the downsides

There are some ways to mitigate the implications of sharing one database.
For example, the engineers could structure the database itself. Schemas and clear table ownership are a good starting point. The following diagram illustrates this.

![Clean schema split between domains](https://dev-to-uploads.s3.amazonaws.com/i/0nt5pqkyxtlxzijocuy9.jpeg)

Service A owns its schema and the tables in that schema. If another service needs that data, then it is clear who is in charge of that data.

This relation is called [Conformist](https://www.infoq.com/articles/ddd-contextmapping/). Downstream consumers have no say with regards to the schema. They need to conform to whatever team A decides.

This approach is sometimes the first step in migrating to cleaner data-approaches. Especially for brownfield environments a sensible strategy. You start by refactoring the components of a monolith towards clean schema ownership. Next you can migrate step-by-step to the approaches described in the following articles.

## Summary

It should be clear, that sharing the data on this level requires extra coordination. Development need processes to align releases and planning. Teams are not autonomous any longer but rather locked in a distributed data monolith. In general, I recommend this as a starting point for brownfield projects. If possible, I would rather recommend considering one of the following patterns instead.

### Pro

* Easy to understand and operate
* Knowledge sharing and setting up teams is easier
* Often a starting point for brownfield scenarios

### Cons

* Services and thus teams are coupled organisationally and on a technology level
* Coupling is more or less in-transparent
* Difficult to orchestrate release dependencies
* Insidious bugs are found once released to production
* Prone to behind-the-doors power struggles

## Outlook

The next article discusses synchronous calls between services. There should be no problems, when services "just" send a GET request to other services, right? Well, as we'll see there are some issues and trade-offs.

Until then feel free to leave comments. Please point out any omissions or different point-of-views.
