setUp-tearDown
setUp
	super setUp.
	pool := RedisPool instance.
	repository   := MaplessRedisRepository on: pool requestClient