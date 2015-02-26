accessing
find: someConditions 

	| result |
	result := self databaseCollection.

	someConditions keysAndValuesDo: [:key :value | result := result select: [:each | (each data at: key ifAbsent:[]) = value ] ].

	^result