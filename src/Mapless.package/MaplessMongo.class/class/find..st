accessing
find: someConditions 

	| result |

	result := self databaseCollection query:[:q| 
				q where: someConditions].

	^ result isNil
		ifTrue: [ Array new ]
		ifFalse: [ result collect: [ :each| 
					self fromJSONObject: each asJsonObject ] ]
		