actions
makeClient
	"Returns a new client so it can be (re)used in the pool"

	^ (MongoAPI 
		host: (OSEnvironment default at: 'MONGO_ADDRESS' ifAbsent: [ 'localhost' ])
		port: (OSEnvironment default at: 'MONGO_PORT' ifAbsent: [ 27017 ]) asInteger)
			open;
			yourself