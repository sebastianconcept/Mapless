accessing
find: someConditions limit: toHowManyResults

	| result |

	result := self databaseCollection queryOne:[:q| 
				q limit: toHowManyResults; where: someConditions].

	^ result isNil
		ifTrue: [ nil ]
		ifFalse: [ self fromJSONObject: result asJsonObject ]
		