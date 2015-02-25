actions
databaseAt: aDatabaseName do: aBlock

	self do:[ :client |
		(client databaseNamed: aDatabaseName) do: [ ^ aBlock value ] ]