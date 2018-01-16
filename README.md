# An Elixir/Phoenix/Elm Implementation of the DDD Shipping Example
This project is an [Elixir](https://elixir-lang.org/) and  [Phoenix web framework](http://phoenixframework.org/) implementation and an alternative [Elm language](http://elm-lang.org/) UI of the Domain Driven Design shipping example. This example is featured in Eric Evans' book: ["Domain-Driven Design"](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215/ref=sr_1_1?s=books&ie=UTF8&qid=1496944932&sr=1-1&keywords=domain-driven+design+tackling+complexity+in+the+heart+of+software).

A demonstration of this example was first written in Java; a description of that effort can be found [here](http://dddsample.sourceforge.net/) (Source Forge - has documentation) and [here](https://github.com/citerus/dddsample-core) (GitHub).

## Contributors
Peter C. Marks (@PeterCMarks), Eric Evans (@ericevans0), and John Kasiewicz (@seejohnplay)

The demo was first implemented by Eric Evans and [Citerus](https:www.citerus.se) - a design consultancy. Eric is the founder of [Domain Language](https://domainlanguage.com).

The idea for this version of the demo was conceived at a Portland, ME Erlang/Elixir Meetup that featured a presentation on DDD by Eric. Peter and John joined Eric in defining the scope of this project. John and Peter created the first Phoenix-only version. Several iterations of design and coding resulted in the final Phoenix server and web interface. At a Portland, ME Elm Meetup, Peter suggested and subsequently developed a first version of an Elm implementation of the web interface. Eric and Peter further refined this Elm version.

Both the Elixir and Elm Meetups are led by Jean-Francois Cloutier (@jfcloutier).
## The Project
The original demo (see above for links) was written in Java using the Spring framework. Eric Evans' book was published in 2004 when the predominant coding style was object-oriented. The challenge for this project was not so much to go from a Java to an Elixir and Elm implementation but to find counterparts for DDD constructs and patterns in Elixir and Elm.

Because Elixir is a functional language, some guidance for its use within the context of DDD was found in the recent activity pertaining to DDD and functional languages; similarly for Elm. A document containing pointers to this activity (for Elixir) is available [here](https://github.com/pcmarks/ddd_elixir_demo_stage1/blob/master/docs/ElixirDDDReferences.md). In addition, there are at least two books currently available:

1. [Domain Modeling Made Functional (Pragmatic Bookshelf, in Beta)](https://pragprog.com/book/swdddf/domain-modeling-made-functional)
2. [Functional and Reactive Domain Modeling (Manning)](https://www.manning.com/books/functional-and-reactive-domain-modeling)

A central idea in functional programming - besides the obvious use of functions - is the movement of data through functions, coupled with functional composition. The Elixir language and the Phoenix framework both implement this idea through the use of the [pipe operator](https://elixir-lang.org/getting-started/enumerables-and-streams.html#the-pipe-operator) and [Plugs](https://hexdocs.pm/phoenix/plug.html), respectively. Plugs constitute a Phoenix [pipeline](https://hexdocs.pm/phoenix/routing.html#pipelines). The Elm language is a purely functional and statically typed language.

The overall project will be divided into three stages that will, progressively, show certain aspects of DDD. This repository contains Stage 1.

## Stage 1 Description
The function of Cargo Tracking is the focus of this stage. Two types of users have access to Cargoes and Handling Events: Clerks and Shipping Operations Managers (OpsManagers) who both work for a Shipping Company.

Clerks are Shipping employess who can retrieve the status and progress of a particular cargo as it is handled by Cargo Handlers. Cargo Handlers are organizations that play some role in the progress of the cargo from its source to its destination. A few of the typical Handlers are:

* Customs
* Sea Shipping Companies
* Land Shipping Companies
* Ports (Unloading and Loading)

OpsManagers are Shipping employees who have access to more shipping data via multi-faceted queries. These queries are limited in Stage 1 to only providing a list of all Handling Events presently known by the Shipping Company. Subsequent stages of this demo will provide the OpsManagers with expanded functionality, such as finding all Cargoes that passed thru a specific port.

Subsequent stages may also implement separate logins and authorization for Clerks and OpsManagers.

## Phoenix and DDD concepts and their correspondence

Phoenix Module | Phoenix/Elixir Concept | DDD Concept
--------------|-----------------|------------
Shipping|Application|Domain/Model
Shipping.Cargoes|Context|Aggregate
Shipping.Cargoes.Cargo|Schema|Repository
Shipping.Cargoes.DeliveryHistory|Struct|Query/Event Sourcing
Shipping.HandlingEvents|Context|Aggregate
Shipping.HandlingEvents.HandlingEvent|Schema|Repository/Domain Event
TrackingWeb|Application|Application/UI

Note that not all of the Phoenix modules are listed.

This stage demonstrates the following aspects of DDD:
* Domain Events - Handling Events
* Aggregates:
  * Cargoes including Delivery History
  * Handling Events

## Phoenix and Elm Aspects
* Phoenix
  * Umbrella project
  * Shipping application
    * Cargoes context
      * Cargo Schema
      * Delivery History - Event Sourced
    * Handling Events context
      * Handling Event Schema
    * Agents - data access, in lieu of a database, used by Repo
  * TrackingWeb application
    * Produces the web pages
    * Uses Bootstrap for web page styling (Phoenix default)
    * Accesses the Shipping Application via the Phoenix Controllers
    * Implements a JSON API via View rendering
* Elm
  * Single Page Application
  * Accesses the Domain Model using a Phoenix JSON API via the Phoenix Controllers (and Views)
  * Only uses [W3.CSS](https://www.w3schools.com/w3css/) for web page styling - no JavaScript

## Installation and Operation
Elixir, Phoenix, and Elm need to be installed first. Phoenix/Elixir installation instructions can be found [in the Phoenix documentation](https://hexdocs.pm/phoenix/installation.html#content). An Elm installation guide can be found at the [Elm website](https://guide.elm-lang.org/install.html). W3CSS styling can be downloaded, however, this applicaiont accesses the style sheets via a CDN.

Next, obtain this repository.

## Building this project
Perform all of these steps in order:

### Phoenix
This step will download all the required Elixir and node.js packages
1. `$ cd <installation directory>`
2. `$ mix deps.get`
3. `$ cd apps/tracking_web/assets`
4. `$ npm install`

### Elm

This step will download all the required Elm packages and compile the Elm code.
1. `$ cd <installation directory>`
2. `$ cd apps/tracking_web/assets/elm`
2. `$ elm-compile.cmd or ./elm-compile.sh`

**A note on Elm recompilation** Phoenix uses [Brunch](http://brunch.io/) to monitor changes in the Elixir files and provide automatic recompilation. There is a Brunch plugin - [elm-brunch](https://www.npmjs.com/package/elm-brunch) - that can monitor changes to Elm files. However, we had trouble with the proper recompilation of multiple, inter-dependent Elm source files. Hence this Phoenix project does not rely on automatic recompilation. You can use one of the elm-compile scripts to recompile manually or some editors can be configured to executed commands upon the saving of files. Atom, for instance, has a save-commands plugin that will execute elm-make of the Main.elm file anytime an Elm file is saved. An Atom save_commands.json file is included.

### Elm Test Installation
This step will install the Elm testing harness that is required for running the project's Elm tests (see below).
1. $ npm install -g elm-test


### Running the web application
1. `$ cd <installation directory>`
2. `$ mix phx.server`

### Using the web application

Two separate methods are used to generate the web content: Phoenix (Views and Templates) and Elm. Each is accessed using a different URL. For Phoenix, use [localhost:4000](localhost:4000) and for the Elm version use [localhost:4000/elm](localhost:4000/elm). Both of these URLs will bring you to the demo's home page. From this point on, the UI looks and behaves (except for some color differences, button sizes, etc.) exactly the same for both versions.

To return to the Home page from any other page, click on the Domain Driven Delivery image.

The application is designed for two different types of users: Clerks and OpsManagers.

#### Clerks

Clerks are those people that wish to find the status of a cargo. From the home page, click on the _Clerks_ button. Enter 'ABC123' as a tracking number and click on _Track!_. The response will be a history of the Handling Events for this particular cargo.

#### OpsManagers

OpsManagers work for the Shipping company and are interested in the status of all the cargoes being managed by the company, for example, those entering a particular port. From the home page, click on _Shipping Ops Manager_. This will take you to a "search" page with only one criterion (for now): All. Click on _Search!_ and a list of all Handling Events will appear. Note that in subsequent stages the user will be able to specify more search criteria.

### Data Storage
Stage 1 of this demo does not use a database. Instead, Cargoes and HandlingEvents are managed by [Elixir Agents](https://hexdocs.pm/elixir/Agent.html); they are saved in their respective agent's state as well as in a file cache. The files are loaded by default when the application is started. The files are named "cargoes.json" and "handling_events.json" and are in the resources directory. Entries can be added with any text editor so long as the id values are unique. Note that the starting status for a new Cargo is "NOT RECEIVED".

## Testing
There are currently 23 Phoenix tests. They can be run by entering the commands below.

1. `$ cd <installation directory>`
2. `$ mix test`

There are currently 8 very basic Elm tests. They can be run by entering the commands below.

1. `$ cd <installation directory>`
2. `$ cd apps/tracking_web/assets/elm`
3. `$ elm-test`
