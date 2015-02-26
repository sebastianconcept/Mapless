other
databaseNames
	^Array streamContents: [ :stream |
		databases valuesCollect: [ :each |
			stream nextPut: each name ] ]