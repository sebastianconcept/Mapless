Class {
	#name : #MaplessUnQLiteResolver,
	#superclass : #MaplessResolver,
	#category : #'Mapless-UnQLite-Core-Core'
}

{ #category : #converting }
MaplessUnQLiteResolver >> storableFor: aMapless in: aMaplessRepository [
	"Returns a new JsonObject that's a serializable friendly 
	version of the jsonObject of aMapless.
	It does that by deep visiting and casting all its values. 
	It will complain if sub models are not previously saved."

	| storableDocument |
	storableDocument := JsonObject new.
	aMapless maplessData
		keysAndValuesDo:
			[ :key :value | storableDocument at: key put: (aMaplessRepository asStorable: value) ].
	^ storableDocument
]
