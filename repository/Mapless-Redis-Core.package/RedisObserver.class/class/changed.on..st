actions
changed: aModel on: aRedisConnection
	"Send a 'heads up' message about a change on aModel to the observers"

	aRedisConnection
		publish: self channelName
		message: 'changed.', aModel id.
