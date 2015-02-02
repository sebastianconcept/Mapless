actions
destroy
	"Removes this instance from the persistent collection"

	| bsonFriendly filter |
	
	filter := JsonObject new at: '_id' put: (data at: '_id'); yourself. 

	self onAboutToDestroy.
		
	bsonFriendly := self asMongoDocumentFor: filter.
		
	self class databaseCollection remove: bsonFriendly.
	
	self onDestroyed
