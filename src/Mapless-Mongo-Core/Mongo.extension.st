Extension { #name : #Mongo }

{ #category : #'*Mapless-Mongo-Core' }
Mongo >> authenticateUsername: user password: pass database: aDatabaseName [
	^ self authMechanism
		authenticateUsername: user
		password: pass
		database: (MongoDatabase root: self name: aDatabaseName)
]

{ #category : #'*Mapless-Mongo-Core' }
Mongo >> isAvailable [
	"Return true when it is possible to connect to the mongo DB instance, false otherwise.
	 When it is available it is also opened."

	^ self isOpen
]

{ #category : #'*Mapless-Mongo-Core' }
Mongo >> printOn: aStream [
	aStream
		nextPutAll: self class name , ' (';
		nextPutAll: host asString;
		nextPut: $:;
		nextPutAll: port asString;
		nextPut: $)
]
