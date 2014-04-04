actions
destroy
	"Removes this instance from the persistent collection"

	| bsonFriendly |
	
	bsonFriendly := self asMongoDocument.

	self onAboutToDestroy.
		
	self class databaseCollection remove: bsonFriendly.
	
	self onDestroyed 