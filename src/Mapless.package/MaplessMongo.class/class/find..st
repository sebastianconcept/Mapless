accessing
find: someConditions 

	| result |

	result := self databaseCollection query:[:q| 
				q where: someConditions].

	^ (result isNil and:[
	result isEmpty])
		ifTrue: [ #() ]
		ifFalse: [ self fromJSONObjects: result ]
		