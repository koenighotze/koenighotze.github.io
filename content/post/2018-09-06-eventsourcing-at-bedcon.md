---
title:  Eventsourcing - You are doing it wrong
date:   2018-09-06
tags: [ "Eventsourcing" ]
---

Just here for the slides? Voila: [BedCon Edition (26MB!)](/assets/media/2018-09-06/eventsourcing-you-are-doing-it-wrong.pdf)

This talk is about staying sane when using event sourcing in your microservices.

Event sourcing and CQRS are two very useful and popular patterns when dealing with data and microservices. We often find in our customer's projects, that both have a severe impact on your future options and the maintainability of your architecture. Presentations and articles on both topics are often superficial and do not tackle real-world problems like security and compliance requirements.

This combination of half-knowledge and technical confusion leads to many projects that either refactor back to a 'non-event-sourced' architecture or reduce event sourcing to a message queue.

In this talk, I will summarize our experience while applying event sourcing and CQRS across multiple large financial and insurance companies over the last 5 years. We will cover the _Good_, the _Not so Good_, and the _'oh my god...all abandon ships!'_ when doing event sourcing in the real world...and see how we solved these issues.

* Introduction to event sourcing and CQRS - which problems does ES solve, why do we need it
* Your event store is not a message queue - why mixing both up is bad for you
* No, Kafka is not an event source - choosing the right tool
* Read models are overrated - why you should not start with read models
* GDPR, compliance, and event sourcing - what happens if you delete data from an immutable structure
* Transactions, concurrency, and your event source - why serial writers are bad and how to handle consistency
* Versions, up-front-design and breaking things down the road - how to evolve event sourced architectures

Slides:

* [BedCon Edition (26MB!)](/assets/media/2018-09-06/eventsourcing-you-are-doing-it-wrong.pdf)
