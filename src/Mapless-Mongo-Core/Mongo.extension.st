Extension { #name : #Mongo }

{ #category : #'*Mapless-Mongo-Core' }
Mongo >> authenticateUsername: user password: pass database: aDatabaseName [
	^ self authMechanism
		authenticateUsername: user
		password: pass
		database: (MongoDatabase root: self name: aDatabaseName)
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
