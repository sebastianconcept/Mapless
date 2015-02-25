accessing
databaseCollectionNamed: aCollectionName
"Answers the collection for this kind of models hold by the current database"
	
	self ensureCollectionNamed: aCollectionName.
	
	^ self database collectionAt: aCollectionName