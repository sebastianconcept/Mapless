reactions
onAboutToInsert: aMapless

	self flag: #deprecated.
	Transcript cr; nextPutAll: (self class name,'>>onAboutToInsert: aMapless   is deprecated, use onBeforeInsert:').
	
	self onBeforeInsert: aMapless 