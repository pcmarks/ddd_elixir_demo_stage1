# An Elixir Implementation of the DDD Shipping Example (Work In Progress)
This project is an [Elixir](https://elixir-lang.org/) implementation of the Domain Driven Design
shipping example. This example is featured in Eric Evans' book:
["Domain-Driven Design"](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215/ref=sr_1_1?s=books&ie=UTF8&qid=1496944932&sr=1-1&keywords=domain-driven+design+tackling+complexity+in+the+heart+of+software).

The example was first written in Java; a description of that effort can be found
[here](http://dddsample.sourceforge.net/) (Source Forge - has documentation) and
[here](https://github.com/citerus/dddsample-core) (GitHub).

## Contributors
Eric Evans, John Kasiewicz, and Peter C. Marks
## The Project
The original demo (see above for links) was written in Java using the Spring framework. This project uses the Elixir language and the Phoenix web framework. Eric Evans' book was published in 2004 when the predominant coding style was object-oriented. The challenge for this project was not so much to go from a Java to an Elixir implementation but to find counterparts for DDD constructs and patterns in Elixir and Phoenix.

Because Elixir is a functional language, some guidance for its use within the context of DDD was found in the recent activity surrounding DDD and functional languages. A document containing pointers to this activity is available here. In addition, there are at least two books currently
available:

1. [Domain Modeling Made Functional (Pragmatic Bookshelf, in Beta)](https://pragprog.com/book/swdddf/domain-modeling-made-functional)
2. [Functional and Reactive Domain Modeling (Manning)](https://www.manning.com/books/functional-and-reactive-domain-modeling)

A central idea in functional programming, in general, and discussed in the above books, in particular, is
the movement of data through functions, coupled with functional composition. The Elixir language and the Phoenix framework both implement this idea as
[pipe operator](https://elixir-lang.org/getting-started/enumerables-and-streams.html#the-pipe-operator) and
[Plugs](https://hexdocs.pm/phoenix/plug.html), respectively. Plugs constitute a
Phoenix [pipeline](https://hexdocs.pm/phoenix/routing.html#pipelines).

This project is divided into three stages that will, progressively, show
certain aspects of DDD. This repository contains Stage 1.

## Stage 1 Description
The function of Cargo Tracking is the focus of this stage. Customers can follow the progress of the cargo
as it is handled by Cargo Handlers.
Cargo Handlers are  organizations that play some role in the progress of the cargo from its source to its
destination. A few of the typical Handlers are:
* Customs
* Sea Shipping Companies
* Land Shipping Companies
* Ports (Unloading and Loading)

Customers can access the latest status of their cargo via a web page. This page shows the handling
history of their cargo and its current status.  These values are updated in real-time by the arrival of a
Cargo Handling event.

Cargo Handlers have their own web page within which they can enter what they did
with a particular cargo. The completion and submission of a Handling Event will be stored and, if a
Customer is tracking the status of that cargo, will result in the real-time update of the Customer's
Tracking page.
## DDD Aspects
This stage demonstrates the following aspects of DDD:
* Domain Events.
* Asynchronous External data feed (Handling Events).
* A User Interface reflecting the underlying model in a non-trivial way.
* Architectural Layers: UI, Application and Domain Events; Technology Stack: Elixir/Phoenix.
* Simple Aggregates:
  * Cargoes and Delivery History.
  * Handling Events

## Elixir and Phoenix Aspects
* Elixir.
  * Umbrella project.
    * Phoenix application.
  * Agents
* Phoenix
  * Phoenix as one of the umbrella applications.
  * Context - corresponding to DDD Aggregates.
  * Web sockets - to broadcast and listen for Handling Events.

## Implementation
The example is implemented as an Elixir
["umbrella"](https://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-apps.html#umbrella-projects) project.
As such, it consists of two appliations (apps in Elixir parlance). One application is concerned primarily
with the data and their associated functions. The other application is a
[Phoenix application](http://phoenixframework.org/) that provides all of the web handling facilities.
## Installation and Operation
Elixir, Phoenix and other packages need to be installed first. Complete installation instructions can be found [in the Phoenix documentation](https://hexdocs.pm/phoenix/installation.html#content).

Next, obtain this repository.
### Building this project
1. $ cd ddd_elixir_demo_stage1
2. $ mix deps.get
3. $ cd apps/shipping_web/assets
4. $ npm install

### Running the web application
1. $ cd ddd_elixir_demo_stage1
2. $ mix phx.server

### Using the web application
The application is configured to be run by users acting in two roles: Customers and Cargo Handlers. For a
complete demonstration, open two browser windows, one for each type of user.

#### Customers

In one browser window, access the application with this url: [localhost:4000](localhost:4000). Click on the _Customers_ button. Enter 'ABC123' as a tracking number and click on _Track!_.
The response will be a history of the Handling Events for this particular cargo.
#### Handlers
In the other browser window, access the application again by going to [localhost:4000](localhost:4000). Click on _Handlers_. A list of Handling Events will appear. At the bottom of the page, click on the New Handling Event button.
Enter data for a new event making sure you use this tracking number: 'ABC123'.
When this new event is submitted, it will appear in this page's list of events and appear in the
Customer's list of events in the other browser's window.
### Data Storage
Stage 1 of this demo does not use a database. Instead, Cargoes and HandlingEvents are managed by [Elixir Agents](https://hexdocs.pm/elixir/Agent.html); they are saved in their respective agent's state as well as in a file cache. The files are loaded by default when the application is started. The files are named
"cargoes.json" and "handling_events.json"
and are in the resources directory. Entries in these files can be deleted if you wish to start from
scratch and they can be added to with any text editor so long as the id values are unique. Note that
the starting status for a new Cargo is "NOT RECEIVED".
