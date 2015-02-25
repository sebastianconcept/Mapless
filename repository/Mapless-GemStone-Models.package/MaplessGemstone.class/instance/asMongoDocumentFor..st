actions
asMongoDocumentFor: aJsonObject
	"Returns a new JsonObject that's the BSON friendly version of aJsonObject
	by visinting all the values. It will complain if sub models are not previously saved."
	
	| mongoDocument storablePart |
		
	mongoDocument := JsonObject new.

	aJsonObject keysAndValuesDo: [ :k :v | 
		storablePart := self asStorable: v.
		mongoDocument 
			at: k
			put: storablePart ].

	^ mongoDocument