"
I test different scenarios using a MongoDB Replica Set
"
Class {
	#name : #MaplessMongoReplicaSetTest,
	#superclass : #MaplessMongoTest,
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #testing }
MaplessMongoReplicaSetTest class >> shouldInheritSelectors [
	^ true
]

{ #category : #actions }
MaplessMongoReplicaSetTest >> newRepository [
	^ self
		setConcernsIn:
			(MaplessMongoRepository
				for: 'Mapless-Test'
				with: MaplessMongoReplicaSetPool test)
]

{ #category : #actions }
MaplessMongoReplicaSetTest >> resetConcernsIn: aMaplessMongoRepository [
	^ aMaplessMongoRepository
		initializeConcerns;
		initializeDefaultConcerns;
		yourself
]

{ #category : #actions }
MaplessMongoReplicaSetTest >> setConcernsIn: aMaplessMongoRepository [
	"We're adding these concerns because we want to make sure 
	that the information is stored on the primary and replicated to 
	at least one secondary so that if there's a loss of primary the data isn't lost."

	| concern |
	concern := MongoWriteConcern new
		j: true;
		w: 'majority';
		wtimeout: 0;
		yourself.
	^ aMaplessMongoRepository
		insertConcern: concern for: DummyPerson;
		insertConcern: concern for: DummyUser;
		updateConcern: concern for: DummyPerson;
		updateConcern: concern for: DummyUser;
		deleteConcern: concern for: DummyPerson;
		deleteConcern: concern for: DummyUser;
		defaultInsertConcern: concern;
		defaultUpdateConcern: concern;
		defaultUpsertConcern: concern;
		defaultDeleteConcern: concern;
		yourself
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testDefaultConcerns [
	| concern |
	self resetConcernsIn: repository.
	concern := MongoWriteConcern new
		j: true;
		w: 'majority';
		wtimeout: 5000;
		yourself.
	repository
		defaultInsertConcern: concern;
		defaultUpsertConcern: concern;
		defaultUpdateConcern: concern;
		defaultDeleteConcern: concern;
		yourself.
	self assert: repository defaultInsertConcern equals: concern.
	self assert: repository defaultUpsertConcern equals: concern.
	self assert: repository defaultUpdateConcern equals: concern.
	self assert: repository defaultDeleteConcern equals: concern
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testDefaultConcernsOnAMaplessClass [
	| concern1 concern2 |
	self resetConcernsIn: repository.

	concern1 := MongoWriteConcern new
		j: true;
		w: 'majority';
		wtimeout: 5000;
		yourself.
	concern2 := MongoWriteConcern new
		j: true;
		w: 1;
		wtimeout: 10000;
		yourself.
	repository
		defaultInsertConcern: concern2;
		defaultUpsertConcern: concern2;
		defaultUpdateConcern: concern2;
		defaultDeleteConcern: concern2;
		yourself.
	repository insertConcern: concern1 for: DummyPerson.
	repository upsertConcern: concern1 for: DummyPerson.
	repository updateConcern: concern1 for: DummyPerson.
	repository deleteConcern: concern1 for: DummyPerson.
	self
		assert: (repository insertConcernFor: DummyPerson)
		equals: concern1.
	self deny: (repository insertConcernFor: DummyUser) equals: concern1.
	self deny: (repository upsertConcernFor: DummyUser) equals: concern1.
	self deny: (repository updateConcernFor: DummyUser) equals: concern1.
	self deny: (repository deleteConcernFor: DummyUser) equals: concern1.
	self
		assert: (repository insertConcernFor: DummyUser)
		equals: concern2.
	self
		assert: (repository upsertConcernFor: DummyUser)
		equals: concern2.
	self
		assert: (repository updateConcernFor: DummyUser)
		equals: concern2.
	self
		assert: (repository deleteConcernFor: DummyUser)
		equals: concern2.
	self
		deny: (repository insertConcernFor: DummyPerson)
		equals: concern2.
	self
		deny: (repository upsertConcernFor: DummyPerson)
		equals: concern2.
	self
		deny: (repository updateConcernFor: DummyPerson)
		equals: concern2.
	self
		deny: (repository deleteConcernFor: DummyPerson)
		equals: concern2
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testDefaultNilConcerns [
	self resetConcernsIn: repository.
	self assert: repository defaultInsertConcern equals: nil.
	self assert: repository defaultUpsertConcern equals: nil.
	self assert: repository defaultUpdateConcern equals: nil.
	self assert: repository defaultDeleteConcern equals: nil
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testFailToFindPrimaryhenUnavailableForTooLong [
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testFindAllWithReadConcern [
	| found writeConcern |
	writeConcern := MongoWriteConcern new
		j: true;
		w: 'majority';
		yourself.
	repository
		insert: (self newDummyPersonNamed: 'Peter')
		writeConcern: writeConcern.
	repository
		insert: (self newDummyPersonNamed: 'Robert')
		writeConcern: writeConcern.
	repository
		insert: (self newDummyPersonNamed: 'John')
		writeConcern: writeConcern.
	1000 milliseconds wait.
	found := repository
		findAll: DummyPerson
		readConcern: MongoReadConcern majority.
	self assert: found notNil.
	self assert: found size equals: 3
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testFindPrimaryAfterItChanged [
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testFindPrimaryFromScratch [
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testPoolStartsFindingPrimary [
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testReadOnly [
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testReadOnlyFailingBecauseThatSecondaryGoesDown [
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testReadWrite [
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testReadWriteFailingBecausePrimaryGoesDown [
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testSetConcernsOnAMaplessClass [
	| concern |
	self resetConcernsIn: repository.
	self assert: repository defaultInsertConcern equals: nil.
	self assert: repository defaultUpsertConcern equals: nil.
	self assert: repository defaultUpdateConcern equals: nil.
	self assert: repository defaultDeleteConcern equals: nil.
	concern := MongoWriteConcern new
		j: true;
		w: 'majority';
		wtimeout: 5000;
		yourself.
	repository insertConcern: concern for: DummyPerson.
	self
		assert: (repository insertConcernFor: DummyPerson)
		equals: concern.
	self deny: (repository insertConcernFor: DummyUser) equals: concern.
	self assert: (repository insertConcernFor: DummyUser) equals: nil
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testUseConcernsOnAMaplessClass [
	| concern guy found |
	self resetConcernsIn: repository.
	concern := MongoWriteConcern new
		j: true;
		w: 'majority';
		wtimeout: 5000;
		yourself.
	repository insertConcern: concern for: DummyPerson.
	guy := DummyPerson new
		firstName: 'Steven';
		yourself.
	repository save: guy.
	self assert: guy hasId.
	found := repository findOne: DummyPerson atId: guy id readConcern: MongoReadConcern majority.
	self assert: found id equals: guy id
]
