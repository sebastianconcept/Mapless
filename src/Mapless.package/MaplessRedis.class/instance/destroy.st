actions
destroy
	"Removes this instance from the persistent storage"

	self onAboutToDestroy.
		
	self class client remove: self oid.
	
	self onDestroyed 