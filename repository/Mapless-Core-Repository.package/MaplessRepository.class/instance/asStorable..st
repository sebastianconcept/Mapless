actions
asStorable: anObject

	^ anObject isCollection 
		ifTrue: [ 
			anObject class = OrderedJsonObject 
				ifTrue:[(JsonObject fromAssociations: anObject associations) collect:[:e|
							self asStorable: e]]
				ifFalse:[anObject collect: [:e| self asStorable: e]]]
		ifFalse: [ (anObject class = MaplessReference)
					ifFalse: [ 
						(anObject isKindOf: Mapless)
							ifTrue:[ anObject asMaplessReference asJsonString ] 
							ifFalse:[ anObject ]]
					ifTrue: [
						(anObject hasModel not or:[ 
						anObject isUnsaved not]) 
							ifTrue: [ anObject asJsonString ]
							ifFalse: [ MaplessUnsavedSubmodel signal: 'This sub model is unsaved. You need to save all sub models before saving a composed model' ]]]