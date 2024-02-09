---
layout: guide
title: "RESTful APIs with Mapless and Teapot"
permalink:
date: 2024-02-09 12:00:16 -0300
categories: guides
---

### {{ page.title }}

##### Install Teapot

A RESTful API needs an HTTP so let's install [Teapot](https://pharo.org/) as it's very comfortable to use in .

{: .shellTitle }
Pharo Playground

<div class="shell">
{% highlight st %}
"Loads the HTTP application server in Phar.
If while loading you get a dialog asking for confirmation on Load/Merge/Cancel select Load."
Metacello new
  baseline: 'Teapot';
  repository: 'github://zeroflag/Teapot:v2.7.0/source';
  load.

"Load latest version of Mapless with its default backends (Memory and SQLite)"
Metacello new
  baseline: 'Mapless';
  repository: 'github://sebastianconcept/Mapless:v0.6.0/src';
  load.
{% endhighlight %}

</div>

##### Configure the server

{: .shellTitle }
Pharo Playground

<div class="shell">
{% highlight st %}
"Configure Teapot defaults"
teapot := Teapot configure: {
		#port -> 9090.
		#debugMode -> true.
		#defaultOutput -> #html
	}.

"Add an exception handler to fail gracefully"
teapot exception: Error -> [ :ex :req |
  | content |
  content := (Smalltalk isHeadless and: [ Smalltalk isInteractiveGraphic ])
  ifTrue: [ 'Ouch: {1}' format: { ex messageText } ]
  ifFalse: [ 'Internal error' ].
  TeaResponse serverError body: content.
  ].

"Optionally add a ping route to use as health-check / availability check"
teapot GET: '/ping' -> 'pong'.  
{% endhighlight %}

</div>

##### Give structure to your API

Lets say we're going to implement one endpoint for `Tweet` objects in a `SimpleTwitter` backend. With this `/tweets` endpoint, we're going to be able to do [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) operations following the [RESTful](https://restfulapi.net/) system.

{: .shellTitle }
Pharo Playground

<div class="shell">
{% highlight st %}
"Create an Mapless model, following the SimpleTwitter app, a Tweet class"
Mapless subclass: #Tweet
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'SimpleTwitter-Mapless'
{% endhighlight %}
</div>

##### Setup routes

We need to implement the CRUD operations in their respective routes.

{: .shellTitle }
Pharo Playground

<div class="shell">
{% highlight st %}
"Create"
teapot POST: '/tweets' -> [ :req | 
  "to be done" 
  ].
{% endhighlight %}
</div>

{: .shellTitle }
Pharo Playground

<div class="shell">
{% highlight st %}
"Read"
teapot GET: '/tweets/<tweetId>' -> [ :req | 
  "Use as ID value that was given as part of the URI path to find a corresponding Tweet"
  found := repository findOne: Tweet atId: (req at: #tweetId).

  "Return a 404 if none was found"
  found ifNil:[ ^ TeaResponse notFound ].

  "Return the tweet found "
  { #author -> found author.
  #text -> found text } asDictionary
  ];
  output: #json.
{% endhighlight %}
</div>

{: .shellTitle }
Pharo Playground

<div class="shell">
{% highlight st %}
"Update"
teapot PUT: '/tweets/<tweetId>' -> [ :req | "to be done"  ].
{% endhighlight %}
</div>

{: .shellTitle }
Pharo Playground

<div class="shell">
{% highlight st %}
"Delete"
teapot DELETE: '/tweets/<tweetId>' -> [ :req | "to be done" ].

{% endhighlight %}

</div>

##### Operation

{: .shellTitle }
Pharo Playground

<div class="shell">
{% highlight st %}
"Start the HTTP server."
teapot start.

"Stop the HTTP server."
teapot stop.

{% endhighlight %}

</div>
