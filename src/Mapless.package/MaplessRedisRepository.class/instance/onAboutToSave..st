reactions
onAboutToSave: aMapless

	super onAboutToSave: aMapless.
	aMapless ensureId.
	aMapless data at: '_id' put: aMapless id.
	