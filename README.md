# An Elixir/Phoenix/Elm Implementation of the DDD Shipping Example (Work In Progress)
This project is an [Elixir](https://elixir-lang.org/) and  [Phoenix web framework](http://phoenixframework.org/) implementation and an alternative [Elm language](http://elm-lang.org/) UI of the Domain Driven Design shipping example. This example is featured in Eric Evans' book: ["Domain-Driven Design"](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215/ref=sr_1_1?s=books&ie=UTF8&qid=1496944932&sr=1-1&keywords=domain-driven+design+tackling+complexity+in+the+heart+of+software).

The demo was first written in Java; a description of that effort can be found [here](http://dddsample.sourceforge.net/) (Source Forge - has documentation) and [here](https://github.com/citerus/dddsample-core) (GitHub).

## Contributors
Eric Evans, Peter C. Marks, and John Kasiewicz
## The Project
The original demo (see above for links) was written in Java using the Spring framework. Eric Evans' book was published in 2004 when the predominant coding style was object-oriented. The challenge for this project was not so much to go from a Java to an Elixir and Elm implementation but to find counterparts for DDD constructs and patterns in Elixir and Elm.

Because Elixir is a functional language, some guidance for its use within the context of DDD was found in the recent activity pertaining to DDD and functional languages; similarly for Elm. A document containing pointers to this activity (for Elixir) is available [here](https://github.com/pcmarks/ddd_elixir_demo_stage1/blob/master/docs/ElixirDDDReferences.md). In addition, there are at least two books currently available:

1. [Domain Modeling Made Functional (Pragmatic Bookshelf, in Beta)](https://pragprog.com/book/swdddf/domain-modeling-made-functional)
2. [Functional and Reactive Domain Modeling (Manning)](https://www.manning.com/books/functional-and-reactive-domain-modeling)

A central idea in functional programming - besides the obvious use of functions - is the movement of data through functions, coupled with functional composition. The Elixir language and the Phoenix framework both implement this idea through the use of the [pipe operator](https://elixir-lang.org/getting-started/enumerables-and-streams.html#the-pipe-operator) and [Plugs](https://hexdocs.pm/phoenix/plug.html), respectively. Plugs constitute a Phoenix [pipeline](https://hexdocs.pm/phoenix/routing.html#pipelines). The Elm language is a purely functional and statically typed language.

The overall project will be divided into three stages that will, progressively, show certain aspects of DDD. This repository contains Stage 1.

## Stage 1 Description
The function of Cargo Tracking is the focus of this stage. Two types of users have access to Cargoes: Customers and Shipping Clerks who work for Shipping Companies.

Customers can follow the progress of their cargo(es) as it is handled by Cargo Handlers. Cargo Handlers are organizations that play some role in the progress of the cargo from its source to its destination. A few of the typical Handlers are:

* Customs
* Sea Shipping Companies
* Land Shipping Companies
* Ports (Unloading and Loading)

Customers can access the latest status of their cargo via a query. The subsequent display shows the handling history of their cargo and its current status.

Shipping Clerks have their entry point into the application. Their functions are limited in Stage 1, only providing a list of all Handling Events presently under the control of the Shipping Company. Subsequent stages of this demo will provide the Clerk with more functions, such as the searching of the Handling Events.

Subsequent stages will implement separate logins and authorization for Customers and Clerks.

## DDD Aspects
This stage demonstrates the following aspects of DDD:
* Domain Events
* Asynchronous External data feed (Handling Events)
* Architectural Layers: UI, Application and Domain Events; Technology Stack: Elixir/Phoenix/Elm
* Simple Aggregates:
  * Cargoes and Delivery History
  * Handling Events

## Phoenix and Elm Aspects
* Phoenix
  * Shipping application
    * Domain Model implementation (Cargoes and Handling Events)
    * Agents
  * Shipping_web application
    * Produces the web pages
    * Uses Bootstrap for web page styling (Phoenix default)
    * Accesses the Domain Model via the Phoenix Controllers
    * Implements a JSON API
* Elm
  * Single Page Application
  * Accesses the Phoenix JSON API via the Phoenix Controllers
  * Only uses [W3.CSS](https://www.w3schools.com/w3css/) for web page styling

## Installation and Operation
Elixir, Phoenix and other packages, and Elm need to be installed first. Phoenix/Elixir installation instructions can be found [in the Phoenix documentation](https://hexdocs.pm/phoenix/installation.html#content). An Elm installation guide can be found at the [Elm website](https://guide.elm-lang.org/install.html). W3CSS styling needs no installation - its CSS is loaded by accessing a CDN.

Next, obtain this repository.

## Building this project
Perform all of these steps in order:

### Phoenix
1. $ cd <install-directory>ddd_elixir_demo_stage1
2. $ mix deps.get
3. $ cd apps/shipping_web/assets
4. $ npm install

### Elm
1. $ cd <installation directory>/ddd_elixir_demo_stage1/apps/shipping_web/assets/elm
2. $ elm-compile.cmd or ./elm-compile.sh

The last Elm step will download Elm packages and compile the Elm code.

**A note on Elm recompilation** Phoenix uses [Brunch](http://brunch.io/) to monitor changes in the Elixir files and provide automatic recompilation. There is a Brunch plugin - [elm-brunch](https://www.npmjs.com/package/elm-brunch) - that can monitor changes to Elm files. However, we had trouble with the proper recompilation of multiple, inter-dependent Elm source files. Hence we do not rely on automatic recompilation. One of the elm-compile script must be run instead.

### Running the web application
1. $ cd ddd_elixir_demo_stage1
2. $ mix phx.server

### Using the web application

Two separate methods are used to generate the web content: Phoenix (Views and Templates) and Elm. Each is accessed using a different URL. For Phoenix, use [localhost:4000](localhost:4000) and for the Elm version use [localhost:4000/elm](localhost:4000/elm). Both of these URLs will bring you to the demo's home page. From this point on, the UI looks (except for some color difference) and behaves exactly the same for both versions.

The application is designed for two different types of users: Customers and Shipping Clerks.

#### Customers

From the home page, click on the _Customers_ button. Enter 'ABC123' as a tracking number and click on _Track!_. The response will be a history of the Handling Events for this particular cargo.

#### Shipping Clerks

From the home page, click on _Shipping Clerk_. A list of all Handling Events will appear.

### Data Storage
Stage 1 of this demo does not use a database. Instead, Cargoes and HandlingEvents are managed by [Elixir Agents](https://hexdocs.pm/elixir/Agent.html); they are saved in their respective agent's state as well as in a file cache. The files are loaded by default when the application is started. The files are named "cargoes.json" and "handling_events.json" and are in the resources directory. Entries in these files can be deleted if you wish to start from scratch and they can be added to with any text editor so long as the id values are unique. Note that the starting status for a new Cargo is "NOT RECEIVED".
