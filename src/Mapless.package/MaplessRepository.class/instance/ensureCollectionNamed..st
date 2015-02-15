accessing
ensureCollectionNamed: aCollectionName
	"Makes sure there is a collection for this kind of models."

	(self database hasCollectionNamed: aCollectionName) ifFalse:[
		self database addCollection: aCollectionName]
