initialization
initializeOn: aMaplessRedisModel

	modelClass := aMaplessRedisModel class name.
	message := #modelChanged:.
	modelId := aMaplessRedisModel id.