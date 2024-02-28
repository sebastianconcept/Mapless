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
				suffix: 'Interoperating';
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
MaplessVoyageMongoModelTest >> testReifyWithReferenceFromVoyageMetadata [

	| serializedFromVoyage deserializedFromVoyage |
	serializedFromVoyage := '{"_id": "596f7169a5aa73b9a2110def", "#instanceOf": "SampleUser","#version":345,"username":"Paul","person":{"__id": "d9b4e739421aa92bd8002411","#collection": "SamplePerson","#instanceOf": "SamplePerson"}}'.
	deserializedFromVoyage := Mapless
		                          fromJSONString: serializedFromVoyage
		                          in: repository.
	self
		assert: deserializedFromVoyage class
		equals: SampleUserInteroperating.
	self assert: deserializedFromVoyage username equals: 'Paul'.
	self assert: deserializedFromVoyage person notNil.
	self assert: deserializedFromVoyage person class notNil.
	self
		assert: deserializedFromVoyage person class
		equals: MaplessReference
]

{ #category : #tests }
MaplessVoyageMongoModelTest >> testSaveWithVoyageMetadata [

	| found voyageSampleUserJSON voyageSamplePersonJSON personFromMapless userFromMapless command filter cursor |
	voyageSampleUserJSON := '{"_id": "596f7169a5aa73b9a2110def", "#instanceOf": "SampleUser","#version":345,"username":"Paul","person":{"__id": "d9b4e739421aa92bd8002411","#collection": "SamplePerson","#instanceOf": "SamplePerson"}}'.
	voyageSamplePersonJSON := '{"_id": "d9b4e739421aa92bd8002411", "#instanceOf": "SamplePerson","#version":345,"firstName":"Buddy"}'.
	personFromMapless := SamplePersonInteroperating new
		                     firstName: 'Buddy';
		                     yourself.
	userFromMapless := SampleUserInteroperating new
		                   username: 'buddy';
		                   person: personFromMapless;
		                   yourself.

	repository save: personFromMapless.
	repository save: userFromMapless.
	found := repository
		         findOne: SamplePersonInteroperating
		         atId: personFromMapless id.
	self assert: found notNil.
	self
		assert: (found maplessData at: '#instanceOf')
		equals: 'SamplePerson'.
	self assert: found id equals: personFromMapless id.
	found := repository
		         findOne: SampleUserInteroperating
		         atId: userFromMapless id.
	self assert: found notNil.
	self
		assert: (found maplessData at: '#instanceOf')
		equals: 'SampleUser'.
	self assert: found id equals: userFromMapless id.
	self assert: found person class equals: MaplessReference.
	self
		assert: found person model class
		equals: SamplePersonInteroperating.
	self assert: found person id notNil.
	self assert: found person id equals: personFromMapless id.
	self assert: found person model notNil.
	self assert: found person data notNil.
	filter := Dictionary newFromPairs: {
			          '_id'.
			          userFromMapless id }.
	command := OrderedDictionary new
		           at: 'find' put: SampleUserInteroperating collectionName;
		           at: 'filter' put: filter asMongoQuery;
		           yourself.
	repository readOnlyDo: [
		cursor := repository newCursorFor: command.
		found := cursor collect: [ :each | each ] ].
	self assert: found notNil.
	self assert: found notEmpty.
	self assert: ((found first at: 'person') includesKey: '__id').
	self assert: ((found first at: 'person') includesKey: '#instanceOf').
	self assert: ((found first at: 'person') includesKey: '#collection').
	self
		assert: ((found first at: 'person') at: '__id')
		equals: personFromMapless id.
	self
		assert: ((found first at: 'person') at: '#instanceOf')
		equals: 'SamplePerson'.
	self
		assert: ((found first at: 'person') at: '#collection')
		equals: 'SamplePerson'
]
