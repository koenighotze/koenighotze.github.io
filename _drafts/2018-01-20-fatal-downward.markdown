---
title: The fatal downward spiral of bad software quality
description: Some thoughts on software quality and why sometimes moving slowly makes total sense
layout: post
date:   2018-01-20
categories: quality testing craftsmanship
permalink: /agile/fatal-downward.html
---

This short post is about taking shortcuts in sofware development and the sometimes severe consequences. Note that I have changed all names and details, to protect the (maybe not so) innocent.

A couple of weeks ago, I took part in a workshop with some project managers and technical architects of one of our customers from the financial industry. The workshop was thought of as some kind of retrospective of the last year and the customer's current situation.

The project manager, let's call her She-Ra, described the situation as follows...

>"The program started in 2016 as a major effort to move towards a new commercial-of-the-shelf CRM platform for our business. The near shore developers - stationed in Barcelona - were asked to integrate our current systems and applications with the new external system. As expected, the requirements and details changed heavily during the year, but because we are using Scrum, we could handle those changes easily._
>
>The team suggested to avoid writing unit tests, because they could not handle the development work required to build a real test foundation. Furthermore the 3rd party CRM platform was not really designed with testing in mind. So we hired another external company was asked to operate, manage and execute the tests manually. We chose a different company because we did not want the development team to influence the testers in any way.
>
>Sadly, the team lost track somehow in the last quarter of 2017. We had lot's of bugs and our Big Boss had some special features he promised to the business owners. So we all agreed to push a little harder and work faster. Despite this additional effort the developers still could not improve the quality of their code.
>Thus we decided to implement a fine grained tracking method. Multiple status calls where the development team describes the current situation in detail and explains how long the different parts will take to implement. This allowed us as leaders to intervene directly, e.g. direct the developers to more critical parts.
>
>This management effort finally brought the expected results. A top-level-management demo, which was announced on short-notice, was given successfully and we were able to deliver the first release of the system at the beginning of 2018.
>
>With this success in mind, we wanted to start directly with implementing release 2. This is when things started to break somehow. Now the build has been broken for somewhere around two weeks and we are not sure why and how to fix it. But the teams are working on it. We have so many new features to implement, but we do not see a clear commitment from the developers. Seeing their estimates for the whole backlog, we suspect that they add extra buffer to cover other tasks, but this is something we cannot prove directly.
>
>Frankly, I would like to look into this in detail, but I really have no time. I spend my day running around, fixing things, kicking butts.
>
>So, how can we get back to our excellent velocity?"

Puh. Where to start?

This situation is not uncommon. So, before jumping to any conclusion, I want to dissect this story and focus on certain aspects in detail.

TODO

Microtracking and -management

"Kick some butt"

A test and development team

External HiPPO-Scope

Big 3rd party platform

No time for test automation


# Quality leads to trust - trust to a sane working environment

In conclusion, it is hard to put the blame on any single person or entity. The situation got worse step-by-step. Without any self-reflection or retrospective, there was no room to improve or even just assess the situation objectively.

So, as software engineers and craftswomen, we should do our homework. TEST..QUALITY...ETHICS

And as managers we should start with the basics. Build an environment of trust, where problems do not lead to blame or punishment, but are used for improving the situation. There are seldom projects, that are saved by increased tracking and so called "top-management-attention". Open communication, regular retrospectives are far better instruments for gaining insights into potential bottlenecks and problems.

Agile software development is not simply about speed. It is about sustainable speed. Achieving this needs collaboration of everybody involved in a project.

///
CI CD
Unit Test
Scrum + Microtracking
Death March
Scope (Fixed deadline, Fixed Scope, ) -> takes experience to do this agile
Remote teams / business in Germany
Responsibility of TL to insist on quality.
Shortcuts lead to death (like in horror movies)
NO trust?



