actions
remove: aRedisClient

	self close: aRedisClient.

	super remove: aRedisClient