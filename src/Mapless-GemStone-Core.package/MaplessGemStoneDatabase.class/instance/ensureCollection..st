other
ensureCollection: aStringKey
  ^ (self hasCollectionNamed: aStringKey)
    ifTrue: [ self collectionAt: aStringKey ]
    ifFalse: [ self addCollection: aStringKey ]