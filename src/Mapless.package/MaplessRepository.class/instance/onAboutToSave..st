reactions
onAboutToSave: aMapless

	#deprecated.
	Transcript cr; nextPutAll: (self class name,'>>onAboutToSave: aMapless   is deprecated, use onBeforeSave:').

	aMapless modifiedOn: DateAndTime now