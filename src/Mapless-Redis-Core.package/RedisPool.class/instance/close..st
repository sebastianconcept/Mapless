actions
close: aRedisClient

	aRedisClient isConnected ifTrue:[
		aRedisClient flushAll; quit].
