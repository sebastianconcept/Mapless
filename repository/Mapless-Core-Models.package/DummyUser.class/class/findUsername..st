as yet unclassified
findUsername: anUsername

	^self currentRepository 
		instanceOf: self 
		where: (JsonObject newFromPairs: {'username' . anUsername})