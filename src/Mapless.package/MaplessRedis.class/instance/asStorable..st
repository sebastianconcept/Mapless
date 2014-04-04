actions
asStorable: anObject
	"Answers anObject in a way that makes it storable."

	^ anObject isCollection 
		ifTrue: [ anObject collect: [:e| self asStorable: e] ]
		ifFalse: [ (anObject class = MaplessReference)
					ifFalse: [ 
						(anObject isKindOf: MaplessMongo)
							ifTrue:[ anObject asMaplessReference asJsonString ] 
							ifFalse:[ anObject ]]
					ifTrue: [
						(anObject hasModel not or:[ 
						anObject isUnsaved not]) 
							ifTrue: [ anObject asJsonString ]
							ifFalse: [ MaplessUnsavedSubmodel signal: 'This sub model is unsaved. You need to save all sub models before saving a composed model' ]]]