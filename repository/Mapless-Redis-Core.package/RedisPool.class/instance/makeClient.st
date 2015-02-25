actions
makeClient
	"Returns a new client so it can be (re)used in the pool"

	^ RedisClient 
		server: (ConfigurationFiles at: #Redis at: #host) 
		port: (ConfigurationFiles at: #Redis at: #port) 