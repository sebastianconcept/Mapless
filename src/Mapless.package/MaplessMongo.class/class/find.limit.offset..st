accessing
find: someConditions limit: howManyResults offset: startingFromWhichResult

	| result |

	result := self databaseCollection query: [ :q | 
				q 
					limit: howManyResults;
					offset: startingFromWhichResult; 
					where: someConditions ].

	^ (result isNil and:[
	result isEmpty])
		ifTrue: [ #() ]
		ifFalse: [ self fromJSONObjects: result ]
		