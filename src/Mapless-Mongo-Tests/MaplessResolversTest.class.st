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
