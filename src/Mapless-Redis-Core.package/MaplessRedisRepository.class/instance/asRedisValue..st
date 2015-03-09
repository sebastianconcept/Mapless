actions
asRedisValue: aBSONFriendlyObject
	"Answers aBSONFirendlyObject as value you will expect to have in Redis"
		
	^ self stringify: (BSON write: aBSONFriendlyObject) 