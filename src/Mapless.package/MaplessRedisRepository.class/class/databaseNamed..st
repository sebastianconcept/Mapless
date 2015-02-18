actions
databaseNamed: aDatabaseName
	"Returns the database found at aDatabaseName"
	
	^ RedisPool instance requestClient