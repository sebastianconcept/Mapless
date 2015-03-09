reactions
onAboutToUpdate: aMapless

	self flag: #deprecated.
	Transcript cr; nextPutAll: (self class name,'>>onAboutToUpdate: aMapless   is deprecated, use onBeforeUpdate:').
	
	self onBeforeUpdate: aMapless 