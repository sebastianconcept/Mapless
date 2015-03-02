actions
observe
	
	self session 
		subscribe: (Array with: RedisObserver channelName)
		callback: [ :c :t :m | self onMessage: m ]