actions
authenticate: mongoClient
	^ mongoClient
		authenticateUsername: self username
		password: self password
		database: self authenticationDatabaseName