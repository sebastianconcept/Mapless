actions
reset
	
	session notNil ifTrue:[
		session unsubscribe: (Array with: RedisObserver channelName).
		session disconnect.
		session := nil]