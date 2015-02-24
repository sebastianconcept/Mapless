actions
normalizeIdOf: aMapless
	"Normalizes aMapless id for the API.
	idAttritbute -> 'id'
	Makes sure that aMapless has the id attribute 
	under the name 'id' taking the information from this concrete repository.
	Removes it from the concrete place in case is present (not failing if absent)." 

	"It's either already having the right one or it needs translation..."
	(aMapless data includesKey: self idAttribute) ifTrue: [ 
		aMapless data at: 'id' put: (aMapless data at: self idAttribute) ].
	
	"clean it.
	Note: if a concrete repo one day needs to use 'id' as id, then it needs to override this to not remove here."
	aMapless data removeKey: self idAttribute ifAbsent: [ nil ].
	
	^ aMapless