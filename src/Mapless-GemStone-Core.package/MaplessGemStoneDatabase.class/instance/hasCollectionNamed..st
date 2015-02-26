other
hasCollectionNamed: aString
	"Answers true if this database has a collection named aString"
	
	^ (self collectionAt: aString) notNil