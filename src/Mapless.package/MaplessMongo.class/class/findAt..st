accessing
findAt: aMongoOID

	^ self findOne: (Dictionary new 
					at: '_id' put: aMongoOID;
					yourself)
		