accessing
databaseName

	^ OSEnvironment default at: 'DB_NAME' ifAbsent: [ 'admin' ]