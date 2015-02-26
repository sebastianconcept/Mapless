actions
makeClient
	"Returns a new client so it can be (re)used in the pool"

	^ (MongoAPI 
		host: (ConfigurationFiles at: #Mongo at: #host) 
		port: (ConfigurationFiles at: #Mongo at: #port)) 
			open;
			yourself 