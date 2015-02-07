as yet unclassified
findUsername: anUsername

	^self currentRepository 
		instanceOf: self 
		where: (Dictionary newFromPairs: {'username' . anUsername})