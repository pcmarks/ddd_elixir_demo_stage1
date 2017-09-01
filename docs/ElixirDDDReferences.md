# Elixir(FP) - DDD references

1. [DDD within Elixir/Phoenix project: Umbrella apps & Service Object](https://medium.com/@andreichernykh/thoughts-on-structuring-an-elixir-phoenix-project-cb083a8894ef).
2. [DDD: Aggregate roots as Elixir Processes](https://elixirforum.com/t/domain-driven-design-aggregate-roots-as-elixir-processes-genserver/4372)  Discussion in Elixir Forum. Aggregates as GenServers. Multi-node and life cycle support.
3. [Example implementation of DDD with Elixir/Phoenix](https://github.com/rpless/phoenix_ddd) Github repository. From the README: The goal of the system is to try to show the concepts of Repositories, Domain Entities, and Ubiquitous Language from Domain Driven Design. 
4. [Domain Driven Design in Elixir](https://www.linkedin.com/pulse/domain-driven-design-elixir-naveen-negi) May 2017 article. Discusses DDD and Phoenix 1.3
5. [Gerogina McFadyen: Using an Elixir Umbrella](https://8thlight.com/blog/georgina-mcfadyen/2017/05/01/elixir-umbrella-projects.html) - Umbrella sub-apps as bounded contexts.
6. That's My Monkey (A Functional, Reactive, Domain Driven Design, and Common Sense Approach To Architecture). [LambdaDays 2017](http://www.lambdadays.org/lambdadays2017/rob-martin). Rob Martin talk [slides](http://www.lambdadays.org/static/upload/media/1487239158386169robmartinthatsmymonkey.pdf). Last third of the talk is about DDD and an FP implementation.
7. [Building a CQRS system with Elixir and Phoenix](https://10consulting.com/2017/01/04/building-a-cqrs-web-application-in-elixir-using-phoenix/). In my (Peter) opinion this is an Elixir implementation of an object-based design. That is, it does not exploit the functional aspects of Elixir.
8. ElixirDaze [talk](https://www.youtube.com/watch?v=AnYm0rTJNVg): Using your Umbrella. Inspired by DDD.
9. [Elixir Application Design](http://learningelixir.joekain.com/elixir-application-design-posts/) - a series of blog post by Joseph Kain.
10. [Thinking in a Highly Concurrent, Mostly-functional language](https://www.youtube.com/watch?v=d5G3P2iosmA&index=11&list=PLE7tQUdRKcyakbmyFcmznq2iNtL80mCsT) by Francesco Cesarini.
11. [Why I won't leave Ruby for Elixir](http://insights.workshop14.io/2016/04/18/why-i-cant-leave-ruby-for-elixir.html)
12. [Vaughn Vernon: Reactive Domain-Driven Design](https://www.infoq.com/news/2013/11/vernon-reactive-ddd): DDD with Reactive Streams and Actors. Think Elixir's GenStage. Aggregates as actors. Also: [Vaughn Vernon on the Actor Model and Domain-Driven Design](https://www.infoq.com/news/2013/06/actor-model-ddd)
13. [Implementing CQRS on top of OTP (in Elixir)](http://slides.com/hubertlepicki/implementing-cqrs-in-elixir#/): Slides from Hubert Lepicki
14. [CQRS with Elixir and Phoenix](http://jfcloutier.github.io/jekyll/update/2015/11/04/cqrs_elixir_phoenix.html): J.F. Cloutier's notes. Provides Elixir macros to handle the distinction between Queries and Commands automagically.
15. [Bryan Hunter - CQRS with Erlang](https://vimeo.com/97318824). Spawn a process for each Aggregate entity.
16. [Introduction to Domain Driven Design, CQRS and Event Sourcing](https://www.kenneth-truyers.net/2013/12/05/introduction-to-domain-driven-design-cqrs-and-event-sourcing/).
17. [Pawel Kaczor: Reactive DDD with Akka](http://pkaczor.blogspot.in/2014/04/reactive-ddd-with-akka.html). Scala and Akka. Aggregate root as an actor. Command sourcing. Event sourcing.
18. [Functinal Web Development With Elixir, OTP, and Phoenix](https://pragprog.com/book/lhelph/functional-web-development-with-elixir-otp-and-phoenix). Pragmatic Programmers book.
19. [Authorization Considerations For Phoenix Contexts](https://dockyard.com/blog/2017/08/01/authorization-for-phoenix-contexts?utm_content=buffer5f6df&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer). Chris McCord discusses where to put authorization when using contexts.
