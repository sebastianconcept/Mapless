actions
ensureCollection
	"Makes sure there is a collection for this kind of models."
	
	(self database hasCollectionNamed: self databaseCollectionName) ifFalse:[
		self database addCollection: self databaseCollectionName]
