accessing
databaseCollection
	"Answers the collection for this kind of models hold by the current database"
	
	self ensureCollection.
	
	^ self database collectionAt: self databaseCollectionName