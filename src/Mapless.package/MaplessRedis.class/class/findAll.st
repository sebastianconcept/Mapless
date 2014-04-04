accessing
findAll
	"Potentially costly operation.
	Returns all objects stored in the collection."
	
	| constraints result |

	constraints := Dictionary new.
	
	result := self databaseCollection query:[:q| 
				q where: constraints].
			
	^ (result isNil and:[
	result isEmpty])
		ifTrue: [ #() ]
		ifFalse: [ self fromJSONObjects: result ]
		