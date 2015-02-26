reactions
onAboutToDelete: aMapless

	self flag: #deprecated.
	Transcript cr; nextPutAll: (self class name,'>>onAboutToDelete: aMapless   is deprecated, use onBeforeDelete:').
	
	self onBeforeDelete: aMapless 