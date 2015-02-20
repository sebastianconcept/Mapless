actions
ifUnavailablePurge: aRedisClient
	"Tests aRedisClient and remove it from this pool if invalid."

	aRedisClient isConnected ifFalse: [ 
		self remove:  aRedisClient ]