actions
destroy: aMapless
	"Removes aMapless from the persistent collection"

	| filter |
	
	self onBeforeDestroy: aMapless.

	filter := JsonObject new at: aMapless class idAttribute put: aMapless id; yourself. 
		
	self basicDestroy: (self storableFor: filter).
	
	self onAfterDestroy: aMapless