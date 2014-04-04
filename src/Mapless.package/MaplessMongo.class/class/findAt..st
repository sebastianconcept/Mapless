accessing
findAt: aMongoOID

	^ self find: (Dictionary new 
					at: '_id' put: aMongoOID;
					yourself)
		