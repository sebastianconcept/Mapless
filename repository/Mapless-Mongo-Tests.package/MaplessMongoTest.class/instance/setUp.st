setUp-tearDown
setUp
	super setUp.
	pool := MongoPool instance.
	repository   := MaplessMongoRepository on: (pool databaseAt: 'Mapless-Tests' )