actions
destroy: aMapless
	"Removes aMapless from the persistent collection"

	| bsonFriendly filter |
	
	filter := JsonObject new at: aMapless class idAttribute put: aMapless id; yourself. 

	aMapless onAboutToDestroy.
		
	bsonFriendly := self asMongoDocumentFor: filter.
		
	(self databaseCollectionNamed: aMapless class name asString) remove: bsonFriendly.
	
	aMapless onDestroyed