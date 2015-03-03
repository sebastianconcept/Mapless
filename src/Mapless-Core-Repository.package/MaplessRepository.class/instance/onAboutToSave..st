reactions
onAboutToSave: aMapless

	self flag: #deprecated.
	Transcript cr; nextPutAll: (self class name,'>>onAboutToSave: aMapless   is deprecated, use onBeforeSave:').

	self onBeforeSave: aMapless 