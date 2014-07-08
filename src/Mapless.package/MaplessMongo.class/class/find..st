accessing
find: someConditions 

	| result |

	result := self databaseCollection query:[:q| 
				q where: someConditions].

	^ result isNil
		ifTrue: [ nil ]
		ifFalse: [ self fromJSONObject: result asJsonObject ]
		