accessing
instanceOf: aMaplessClass where: aCollection 

	| result |

	result :=self database hGet: aCollection values first field: aCollection keys first.
	^ result isNil
		ifTrue: [ nil ]
		ifFalse: [ self onAfterRead: (aMaplessClass fromJSONObject:  (self jsonObjectFromValue: result))]

	
