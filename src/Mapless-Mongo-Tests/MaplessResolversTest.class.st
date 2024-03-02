Class {
	#name : #MaplessResolversTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #running }
MaplessResolversTest >> setUp [

	super setUp.
	repository := MaplessMongoRepository
		              for: 'Mapless-Test'
		              with: MaplessStandaloneMongoPool local
]

{ #category : #running }
MaplessResolversTest >> tearDown [
	super tearDown.
	repository
		drop;
		shutDown
]

{ #category : #tests }
MaplessResolversTest >> testCanRepresentArrayOfMaplessReferences [

	self assert: (repository resolver
			 canRepresentArrayOfMaplessReferences: {
					 {
						 ('_c' -> 'SampleUser').
						 ('_id' -> '12') } asDictionary.
					 {
						 ('_c' -> 'SamplePerson').
						 ('_id' -> '123') } asDictionary }
			 in: repository)
]

{ #category : #tests }
MaplessResolversTest >> testCanRepresentSubMapless [

	self assert: (repository resolver
			 canRepresentSubMapless: {
					 ('_c' -> 'SamplePerson').
					 ('_id' -> '123') } asDictionary
			 in: repository)
]

{ #category : #tests }
MaplessResolversTest >> testConditionForClass [

	self
		assert: (repository resolver conditionForClass: SamplePerson)
		equals: { ('_c' -> 'SamplePerson') } asDictionary
]

{ #category : #tests }
MaplessResolversTest >> testMaplessAsStorable [

	| saved |
	saved := SamplePerson new.
	repository save: saved.

	self
		assert:
			(repository resolver maplessAsStorable: saved in: repository)
				asDictionary
		equals: {
				('_c' -> 'SamplePerson').
				('_id' -> saved id) } asDictionary
]

{ #category : #tests }
MaplessResolversTest >> testMaplessClass [

	self
		assert: (repository resolver
				 maplessClassFor: { ('_c' -> 'SamplePerson') } asDictionary
				 in: repository)
		equals: SamplePerson
]

{ #category : #tests }
MaplessResolversTest >> testMaplessClassNameFor [

	self
		assert: (repository resolver
				 maplessClassNameFor: {
						 ('_c' -> 'SamplePerson').
						 ('_id' -> '123') } asDictionary
				 in: repository)
		equals: 'SamplePerson'
]

{ #category : #tests }
MaplessResolversTest >> testMaplessCustomCollectionNameResolver [

	| customResolver dictionarish |
	customResolver := MaplessCustomCollectionNameResolver new.
	customResolver translations
		at: #Task put: SampleTask name;
		yourself.
	repository resolver: customResolver.

	dictionarish := Dictionary new
		                at: '_c' put: 'Item';
		                yourself.

	self
		should: [
		customResolver maplessClassFor: dictionarish in: repository ]
		raise: MaplessClassNotFound.

	dictionarish := Dictionary new
		                at: '_c' put: 'Task';
		                yourself.
	self
		assert:
		(customResolver maplessClassFor: dictionarish in: repository)
		equals: SampleTask.

	customResolver translations: (Dictionary new
			 at: #LaborUnit put: SampleTask name;
			 yourself).

	repository resolver: customResolver.

	dictionarish := Dictionary new
		                at: '_c' put: 'Task';
		                yourself.

	self
		should: [
		customResolver maplessClassFor: dictionarish in: repository ]
		raise: MaplessClassNotFound.
		
	dictionarish := Dictionary new
		                at: '_c' put: 'LaborUnit';
		                yourself.

	self
		shouldnt: [
		customResolver maplessClassFor: dictionarish in: repository ]
		raise: MaplessClassNotFound.		
			
]
