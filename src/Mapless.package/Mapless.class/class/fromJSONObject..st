actions
fromJSONObject: aJsonObjectOrNilOrArray

	| modelClass | 
	aJsonObjectOrNilOrArray ifNil: [ ^ nil ].
	aJsonObjectOrNilOrArray isArray ifTrue: [ ^ self fromJSONObjects: aJsonObjectOrNilOrArray ].
	 
	modelClass := aJsonObjectOrNilOrArray at: 'modelClass' ifAbsent: [ ^nil ].
	
	^ (Smalltalk at: modelClass asSymbol) basicNew 
		initializeOn: aJsonObjectOrNilOrArray asJsonObject;
		yourself 
