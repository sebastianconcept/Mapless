accessing
findAt: anId

	^self databaseCollection at: anId ifAbsent:[ nil ]