actions
makeClient
	"Returns a new client so it can be (re)used in the pool"

	| newClient isAuthenticated |
	newClient := (MongoAPI
		host: (OSEnvironment current at: 'MONGO_ADDRESS' ifAbsent: [ 'localhost' ])
		port: (OSEnvironment current at: 'MONGO_PORT' ifAbsent: [ 27017 ]) asInteger)
		open;
		yourself.
	isAuthenticated := self authenticate: newClient.
	isAuthenticated
		ifFalse: [ ^ self error: 'Authentication failed' ].
	self logNewClient: newClient.
	^ newClient