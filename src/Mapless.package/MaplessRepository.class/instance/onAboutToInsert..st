reactions
onAboutToInsert: aMapless

	#deprecated.
	Transcript cr; nextPutAll: (self class name,'>>onAboutToInsert: aMapless   is deprecated, use onBeforeInsert:').
	
	aMapless ensureId