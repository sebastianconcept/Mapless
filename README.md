Mapless
=======

*Obscenely simple persistence for Smalltalk.* Mapless is a small framework for storing objects in a key->data fashion (i.e.: noSQL databases) without requiring any kind of object-data map. Supported backends are MongoDB and Redis.

*There is no instVars...*
*There is no accessors...*
*There is no object-mapping impedance...*

*Only persistence.*

### Applicability

Mapless can be used for Model persistence, object oriented shared cache, observer pattern across images and network JSON communication.

### Motivation
> "I wanted to persist objects with *low friction* and *low maintenance* but *high scaling* and *availability* capabilities so Mapless is totally biased towards that. This framework is what I came up with after incorporating my experience with [Aggregate](https://github.com/sebastianconcept/Aggregate) in [airflowing](http://airflowing.com)." ~ [Sebastian Sastre](http://sebastiansastre.co)

### Loading

If you want to use Pharo's UI, open an image and click for a **menu**, then **tools**, then **Configuration Browser** and search for **Mapless**. Click **Install Stable Version**

However, it's recommended that you use Metacello to load your projects...

Use this snippet to fetch the Baseline and load it in your [Pharo](http://www.pharo-project.org/home)* image:

    Metacello new
    	baseline: 'Mapless';
    	repository: 'github://sebastianconcept/Mapless:master/src';
    	get.

To load Mapless alone, with no backend database (likely only for Mapless contributors):

    Metacello new
    	baseline: 'Mapless';
    	repository: 'github://sebastianconcept/Mapless:master/src';
    	load.

There are many backend options you can load. Use the following snippet to load one or more backend database(s):

	Metacello new
    	baseline: 'Mapless';
    	repository: 'github://sebastianconcept/Mapless:master/src';
    	load: #('Mongo' 'Redis' 'Postgres' 'GemStone').

NOTE: If you are running on the GemStone platform, the GemStone classes are automatically loaded along with Mapless.

To load the both the database classes and the corresponding tests, use the following snippet:

	Metacello new
    	baseline: 'Mapless';
    	repository: 'github://sebastianconcept/Mapless:master/src';
    	load: #('Mongo Tests' 'Redis Tests' 'Postgres Tests' 'GemStone Tests').

To load everything available for your platform, including the tests:

	Metacello new
    	baseline: 'Mapless';
    	repository: 'github://sebastianconcept/Mapless:master/src';
    	load: #('all').

### How does it look?

You can store  and retrieve your Mapless models on MongoDB like a breeze.
#### Getting the connection

    odb := MongoPool instance databaseAt: 'YourMongoDatabase'.

#### Create a new model

Just subclass MaplessModel with your app "business objects". Here we use a Task model:

    task := Task new description: 'Try Mapless'; beIncomplete.

#### Save it

In Mapless you do things sending a #do: with a closure which Mapless uses to automatically discern which MongoDB database and collection has to be used. It also will know if it needs to do an insert or an update. As a bonus, you get the collection *and* the database created lazily.

Want to save something? Zero bureaucracy, just tell that to the model:
    odb do:[ task save ].

The spirit of the project is to preserve developer *low-friction* when using persistence.
#### Fetching data

Getting all models of a given class:
    odb do:[ Task findAll ].

Getting a specific model:
    odb do: [ Task findId: 'c472099f-79b9-8ea2-d61f-e5df34b3ed06' ].

For getting efficiently a (sub)group of models, you write your own Mapless class side getters. They should act on the MongoDB indices with the parameters of your query. You'll get your models in a breeze:

    odb do:[ Task findAtUsername: 'awesomeguy' ].

#### Adding something to a model

You can use Mapless models pretending they are [prototypical](http://en.wikipedia.org/wiki/Prototype-based_programming) like in [Self](http://en.wikipedia.org/wiki/Self_(programming_language)) or [Javascript](http://en.wikipedia.org/wiki/JavaScript) objects. No instVars. No setters. No getters. All just works:

    odb do: [
    	task
    		deadline: Date tomorrow;
    		notes: 'Wonder how it feels to use this thing, hmm...';
    		save ].

#### Need composition?

Of course you do! The only thing you need is to save the children first
    odb do: [  | anAlert |
      anAlert := Alert new
      				duration: 24 hours;
      				message: 'You will miss the target!';
      				save.
    	task
    		alert: anAlert;
    		save ]

This is what I like to call *low-maintenance*.
#### Navigating the object graph

Mapless embraces an aggressive *lazy approach*. When you query for models you get them. But if they are composed by other (sub)Mapless, they are going to be references and *only* reify into the proper Mapless model *if* you send them a message and you can do this with arbitrary depth:

    odb do: [ task alert message ].

    odb do: [ task alert class = MaplessReference ].  "<- true"

    odb do: [ task alert description ].  "<- 'You will miss the target!'"

#### Persisting different models

Say for your app you now need to store different kind of models, say `List` or `User` or anything else, how you typically proceed?

This is what happens to you with Mapless:

1. Create a subclass for them.
2. <del>Know what attributes they will need in advance.</del>
3. <del>Create its attributes' instVars.</del>
4. <del>Make accessors for them.</del>
5. <del>Elegantly map their type for each property so it all fits in the database.</del>
6. <del>Patiently re-map them every time you need to change its design.</del>
7. <del>Patiently migrate when you need production data to adopt the new design.</del>
8. Profit.

### How does it look? on Redis (this is work in prgress)

Using Redis supported Mapless models are interesting for:

1. **Caching**. It will hold the data in RAM so you get great response times.
2. **Shared caching**. If your app scales load horizontally, you can use Mapless on Redis as a cache shared across your service images.
3. **Reactivity**. Mapless uses Redis [PUB/SUB](http://redis.io/topics/pubsub) feature to observe/react models among N Pharo worker images enabling to use the [Observer pattern](https://en.wikipedia.org/wiki/Observer_pattern) with [horizontal scaling](http://en.wikipedia.org/wiki/Scalability#Horizontal_and_vertical_scaling).

Here is a workspace for Redis based Mapless models:

    redis := RedisPool instance.
    guy := DummyPerson new
				firstName: 'John';
				lastName: 'Q';
				yourself.
    redis do: [ :c | guy save].
    redis do: [ :c | DummyPerson findAt: '38skolpqv0y9lazmk772hmsed' ].
    redis do: [ :c | (DummyPerson findAt: '38skolpqv0y9lazmk772hmsed') lastName]

### State

This project code is considered beta. Check tests and please contribute!

### Contributions

...are *very* welcomed, send that push request and hopefully we can review it together.

### Direction?

1. We would love to see more unit tests and iterate the reactive features so you can ultimately get an a model in one image being observed in regard to one event by something in another image and that something reacting upon that event. Broadcast and multicast of events would be also a nice feat and not too hard to do. Have design suggestions? Let's have a chat! (find me in Pharo's Discord server)
2. For MongoDB-based Mapless, a nice feature would be to have <code>UserModel ensureIndex: '{ key1: 1, key2: -1 }'</code>

### *Pharo Smalltalk
Getting a fresh Pharo Smalltalk image and its virtual machine is as easy as running in your terminal:
 
    wget -O- https://get.pharo.org | bash

_______

MIT License

Copyright (c) 2014 [Sebastian Sastre](http://sebastiansastre.co)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
