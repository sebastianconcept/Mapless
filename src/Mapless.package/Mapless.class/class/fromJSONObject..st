actions
fromJSONObject: aJsonObjectOrNilOrArray

	| modelClass | 
	aJsonObjectOrNilOrArray ifNil: [ ^ nil ].
	aJsonObjectOrNilOrArray isArray ifTrue: [ ^ self fromJSONObjects: aJsonObjectOrNilOrArray ].
	 
	"If the content has metadata then it will use it to decide what instances to create.
	When there is no Mapless metadata available, the assumption is 
	that it should create instances of this class of Mapless."
	modelClass := aJsonObjectOrNilOrArray at: 'modelClass' ifAbsent: [ self name ].
	
	^ (Smalltalk at: modelClass asSymbol) basicNew 
		initializeOn: aJsonObjectOrNilOrArray asJsonObject;
		yourself 
