actions
destroy: aMapless
	"Removes this instance from the persistent storage"

	self onAboutToDestroy: aMapless.
	
	aMapless beDeleted.
		
	self database remove: aMapless oid.
	
	self onDestroyed: aMapless