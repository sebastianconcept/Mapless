accessing
findUsername: anUsername

	^ self fromJSONObject: ( self databaseCollection detect: [ :each | 
		( each username = anUsername ) ] )