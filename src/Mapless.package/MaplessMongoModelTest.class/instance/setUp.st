setUp-tearDown
setUp
	super setUp.
	pool := MongoPool instance.
	mongoRepository   := MaplessMongoRepository on: (pool databaseAt: 'Mapless-Tests')