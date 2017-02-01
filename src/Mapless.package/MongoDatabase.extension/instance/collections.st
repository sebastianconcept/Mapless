*Mapless
collections
	| query reply names real stripped |
	"query := MongoQuery new collection: (MongoMetaCollection name: 'system.namespaces').
	reply := self query: query."
	"Drop options on the floor for now"
	"names := reply collect: [:each | each at: 'name'].
	real := names select: [:each | (each occurrencesOf: $.) = 1].
	stripped := real collect: [:each | each readStream upTo: $.; upToEnd]."
	
	stripped := (self command: { #listCollections -> 1 } asDictionary) cursor firstBatch collect: [ :e | e name ].
		
	^stripped collect: [:each | MongoCollection database: self name: each]