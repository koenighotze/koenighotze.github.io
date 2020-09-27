---
title: Dealing with data in microservice architectures - part 1
description: The first part of a series dealing with the problem of data and data ownership in microservice architectures
date:   2020-09-27
categories: ddd microservices
permalink: /microservices-data-patterns/part1.html
---

After a long project and COVID induced hiatus, I'll look at different patterns of how to handle data in a distributed microservice architecture.

[Microservices](https://martinfowler.com/articles/microservices.html) are a popular and wide-spread architectural style for building non-trivial applications. They offer huge advantages but also some [challenges and traps](https://www.youtube.com/watch?v=X0tjziAQfNQ). Some obvious, some of a more insidious nature. In this short article, I want to focus on how to deal with data, when building microservices.

Dealing with data and data ownership in a microservice architecture is not a trivial thing. There is no one-size-fits-all solution and being aware of the trade-offs may be the difference between succeeding with microservices and utter disaster. The typical „every microservice hat its own database“ seems like good advice, but as we will see below has its challenges.

This overview explains and compares popular patterns for dealing with data in microservice architectures. I neither assume to be complete with regards to available approaches nor do I think I cover every pros and con of each pattern. As always, experience and context matter.

The patterns are described in four different parts.

* Sharing a database
* Synchronous calls
* Replication
* Event-driven architectures

This part deals with sharing a database between multiple databases.

## Sharing a database

The first pattern is one of the more common approaches to dealing with data. See the following illustration.

![Sharing a database](/assets/media/2020-09-27/shareddb.png)

As shown, two services A and B use and access the same database. There is no real separation on a business or technical level. As indicated by the color-coding, the database holds data (schemas, tables,...) that belong to the domain of service A and service B and somehow additional data that neither seems to belong to A or B.

This approach may be a starting point for brownfield implementations, where a given database must be reused as-is. But more often than not, even greenfield implementations adopt this style, because it is straightforward to use and most familiar to engineers. Looking at maintenance and knowledge distribution, the advantage is clear: if all engineers focus on a single database technology, knowledge sharing and reuse of common libraries is far easier than in a polyglot environment, where multiple different database technologies must be maintained.

Which leads us to operations.

This approach is most familiar from an operations point of view. Only a single database infrastructure component must be operated, monitored, backed-up, and so on. Just ask the question „how many databases do you consider yourself an expert in?“ I guess, most engineers are at most expert in one or many two databases - and no...knowing how to connect to a database and issue queries does not make one an expert in that database.

But, sharing one database has some more or less severe and maybe not obvious implications.

First of all, let's consider the technical implications.

### In-transparent schema coupling

Going back to the diagram above, we can see that the database contains data from at least three different services - and if designed according to DDD - one can presume three different domains. As an example, service A is responsible for maintaining users. It may have a table like the following:

![User table](/assets/media/2020-09-27/table_a.png)

Service B also requires some user-related data, maybe for generating invoices. So, it relies on the name and the address columns of the user database.

Now, the product owner responsible for the user administration domain requires a change to the user data. For example, the `STREET_AND_NUMBER` column needs to be split into `STREET` and `NUMBER` columns, for whatever reason. The team maintaining service A knows about that change and proceeds to implement it, illustrated by the following image.

![Modifies user table](/assets/media/2020-09-27/table_b.png)

But what about the team owning service B?

There are two cases of interest here: either they do not know about the change, or they do.

#### Scenario 1: The team maintaining service B is surprised by the changes

Team A changes the table as required by their product owner and applies any necessary change to their code. All tests pass and their service A and the table changes are deployed to maybe an integration test stage.
Only then can team B discover breaking integration tests. They notice the table change and need to plan additional - previously unknown - an effort for migrating data and adopting the change to the user table. This leads to a delay in implementing features the product owner of service B may have planned instead.

Be aware that this is the best case in this scenario. Depending on the staging strategy, this breaking change would only be discovered in production.

#### Scenario 2: The teams communicate the schema changes

Team A plans the required change. Knowing that team B relies on the user data they approach team B and align on the changes. Maybe they come up with a mitigation strategy, maintaining the previous and the new schema for some time. This allows team B to catch up and work around this disruption.

The implications are nearly the same as in scenario 1. Team B has to conform to the change of team A, maybe leading to a delay of essential business features they had planned.
Also, one must notice that this requires team A to be aware of any consumers of _"their"_ data. Why the quotes around _"their"_? One could argue that the user data is not belonging to team A. They have consumers and depending on their organizational power, even team A may not be able to proceed as they see fit.

But, what about a new team C, that is not made aware of team A. And what about technical processes like backups and reports, basically any downstream consumer of the user data.

In the worst case, you may end up with an organizational power struggle.

### Runtime coupling

But there are other challenges, too, that are not as obvious as dependency management. Multiple services relying on the same database share the underlying technical resources: Connection pools, CPU, memory,...

So, if one service submits a really expensive query, then this may degrade the performance of other services. If the monitoring is not configured to capture these cases, then the debugging sessions become a game of hunting in the dark.  Discovering such cases of service-spanning runtime couplings is not an easy feat.

The same holds for locks, too, and may lead to deadlocks. If service A locks a table column and service B needs that data, then you are in for some ugly analysis. This is like debugging race conditions in a JVM, only in a distributed scenario.

Finally, most SQL databases struggle with horizontal scalability. This means there may be an upper limit to how many services can use a database in a performant way.  There are notable exceptions like Google‘s Cloud Spanner and the impact depends on the database technology (NoSQL databases scale horizontally, e.g.). But even those require a close look at the issues pointed out in this section.
Mitigating the downsides

There are some ways to mitigate the implications of sharing one database.
For example, the database itself could be structured cleanly using schemas and clear table ownership, as illustrated by the following diagram.

![Database split into schemas](/assets/media/2020-09-27/schema-split.jpeg)

Each table owned by service A belongs to a special schema also owned by A. And if another service needs that data, then it is clear who is in charge of that data and the associated data structure. This relation is called [Conformist](https://www.infoq.com/articles/ddd-contextmapping/), as downstream consumers have no say with regards to the schema and need to conform to whatever team A decides.

This approach is sometimes the first step in migrating to cleaner data-approaches, especially for brownfield environments. You start by refactoring the different components of a monolith towards clean schema ownership and subsequently migrate step-by-step to the approaches described in the following sections.

## Summary

It should be clear, that regardless of the scenario, sharing the data on this level requires extra coordination and processes to align releases and planning. Teams can no longer be considered autonomous but rather locked in a distributed data monolith. In general, I recommend this as a starting point for brownfield projects. If possible, I would rather recommend considering one of the following patterns instead.

### Pro

* Easy to understand and operate
* Knowledge sharing and setting up teams is easier
* Often a starting point for brownfield scenarios

### Cons

* Services and thus teams are coupled organizationally and on a technology level
* Coupling is more or less in-transparent
* Difficult to orchestrate release dependencies
* Insidious bugs may only be found once released to production
* Prone to behind-the-doors power struggles

## Outlook

In the next article, we will look at a widespread pattern, namely synchronous calls between services. There should be no problems, when services "just" send a GET request to other services, right? Well, maybe there are some issues and trade-offs.

Until then feel free to leave comments and point out any omissions or maybe different point-of-views.