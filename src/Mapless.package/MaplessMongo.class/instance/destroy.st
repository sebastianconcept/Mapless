actions
destroy
	"Removes this instance from the persistent collection"

	| bsonFriendly filter |
	
	filter := JsonObject new at: self class idAttribute put: self id; yourself. 

	self onAboutToDestroy.
		
	bsonFriendly := self asMongoDocumentFor: filter.
		
	self class databaseCollection remove: bsonFriendly.
	
	self onDestroyed
