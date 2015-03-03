actions
databaseNamed: aDatabaseName
	"Returns the database found at aDatabaseName"
	
	"Currently we are using Postgres in single database mode.
	Which database is going to use is controlled by the Postgres configuration file."
	^ PostgresPool instance 