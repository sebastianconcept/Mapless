actions
destroy: aMapless
	"Removes aMapless from the persistent collection"
	
	self onBeforeDestroy: aMapless.
		
	self basicDestroy: (self storableFor: aMapless data).
	
	self onAfterDestroy: aMapless