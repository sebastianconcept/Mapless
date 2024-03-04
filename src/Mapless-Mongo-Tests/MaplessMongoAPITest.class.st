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
MaplessMongoAPITest >> testGetCollection [

	| repository |
	repository := MaplessMongoRepository
		              for: 'Mapless-Test'
		              with: MaplessStandaloneMongoPool local.

	repository do: [
		self assert: SamplePerson collection class equals: MongoCollection.
		self
			assert: SamplePerson collection name
			equals: SamplePerson collectionName ]
]

{ #category : #tests }
MaplessMongoAPITest >> testGetMongoInfo [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self assert: api admin isMaster class equals: MongoIsMaster.
	api close
]
