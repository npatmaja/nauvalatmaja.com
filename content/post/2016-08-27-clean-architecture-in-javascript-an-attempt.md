---
categories: [development, programming]
date: 2016-08-27T21:40:14+07:00
description: "An attempt to make server side JavaScript application's architecture cleaner using uncle Bob's The Clean Architecture concept"
draft: true
keywords: [javascript, software, architecture, clean architecture, code, craftmanship]
series: []
socialsharing: true
tags: [javascript, clean architecture, software architecture, code, craftmanship]
title: Clean(er) Architecture in JavaScript (NodeJS), An Attempt
totop: true
---
![The Clean Architecture](/img/CleanArchitecture.jpg)
## on Clean Architecture
Simple summary:
- why
- what is essential

## JavaScript implementation
- the design
  - using usecase
  - separating the layers
  - on using entity:
    - still couldn't find the best way to implement entity and
      repository.
    - the weak type system and the absent of interface make it
      difficult to implement database repository. One thing I
      can think of is by using convention. However for some case
      this will increase complexity of the overall system. In
      my case when I tried to implement it on top of Bookshelfjs ORM,
      the code to handle the model to entity and vice versa is too
      complex for me to handle now, given the time and resources
      given for the project, we decide it to discard it for now.
      - Type checking
      - Attribute validations etc

## conclusion
- Separating out between your app's logic and infrastructure is a must
  - smaller controller
  - easier to manage app's logic when it is broken down into
    usecases/interactors
  - easily to swap infrastructure implementation. For example I want
    to use Koa instead of express, I just need to write a Koa server
    and use the same usecases that I have written.

Credit:<br>
Image taken from
[8thlight](https://8thlight.com):
https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html
