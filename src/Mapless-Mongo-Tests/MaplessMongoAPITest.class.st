Class {
	#name : #MaplessMongoAPITest,
	#superclass : #MaplessTestCase,
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #tests }
MaplessMongoAPITest >> testConnectUsingMongoUrl [

	| api mongoUrl |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.
	self assert: api isValid.
	api close.
	self deny: api isValid.
	mongoUrl := ZnUrl fromString: 'mongodb://localhost:27017'.
	self assert: api asMongoUrl equals: mongoUrl.

	self assert: (api isAt: mongoUrl)
]

{ #category : #tests }
MaplessMongoAPITest >> testGetAdminDatabase [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self assert: api admin class equals: MongoDatabase.
	api close
]

{ #category : #tests }
MaplessMongoAPITest >> testGetMongoInfo [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self assert: api admin isMaster class equals: MongoIsMaster.
	api close
]

{ #category : #tests }
MaplessMongoAPITest >> testInitializeIsPrimary [

	| api result |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self shouldnt: [ result := api isPrimary ] raise: Error.
	self deny: result.
	api close
]

{ #category : #tests }
MaplessMongoAPITest >> testIsPrimary [

	| api result |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self
		shouldnt: [ result := api admin isMaster isPrimary ]
		raise: Error.
	self deny: result.
	api close
]

{ #category : #tests }
MaplessMongoAPITest >> testIsReadOnly [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self shouldnt: [ api isPrimary ] raise: Error.
	self assert: api isReadOnly.
	api close
]

{ #category : #tests }
MaplessMongoAPITest >> testIsReadWrite [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self shouldnt: [ api isPrimary ] raise: Error.
	self deny: api isReadWrite.
	api close
]

{ #category : #tests }
MaplessMongoAPITest >> testIsType [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self shouldnt: [ api isPrimary ] raise: Error.

	self assert: (api isType: #readOnly).
	api close
]

{ #category : #tests }
MaplessMongoAPITest >> testResetRole [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self shouldnt: [ api isPrimary ] raise: Error.

	self assert: (api isType: #readOnly).

	self shouldnt: [ api resetIsPrimary ] raise: Error.
	self shouldnt: [ api isPrimary ] raise: Error.
	self assert: (api isType: #readOnly).
	api close
]
