---
title: 10 tips for failing badly at microservices
published: false
description: This post describes 10 recipes for failing at microservices the hard way.
tags: microservices failing cloud agile
permalink: /failing-at-microservices.html
---

The last 5 or so years I have been part of multiple projects that adopted microservice-oriented architecture. Some went smooth, some went not-so-smooth.

In this post I will introduce my top 10 tips for absolutely failing at microservices. These are lessons learned the hard way. So if _you_ want to fail, too, then follow these guidelines.

# Number 10 - go full scale polyglot

Full Scale Polyglot
Ergo: Every team chooses whatever they want
Issue: Maintenance, Reuse of technical infrastructure?


Sure you can mix and match
Every team chooses its own stack -> Flexibility
Cross Cutting Concerns: develop multiple times, tiny differences
e.g. Security, Monitoring,
What about Maintaining and Bugfixing?
Sometimes stability is a plus

Extra Fun if you mix Build systems. SBT Gradle Maven

The Zoo of Technology
Technical knowledge - Excitement
Groundhog Code - Redevelop solutions
Maintenance field trips
Heisenberg monitoring & Ops

Version 0.02 is stable enough The bandwagon is the happy place
Of course you can jump onto every UI framework
Think of the synergies! Bandwagon + Full scale polyglot Vue Angular React!
Also - sadly - holds for Spring Boot. Migrating from 1.2 to 1.3 held some rather nasty surprises. Of course documented…but who would read the documentation if you can just use stackoverflow

Freedom is a human right
Everybody loves a puzzle - REST, HAL, SIREN
Find new friends while searching for fixes on Stackoverflow
Synergies: Polyglot UI with beta status
Keep ops on their toes by multi-monitoring and logging (easy win -> Date format!)


# Number 9 - the death star database

Monolithic DB
PBS und Ergo Story
Issue: Similar to BFS
Issue: What happens if a shared Table is modified? Ripple changes
Issue: Multiple access to tables across domain.

Describe what a domain means: UI, Services + Data!
Use a single big db for all your microservices
Integrate your Microservices using a single database
One Architect: “Finally, we have moved every project to DB2”

Name must be VARCHAR(200) instead of VARCHAR(50)

Sharing is a Good ThingTM
All microservices must share the database
Avoid table or schema ownership
Insidious dependencies, e.g. Connection pools keep everybody awake at night


# Number 8 - the event monolith




# Number 7 - the home-grown monolith

“If you wish to make MICROSERVICES from scratch, you must first create a FRAMEWORK”

Homegrown frameworks == Monolithic Rollout == Instant fun
Paydirekt: Eventsourcing framework, based on Akka, integrated into spring. Really performant
Issue: Needs to be updated in all micro services at the same time if breaking changes
Issue: The FW ‘Guy’ needed to do this in all service in an ‘overnight’ action including bugs

Cross-cutting dependencies as social tools
Job insurance via invasive frameworks
Building frameworks is fun! Try it!
Ideas: Collections, String-Utils, Logging, ORM!


# Number 6 - use the meat cloud

Optimise your Revenue!

Use the meat cloud
Paydirekt / PBS Story: MS without involvement of OPS. Someone needs a job. PBS: Konfiguration der Firewall und Nginx configuration
Issue: Instead of automation, only deployment (Dev) gets automated…i.e. only the road to nexus
Issue: Machines are configured and setup manually
- Who knows, you may be google or amazon one day, so be ready and go full cloud full reactive full everything!!! There is a reason for all those options on start.spring.io. They don't select themselves. Use them. Nobody cares if you cannot tell a Redis from a Postgres. Your manager cannot either! (Top tip: you can store relational data in a redis value: just concatenate using ',' key => csv, PRESTO!)

Infrastructure is expensive…be proud to take care of it
Microsoft Word is some kind of automation
Play the “we are not google” card
If someone asks, say you are using Docker


# Number 5 - the distributed monolith


Combine the complexity of a  microservice architecture with the rigidity and fragility of a monolith

The network is reliable
Dependencies indicate good design, like in Dependency Injection
Synchronous dependencies are easy
What is half a system good for, anyway? So avoid Circuit breakers

# Number 4 - the spa monolith

# Number 3 - the decision monolith

# Number 2 - the monolithic business




# Number 1 - hr driven architecture

It is easier to search for React developers than for general craftswomen

Build a HR Architecture
ERGO Story: UI Microservice in HH, Business Services in Nürnberg and Backend Services in Düsseldorf.  Feature team is a great idea! Instead of thinking in SCS we build a distributed monolith. Easy for HR “we need a fronted dev on row 3”. Managing Product-Teams is more difficult

Use a HR driven team setup, horizontal not vertical
UI Microservice
Business MS
?? Persistence MS ??

Programmers do not like other people
Avoid spread of knowledge
Business knows the domain. Devs know tech
Nobody should have a big picture, keep them in the dark
Meetings mean coffee and biscuits

And: In case of bugs…
It’s always the other team’s fault!

# Wrapping up

The key to failure is the hidden monolith

Microservices are not a free lunch
Choose technology carefully. If you are not a start up or building throw away software, then you may want to stick to/move to proven solutions (Spring Boot is still viable)
Greenfield != Brownfield
Most transitions take multiple years. Intermediate “dirty” architectures are the norm
Most systems do not exist in isolation, think about integration right from the start
Think of the organisational impact
One clear owner makes your life easier
Business Owner, Feature Owner, Product team
BisDevTestOpsSec? Feature team
Two speed IT is at least controversial. Postpones problems instead of solving them


