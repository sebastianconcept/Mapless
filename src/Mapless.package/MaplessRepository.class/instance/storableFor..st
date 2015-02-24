actions
storableFor: aJsonObject
	"Returns a new JsonObject that's the BSON friendly version of aJsonObject
	by visinting all the values. It will complain if sub models are not previously saved."
	
	| storableDocument storablePart |
		
	storableDocument := JsonObject new.

	aJsonObject keysAndValuesDo: [ :k :v | 
		storablePart := self asStorable: v.
		storableDocument 
			at: k
			put: storablePart ].

	^ storableDocument 