"
I verify that classes that are not subclasses of Mapless but compose the MaplessBehavior trait can be persisted in MongoDB.

The MongoDB to use can be set with the environment variables MAPLESS_MONGO_HOST and MAPLESS_MONGO_PORT (default localhost:27017).
Test data is deliberately not dropped when the tests finish, so it can be inspected with a MongoDB client. Each test starts by cleaning only the collections of the example classes.
"
Class {
	#name : #MaplessBehaviorMongoTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Behavior-Mongo-Tests'
}

{ #category : #accessing }
MaplessBehaviorMongoTest class >> databaseName [

	^ 'Mapless-Behavior-Test'
]

{ #category : #accessing }
MaplessBehaviorMongoTest class >> mongoHost [

	^ OSEnvironment current
		  at: 'MAPLESS_MONGO_HOST'
		  ifAbsent: [ 'localhost' ]
]

{ #category : #accessing }
MaplessBehaviorMongoTest class >> mongoPort [

	^ (OSEnvironment current
		   at: 'MAPLESS_MONGO_PORT'
		   ifAbsent: [ '27017' ]) asInteger
]

{ #category : #actions }
MaplessBehaviorMongoTest >> do: aBlock [

	^ repository do: aBlock
]

{ #category : #'setUp-tearDown' }
MaplessBehaviorMongoTest >> newRepository [

	^ MaplessMongoRepository
		  for: self class databaseName
		  with: (MaplessStandaloneMongoPool
				   hostname: self class mongoHost
				   port: self class mongoPort
				   username: nil
				   password: nil)
]

{ #category : #actions }
MaplessBehaviorMongoTest >> resetCollections [

	{
		ExampleUser.
		ExamplePerson.
		ExampleTag } do: [ :each | self do: [ each findAll do: [ :m | m destroy ] ] ]
]

{ #category : #'setUp-tearDown' }
MaplessBehaviorMongoTest >> setUp [

	super setUp.
	repository := self newRepository.
	self resetCollections
]

{ #category : #'setUp-tearDown' }
MaplessBehaviorMongoTest >> tearDown [

	repository ifNotNil: [ repository shutDown ].
	repository := nil.
	super tearDown
]

{ #category : #tests }
MaplessBehaviorMongoTest >> testComposedReferences [

	| user guy loaded |
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	user := ExampleUser new
		        username: 'johnq';
		        person: guy;
		        yourself.
	self do: [
		guy save.
		user save ].
	self do: [
		loaded := ExampleUser findUsername: 'johnq'.
		self assert: loaded notNil.
		self assert: loaded person class equals: MaplessReference.
		self assert: loaded person model class equals: ExamplePerson.
		self assert: loaded completeName equals: 'john q' ]
]

{ #category : #tests }
MaplessBehaviorMongoTest >> testDestroy [

	| guy |
	guy := ExamplePerson new
		       firstName: 'gone';
		       yourself.
	self do: [
		guy save.
		self assert: (ExamplePerson existsId: guy id).
		guy destroy.
		self deny: (ExamplePerson existsId: guy id).
		self assert: ExamplePerson count equals: 0 ]
]

{ #category : #tests }
MaplessBehaviorMongoTest >> testFindAndCount [

	self do: [
		#( 'ana' 'bob' 'carl' ) do: [ :each |
			ExamplePerson new
				firstName: each;
				save ].
		self assert: ExamplePerson count equals: 3.
		self assert: ExamplePerson findAll size equals: 3.
		self
			assert: (ExamplePerson findOne: { ('firstName' -> 'bob') } asDictionary) firstName
			equals: 'bob'.
		self
			assert: (ExamplePerson find: { ('firstName' -> 'zed') } asDictionary) isEmpty ]
]

{ #category : #tests }
MaplessBehaviorMongoTest >> testMultipleComposedReferences [

	| user guy tags loaded |
	guy := ExamplePerson new
		       firstName: 'jane';
		       lastName: 'd';
		       yourself.
	tags := OrderedCollection
		        with: (ExampleTag new
				         label: 'cool';
				         yourself)
		        with: (ExampleTag new
				         label: 'stuff';
				         yourself).
	user := ExampleUser new
		        username: 'janed';
		        person: guy;
		        tags: tags;
		        yourself.
	self do: [
		tags do: [ :each | each save ].
		guy save.
		user save ].
	self do: [
		loaded := ExampleUser findId: user id.
		self assert: loaded notNil.
		self assert: loaded tags size equals: 2.
		self assert: loaded person firstName equals: 'jane' ]
]

{ #category : #tests }
MaplessBehaviorMongoTest >> testSaveAndLoad [

	| guy loaded |
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	self do: [ guy save ].
	self assert: guy id notNil.
	self do: [
		loaded := ExamplePerson findId: guy id.
		self assert: loaded notNil.
		self assert: loaded firstName equals: 'john'.
		self assert: loaded lastName equals: 'q' ]
]

{ #category : #tests }
MaplessBehaviorMongoTest >> testUpdate [

	| guy |
	guy := ExamplePerson new
		       firstName: 'john';
		       yourself.
	self do: [
		guy save.
		guy firstName: 'johnny'.
		guy save.
		self assert: ExamplePerson count equals: 1.
		self
			assert: (ExamplePerson findId: guy id) firstName
			equals: 'johnny' ]
]
