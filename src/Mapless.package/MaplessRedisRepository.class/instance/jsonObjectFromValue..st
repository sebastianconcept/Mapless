actions
jsonObjectFromValue: aRedisValue 
	
	^ (BSON read: (self unstringify: aRedisValue) readStream) asJsonObject