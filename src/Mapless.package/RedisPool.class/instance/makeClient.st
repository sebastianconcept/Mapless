actions
makeClient
	"Returns a new client so it can be (re)used in the pool"

	"improve this so it can create connections that are not local"
	^ RedisClient localhost