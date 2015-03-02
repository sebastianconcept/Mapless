actions
fresh

	^ self isUnsaved 
		ifTrue: [ self ]
		ifFalse: [ self class findId: self id ]