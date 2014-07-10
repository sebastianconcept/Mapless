accessing
findId: aMongoOID

	^ self findOne: (Dictionary new 
					at: '_id' put: aMongoOID;
					yourself)
		