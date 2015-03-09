actions
destroy: aMapless
	"Removes aMapless from the persistent collection"

	| bsonFriendly filter |
	
	self onBeforeDestroy: aMapless.

	filter := JsonObject new at: aMapless class idAttribute put: aMapless id; yourself. 
		
	bsonFriendly := self storableFor: filter.
		
	(self databaseCollectionNamed: aMapless class name asString) remove: bsonFriendly.
	
	self onAfterDestroy: aMapless