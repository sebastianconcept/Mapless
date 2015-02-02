accessing
getMongoModel

	| class |
	
	class := Smalltalk 
				at: modelClass asSymbol 
				ifAbsent:[ self error: 'This image does not have ',modelClass asString,' class' ].
	
	^ class findAt: oid 
	
	