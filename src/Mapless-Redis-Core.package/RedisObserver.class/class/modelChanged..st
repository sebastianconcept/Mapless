actions
modelChanged: aMaplessRedisModel
	"Spread the word about a change on aMaplessRedisModel."
	
	RedisPool instance do:[:api|
		self 
			changed: aMaplessRedisModel
			on: api]
		
	