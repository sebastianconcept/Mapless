actions
destroy
	"Removes this instance from the persistent collection"

	self onAboutToDestroy.		
		
	self class databaseCollection removeKey: self oid.
	
	self onDestroyed