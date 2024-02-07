---
layout: guide
title: "The Observer Pattern beyond one Smalltalk image"
date: 2024-01-28 08:50:16 -0300
categories: guides
---

## The Observer Pattern beyond one Smalltalk image

##### Intro

The [Observer Pattern](https://refactoring.guru/design-patterns/observer) is a well-known design regularity with numerous use cases. In Smalltalk images featuring a graphical user interface (GUI), this pattern is leveraged to ensure that a view accurately represents a value in a model after being updated. It achieves this by enabling observer objects to react to events occurring in observed instances without creating tight couplings.

While this approach has proven effective within the confines of a single image, what options are available when your use case requires an architecture spread across multiple images? Wouldn't it be convenient if there were a method for coding cross-image observability as conveniently as if all component were in the same image?

In this guide we're going to unlock this possibility.

##### Overview

We're going to use [Mapless](https://github.com/sebastianconcept/Mapless) with a Redis backend to implement a simple backend Twitter/X-like application named `SimpleTwitter` using [Pharo](https://pharo.org). In this example, from image A we'll create and save a `Tweet`, and from image B, that `Tweet` will be observed to locally get its current values of likes and reposts.

![]({{ '/images/PubsubDiagram.png' | relative_url }}){:width="100%" class="imageParagraph"}

- **Smalltalk image A**. Creates the tweet with ID 321, saves it and publish events when people like or repost that tweet.

- **Smalltalk image B**. Fetches the same tweet ID 321 from the storage, adds a subscription to the published event of interest `someoneReacted` and a reaction handler `onTweetReaction` receives the `value:` message with the arguments received from the remote published tweet event every time .

##### Requirements

- [Redis](https://redis.io/). Local or not, you'll need Redis to be available for this to work. If you don't have one installed on your host you can get one up and running quickly using [Docker](https://www.docker.com/products/docker-desktop/) with:

{: .shellTitle }
Terminal
<div class="shell">
<pre>
$ docker run -d --name redis-stack-server -p 6379:6379 redis/redis-stack-server:latest
</pre>
</div>

- **Pharo 11**. If you don't have one, see [installing Pharo](/guides/2024/02/06/installing-pharo.html) to get a fresh image and VM.

##### 1. Download and open 2 Smalltalk images
For this we'll be using 2 [Pharo](https://pharo.org) images.

{: .shellTitle }
Terminal 1
<div class="shell">
<pre>
$ mkdir imageA
$ cd imageA
$ curl get.pharo.org/64/110 | bash
$ curl get.pharo.org/64/vm110 | bash
$ ./pharo-ui Pharo.image
</pre>
</div>

{: .shellTitle }
Terminal 2
<div class="shell">
<pre>
$ mkdir imageB
$ cd imageB
$ curl get.pharo.org/64/110 | bash
$ curl get.pharo.org/64/vm110 | bash
$ ./pharo-ui Pharo.image
</pre>
</div>

##### 2. Load Mapless with Redis

By default, Mapless doesn't include the observability feature when installed with a Redis backend. To enable remote observability, let's install it with the optional `Mapless-Redis-Observer` package. This will add the `subscribe` and `publish` family of methods in the `MaplessRedisRepository` object. Load them with the `Redis-Observer-Tests` too so you can learn more about them by looking at the unit tests.

{: .shellTitle }
Playground on Pharo 11

<div class="shell">
{% highlight st %}
"Load latest version of Mapless with its Core, Redis and Redis-Observer packages"
Metacello new
  baseline: 'Mapless';
  repository: 'github://sebastianconcept/Mapless:latest/src';
  load: #('Core' 'Redis' 'Redis-Observer' 'Redis-Observer-Tests') 
{% endhighlight %}
</div>

##### 3. Creating the application code
Now it's time to structure your application code.

For this example we're going to remotely react observing one particular tweet instance, so we create a class for it: 

{: .shellTitle }
Give structure to your application

<div class="shell">
{% highlight st %}
"Evaluate in Image A and Image B"

"Custom class to model your data."
Mapless subclass: #Tweet
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'SimpleTwitter-Mapless'
{% endhighlight %}

</div>

##### 4. Using your code
Now you can wire the observer/observed relationship and how your application reacts to events.

{: .shellTitle }
Create and save the Tweet

<div class="shell">
{% highlight st %}
"Evaluate in Image A"

"Get the Mapless repository used for both, storage and PUBSUB channel"	
repository := MaplessRedisHelper repository.

"Create and store a new Tweet Mapless object"
repository do: [
  tweet := Tweet new
    content: 'What is the answer?';
    reposts: 0;
    likes: 0;
    save ].
{% endhighlight %}

</div>

{: .shellTitle }
Get the ID of that tweet and create the reaction handler

<div class="shell">
{% highlight smalltalk %}
"Evaluate in Image A"

"Copy the value of the tweet ID to use it from image B"
tweet id.      

reactions := {  
  #like -> [ tweet likes: tweet likes + 1 ].
  #repost -> [ tweet reposts: tweet reposts + 1 ].
  } asDictionary.

  "Create handler for when tweet reactions are published"
  onTweetReaction := [ :typeOfReaction |
    (reactions at: typeOfReaction) value.
    repository save: tweet.

    Transcript crShow: ('This tweet has {1} reposts and {2} likes' format: {
      tweet reposts asString.
      tweet likes asString }) ].

{% endhighlight %}

</div>

{: .shellTitle }
Subscribe to an event
<div class="shell">
{% highlight st %}
"Evaluate in Image A"

"Make this tweet to observe the #someoneReacted event"
tweet subscribe: #someoneReacted send: #value: to: onTweetReaction.
{% endhighlight %}
</div>

Now we can start publishing events from **Image B**.

{: .shellTitle }
Publish events
<div class="shell">
{% highlight st %}
"Evaluate in Image B"

"Get the Mapless repository used for both, storage and PUBSUB channel"	
repository := MaplessRedisHelper repository.

id := 'Replace this string with the ID value you copied from the saved tweet in Image A'.

"Fetch the mapless that is the observed object of interest"
repository do: [
  tweet :=  Tweet findAt: id ].

"Make the tweet publish the #someoneReacted event sending
either a #like or a #repost payload to the channel."
tweet publish: #someoneReacted with: { #like. #repost } atRandom.
{% endhighlight %}
</div>

And with that, when you make that `tweet` publish `#someoneReacted` from `Image B`, your handler in `Image A` will be receiving `value:` with the payload as argument every time.

And if you need to dynamically stop reacting to certain event, you just `unsubscribe:` from it.

{: .shellTitle }
Unsubscribe from events
<div class="shell">
{% highlight st %}
"Evaluate in Image A"

"Make this tweet to stop observing the #someoneReacted event"
tweet unsubscribe: #someoneReacted.
{% endhighlight %}
</div>

##### 5. Result

Enjoy your `SimpleTwitter` with Smalltalk!

![]({{ '/images/observer2.gif' | relative_url }}){:width="100%"}
