accessing
fromJSONObject: aJsonObjectOrNil
	| modelClass | 
	aJsonObjectOrNil ifNil:[ ^ nil ].

	modelClass := aJsonObjectOrNil at: 'modelClass' ifAbsent:[^nil].
	
	^ (Smalltalk at: modelClass asSymbol) basicNew 
		initializeOn: aJsonObjectOrNil asJsonObject;
		yourself 
