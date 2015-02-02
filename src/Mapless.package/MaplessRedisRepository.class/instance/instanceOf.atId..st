accessing
instanceOf: aMaplessClass atId: anId

	| result |

	result := self database get: anId.	
	^ result isNil
		ifTrue: [ nil ]
		ifFalse: [ aMaplessClass fromJSONObject:  (self jsonObjectFromValue: result)]