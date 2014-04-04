actions
ifUnavailablePurge: aRedisClient
	"Tests aMongoClient and remove it from this pool if invalid."

	aRedisClient isConnected ifFalse:[ self remove:  aRedisClient]