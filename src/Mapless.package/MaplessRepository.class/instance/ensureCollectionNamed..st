actions
ensureCollectionNamed: aCollectionName
	"Makes sure there is a collection for this kind of models."

	(self hasCollectionNamed: aCollectionName) ifFalse:[
		self addCollection: aCollectionName]
