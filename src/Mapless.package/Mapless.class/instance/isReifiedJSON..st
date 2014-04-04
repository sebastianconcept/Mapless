testing
isReifiedJSON: anObject 
	^ (anObject isKindOf: JsonObject) or:[
	anObject isKindOf: OrderedJsonObject ] 