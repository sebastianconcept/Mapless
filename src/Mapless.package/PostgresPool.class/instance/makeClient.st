actions
makeClient
	"Returns a new client so it can be (re)used in the pool"

	^ PGConnection new
		connectionArgs: (PGConnectionArgs
		hostname: (ConfigurationFiles at: #Postgres at: #host)
		portno: (ConfigurationFiles at: #Postgres at: #port)
		databaseName: (ConfigurationFiles at: #Postgres at: #database)
		userName: (ConfigurationFiles at: #Postgres at: #username)
		password: (ConfigurationFiles at: #Postgres at: #password));
		yourself 