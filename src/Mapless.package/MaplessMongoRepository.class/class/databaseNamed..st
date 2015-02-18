actions
databaseNamed: aDatabaseName
	"Returns the database found at aDatabaseName"
	
	^ MongoPool instance databaseAt: aDatabaseName 