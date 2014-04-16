Mapless
=======

Mapless is a small framework for storing objects in a key->data fashion (i.e.: noSQL databases) without requiring any kind of object-data map.  So far only MongoDB is supported. It can use Redis for reactivity (pub/sub) and cache.

###Motivation
I wanted to persist objects with extremely *low friction* and extremely *low maintenance* and great *scaling* and *availability* capabilities so Mapless is totally biased towards that. This framework is what I came up with after incorporating my experience with [Aggregate](https://github.com/sebastianconcept/Aggregate).

*There is no spoon...*

*There is no object-relational impedance...*

*There is no instVars...*

###Loading it in your image 

Take your open image and click for a **menu**, then **tools**, then **Configuration Browser** and search for **Mapless**.

Click **Install Stable Version**

Or...

Use this snippet to load it into your [Pharo](http://www.pharo-project.org/home)* image:

    Gofer it 
		smalltalkhubUser: 'Pharo'
		project: 'MetaRepoForPharo30'; 
		package: 'ConfigurationOfMapless';
		load.
	
    (Smalltalk at: #ConfigurationOfMapless) load

###How does it look? on MongoDB

You can store  and retrieve your Mapless models on MongoDB like a breeze.

Here is a workspace I've used while developing [tasks](http://tasks.flowingconcept.com)

    odb := MongoPool instance databaseAt: 'Reactive'.    odb do:[RTask findAt: 'c472099f-79b9-8ea2-d61f-e5df34b3ed06'].    odb do:[(RTask findAt: 'c472099f-79b9-8ea2-d61f-e5df34b3ed06') isCompleted].
    odb do:[task := RTask findAt: 'c472099f-79b9-8ea2-d61f-e5df34b3ed06'].    odb do:[task save].     task description.
    task isCompleted.
    odb do:[task beCompleted; save; changed].   

###How does it look? on Redis

Redis is interesting for:

1. Caching
2. Reactivity. You can use pub/sub to observe/react models among N Pharo worker images.

Here is a workspace for Redis based Mapless models:

    redis := RedisPool instance.
    guy := MaplessRedisDummyPerson new				firstName: 'John';				lastName: 'Q';				yourself.				
    redis do:[:c| guy save].    redis do:[:c| MaplessRedisDummyPerson findAt: '38skolpqv0y9lazmk772hmsed'].
    redis do:[:c| (MaplessRedisDummyPerson findAt: '38skolpqv0y9lazmk772hmsed') lastName].

###State

This code is considered alpha.Check its tests.

###Contributions

...are very welcomed, send that push request and hopefully we can review it together

###*Pharo Smalltalk
Getting a fresh Pharo Smalltalk image and its virtual machine is as easy as running in your terminal:
 
    wget -O- get.pharo.org/30+vm | bash

_______

MIT - License

2014 - [sebastian](http://about.me/sebastianconcept)

o/
