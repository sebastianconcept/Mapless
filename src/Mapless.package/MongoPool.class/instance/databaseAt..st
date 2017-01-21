actions
databaseAt: aDatabaseName 

	self do:[ :client |
		^ client databaseNamed: aDatabaseName ]