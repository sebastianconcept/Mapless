accessing
authenticationDatabaseName
	^ OSEnvironment current at: 'DB_AUTH_NAME' ifAbsent: [ 'admin' ]