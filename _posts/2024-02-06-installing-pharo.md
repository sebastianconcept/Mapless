---
layout: guide
title:  "Installing Pharo"
date:   2024-02-06 18:39:16 -0300
categories: guides
---


### Installing Pharo


##### Image and VM 
You can install [Pharo](https://pharo.org) in several ways as described [here](https://pharo.org/download).

The recommended way here is to do it to do it from the command line as you would in a [CI](https://martinfowler.com/books/continuousDelivery.html) production version build using: 

{: .shellTitle }
Terminal
<div class="shell">
<pre>
$ mkdir my-new-pharo-project
$ cd my-new-pharo-project
my-new-pharo-project$ curl get.pharo.org/64/110 | bash
my-new-pharo-project$ curl get.pharo.org/64/vm110 | bash
</pre>
</div>

Where the `110` denotes the version for [Pharo](https://pharo.org) 11 and the first command is for the image and the second for the VM.

With that you are basically ready to start.

{: .shellTitle }
Terminal
<div class="shell">
<pre>
my-new-pharo-project$ ./pharo-ui Pharo.image
</pre>
</div>


##### Productivity customization
Would you prefer a dark theme for your IDE?

Here is a nice warm dark theme for [Pharo](https://pharo.org)

{: .shellTitle }
Playground on Pharo

<div class="shell">
{% highlight st %}
"Loads the Dawn theme in Pharo"
Metacello new 
	baseline: 'PharoDawnTheme';
	repository: 'github://sebastianconcept/PharoDawnTheme:pharo11';
	load.	
{% endhighlight %}
</div>

And this is a nice window manager for [Pharo](https://pharo.org): [TilingWindowManager](https://github.com/Pharophile/TilingWindowManager)

{: .shellTitle }
Playground on Pharo

<div class="shell">
{% highlight st %}
"Loads the Dawn theme in Pharo"
Metacello new 
  githubUser: 'pharophile' 
  project: 'TilingWindowManager' 
  commitish: 'master' 
  path: 'packages';
  baseline: 'TilingWindowManager';
  onWarningLog; 
  load.
{% endhighlight %}
</div>