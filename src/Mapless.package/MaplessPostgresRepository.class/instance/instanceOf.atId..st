accessing
instanceOf: aMapless atId: anId

	^ self  
		instanceOf: aMapless 
		where: (JsonObject newFromPairs: {self idAttribute. anId})