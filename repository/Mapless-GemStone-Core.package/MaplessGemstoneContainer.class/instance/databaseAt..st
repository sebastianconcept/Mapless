other
databaseAt: aString

	 databases at: aString ifAbsent:[ self createDatabaseNamed: aString ifPresent:[]].
	^ databases at: aString