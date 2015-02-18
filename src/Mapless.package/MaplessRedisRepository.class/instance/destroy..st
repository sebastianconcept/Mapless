actions
destroy: aMapless
	"Removes this instance from the persistent storage"

	self onBeforeDestroy: aMapless.
		
	self database remove: (self idOf: aMapless).
	
	self onAfterDestroy: aMapless