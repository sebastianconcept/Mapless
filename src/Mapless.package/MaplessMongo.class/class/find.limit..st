accessing
find: someConditions limit: toHowManyResults

	| result |

	result := self databaseCollection query: [ :q | 
				q limit: toHowManyResults; where: someConditions ].

	^ (result isNil and:[
	result isEmpty])
		ifTrue: [ #() ]
		ifFalse: [ self fromJSONObjects: result ]
		