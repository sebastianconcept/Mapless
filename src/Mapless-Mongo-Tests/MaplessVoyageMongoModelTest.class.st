Class {
	#name : #MaplessVoyageMongoModelTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #accessing }
MaplessVoyageMongoModelTest >> currentRepository [
	^ MaplessCurrentRepository value
]

{ #category : #'setUp-tearDown' }
MaplessVoyageMongoModelTest >> setUp [
	super setUp.
	repository := MaplessMongoRepository
		for: 'Mapless-Test'
		with: MaplessStandaloneMongoPool local.
	repository
		resolver:
			(MaplessVoyageWithMaplessSuffixResolver new
				suffix: 'Imported';
				yourself)
]

{ #category : #'setUp-tearDown' }
MaplessVoyageMongoModelTest >> tearDown [
	super tearDown.
	repository
		drop;
		shutDown
]

{ #category : #tests }
MaplessVoyageMongoModelTest >> testReifyWitVoyageMetadata [
	| serializedFromVoyage |
	serializedFromVoyage := '{"__id": "abc123", "#instanceOf": "DummyPerson","#collection": "DummyPerson"}'.
	self
		assert:
			(DummyPerson fromJSONString: serializedFromVoyage in: repository)
				class
		equals: DummyPersonImported
]
