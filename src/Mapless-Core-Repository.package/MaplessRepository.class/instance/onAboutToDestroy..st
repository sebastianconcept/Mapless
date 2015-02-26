reactions
onAboutToDestroy: aMapless

	self flag: #deprecated.
	Transcript cr; nextPutAll: (self class name,'>>onAboutToDestroy: aMapless   is deprecated, use onBeforeDestroy:').
	
	self onBeforeDestroy: aMapless 