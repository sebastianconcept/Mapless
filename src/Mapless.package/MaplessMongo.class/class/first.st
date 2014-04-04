accessing
first 

	| constraints result |

	constraints := Dictionary new 
					yourself.

	result := self databaseCollection query:[:q| 
				q 
					where: constraints;
					limit: 1].
				
	^ (result isNil or:[
	result isEmpty])
		ifTrue: [ nil ]
		ifFalse: [ self fromJSONObject: result first asJsonObject ]
		