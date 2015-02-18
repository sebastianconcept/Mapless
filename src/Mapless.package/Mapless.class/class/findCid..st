accessing
findCid: anId

	^self currentRepository 
		instanceOf: self 
		where: (Dictionary newFromPairs: {'cid'. anId})
	
	