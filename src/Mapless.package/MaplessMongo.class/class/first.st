accessing
first 

	| constraints result |

	constraints := Dictionary new 
					yourself.

	result := self databaseCollection queryOne:[:q| 
				q where: constraints ].
				
	^ (result isNil or:[
	result isEmpty])
		ifTrue: [ nil ]
		ifFalse: [ self fromJSONObject: result first asJsonObject ]
		