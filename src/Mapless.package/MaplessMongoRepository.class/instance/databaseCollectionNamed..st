accessing
databaseCollectionNamed: aCollectionName
	"Answers the collection for this kind of models hold by the current database"

	^ self database collectionAt: aCollectionName