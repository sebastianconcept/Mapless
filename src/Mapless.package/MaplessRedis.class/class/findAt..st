accessing
findAt: anId

	| result |

	result := self valueAt: anId.
			
	^ result isNil
		ifTrue: [ nil ]
		ifFalse: [ self fromValue: result ]
		