other
addDatabase: aDatabase ifPresent: aBlock
	| added |
	added := false.
	databases
		at: aDatabase name
		ifAbsentPut: [
			added := true.
			aDatabase ].
	added ifFalse: [ aBlock value ]