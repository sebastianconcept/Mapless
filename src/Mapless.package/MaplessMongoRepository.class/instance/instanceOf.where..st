accessing
instanceOf: aMaplessClass where: someConditions
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| result databaseCollection |


	databaseCollection := self databaseCollectionNamed: aMaplessClass name asString.
	result :=  databaseCollection queryOne: [ :q | q where: someConditions ].

	^result isNil
		ifTrue: [ nil ]
		ifFalse: [ self onAfterRead: (aMaplessClass fromJSONObject: result asJsonObject)  ]