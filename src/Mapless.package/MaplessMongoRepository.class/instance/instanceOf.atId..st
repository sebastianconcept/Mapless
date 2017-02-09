accessing
instanceOf: aMaplessClass atId: anId

	^self  
		instanceOf: aMaplessClass 
		where: (Dictionary newFromPairs: {self idAttribute. anId})