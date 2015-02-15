actions
destroy: aMapless
	"Removes this instance from the persistent storage"

	self onBeforeDestroy: aMapless.
		
	self database remove: aMapless oid.
	
	self onAfterDestroy: aMapless