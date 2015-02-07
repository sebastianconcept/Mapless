reactions
onBeforeSave: aMapless

	super onBeforeSave: aMapless.
	
	aMapless ensureId.

	aMapless data at: '_id' put: aMapless id.
	