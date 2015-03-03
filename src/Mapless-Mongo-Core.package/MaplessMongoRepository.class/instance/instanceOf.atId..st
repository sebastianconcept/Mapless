accessing
instanceOf: aMapless atId: anId

	^self  
		instanceOf: aMapless 
		where: (Dictionary newFromPairs: {self idAttribute. anId})