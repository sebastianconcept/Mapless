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
MaplessMongoAPITest >> testGetMongoInfo [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self assert: api admin isMaster class equals: MongoIsMaster.
	api close
]
