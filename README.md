Mapless
=======

*Obscenely simple persistence for Smalltalk.* Mapless is a small framework for storing objects in a key->data fashion (i.e.: noSQL databases) without requiring any kind of object-data map.  Supported backends are MongoDB and Redis. 

*There is no instVars...*

*There is no accessors...*

*There is no object-mapping impedance...*


*Only persistence.*

### Applicability

Mapless can be used for Model persistence, trans-image observer pattern, object oriented cache and network JSON communication.

### Motivation
> "I wanted to persist objects with *low friction* and *low maintenance* but *high scaling* and *availability* capabilities so Mapless is totally biased towards that. This framework is what I came up with after incorporating my experience with [Aggregate](https://github.com/sebastianconcept/Aggregate) in [airflowing](http://airflowing.com)." ~ [Sebastian](http://about.me/sebastianconcept)

### Loading

Take your open image and click for a **menu**, then **tools**, then **Configuration Browser** and search for **Mapless**. Click **Install Stable Version**

However, it's recommended that you use Metacello to load your projects...

Use this snippet to fetch the Baseline and load it in your [Pharo](http://www.pharo-project.org/home)* image:

    Metacello new
    	baseline: 'Mapless';
    	repository: 'github://flow-stack/Mapless:master/repository';
    	get.
    	
To load Mapless alone, with no backend database (likely only for Mapless contributors):

    Metacello new
    	baseline: 'Mapless';
    	repository: 'github://flow-stack/Mapless:master/repository';
    	load.
	
There are many backend options you can load. Use the following snippet to load one or more backend database(s):

	Metacello new
    	baseline: 'Mapless';
    	repository: 'github://flow-stack/Mapless:master/repository';
    	load: #('Mongo' 'Redis' 'Postgres' 'GemStone').

NOTE: If you are running on the GemStone platform, the GemStone classes are automatically loaded along with Mapless.

To load the both the database classes and the corresponding tests, use the following snippet:

	Metacello new
    	baseline: 'Mapless';
    	repository: 'github://flow-stack/Mapless:master/repository';
    	load: #('Mongo Tests' 'Redis Tests' 'Postgres Tests' 'GemStone Tests').

To load everything available for your platform, including the tests:

	Metacello new
    	baseline: 'Mapless';
    	repository: 'github://flow-stack/Mapless:master/repository';
    	load: #('all').

### How does it look?

You can store  and retrieve your Mapless models on MongoDB like a breeze. Here is a couple of snippets used while developing [tasks](http://tasks.flowingconcept.com).

#### Getting the connection

    odb := MongoPool instance databaseAt: 'YourMongoDatabase'.
    
####Create a new model

Just subclass MaplessModel. Here we use a Task model:

    task := Task new description: 'Try Mapless'; beIncomplete.

#### Save it

In Mapless you do things using a #do: closure which Mapless uses to automatically discern which MongoDB database and collection has to be used. It also will know if it needs to do an insert or an update. As a bonus, you get the collection *and* the database created lazily. 

Want to save something? Zero bureaucracy, just tell that to the model:
    odb do:[ task save ].

At [flowing](http://flowingconcept.com) we call this the *low-friction* way to do it.

#### Fetching stuff

Getting all models of a given class:
    odb do:[ Task findAll ].

Getting a specific model:
    odb do:[ Task findId: 'c472099f-79b9-8ea2-d61f-e5df34b3ed06' ].

For getting efficiently a (sub)group of models, you write your own Mapless class side getters. They should act on the MongoDB indices with the parameters of your query. You'll get your models in a breeze:

    odb do:[ Task findAtUsername: 'awesomeguy' ].

#### Adding something to a model

You can use Mapless models pretending they are [prototypical](http://en.wikipedia.org/wiki/Prototype-based_programming) like in [Self](http://en.wikipedia.org/wiki/Self_(programming_language)) or [Javascript](http://en.wikipedia.org/wiki/JavaScript) objects. No instVars. No setters. No getters. All just works:

    odb do:[
    	task 
    		deadline: Date tomorrow; 
    		notes: 'Wonder how it feels to use this thing, hmm...';
    		save].

#### Need composition? 

Of course you do! The only thing you need is to save the children first
    odb do:  [  | anAlert |
      anAlert := Alert new 
      				duration: 24 hours;
      				message: 'You will miss the target!';
      				save.
    	task 
    		alert: anAlert;
    		save ]

This is what [we](http://flowingconcept.com) call *low-maintenance*.
#### Navigating the object graph
Mapless embraces an aggressive *lazy approach*. When you query for models you get them. But if they are composed by other (sub)Mapless, they are going to be references and *only* reify into the proper Mapless model *if* you send them a message and you can do this with arbitrary depth:

    odb do: [ task alert message ].   

    odb do: [ task alert class = MaplessReference ].  "<- true"   

    odb do: [ task alert description ].  "<- 'You will miss the target!'"   

#### Persisting a different model

So you now need to store a different kind of models, say List or User or anything, how you proceed? 

This is what happens to you with Mapless:

1. Create a subclass for them
2. <del>Know what attributes they will need in advance</del>
3. <del>Create its attributes' instVars</del>
4. <del>Make accessors for them</del>
5. <del>Elegantly map them so it all fits in the database</del>
6. <del>Patiently re-map them every time you need to change its design</del>
7. Profit

### How does it look? on Redis

Redis is interesting for:

1. **Caching**. It will hold the data in RAM so you get great response times.
2. **Reactivity**. Mapless uses Redis [PUB/SUB](http://redis.io/topics/pubsub) feature to observe/react models among N Pharo worker images enabling [horizontal scaling](http://en.wikipedia.org/wiki/Scalability#Horizontal_and_vertical_scaling).

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

This code is considered beta. Check tests and contribute!

### Contributions

...are *very* welcomed, send that push request and hopefully we can review it together.

### Direction?

1. We would love to see more and better tests and iterate the reactive features so you can ultimately get an a model in one image being observed in regard to one event by something in another image and that something reacting upon that event. Broadcast and multicast of events would be also a nice feat and not too hard to do. Have design suggestions? Let's have a chat!
2. For MongoDB-based Mapless, a nice feature would be to have <code>UserModel ensureIndex: '{ key1: 1, key2: -1 }'</code>
3. We actually are starting to think [Amber](http://amber-lang.net) and [localStorage](http://en.wikipedia.org/wiki/Web_storage) but that's more hush hush at this point. Oh gee! [we already](https://www.youtube.com/watch?v=ZDC1N5wYsMg) blown it!

### *Pharo Smalltalk
Getting a fresh Pharo Smalltalk image and its virtual machine is as easy as running in your terminal:
 
    wget -O- get.pharo.org/30+vm | bash

_______

MIT - License

2014 - [sebastian](http://about.me/sebastianconcept)

o/
