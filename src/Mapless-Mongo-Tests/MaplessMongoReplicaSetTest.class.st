"
I test different scenarios using a MongoDB Replica Set
"
Class {
	#name : #MaplessMongoReplicaSetTest,
	#superclass : #MaplessTestCase,
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #actions }
MaplessMongoReplicaSetTest >> newRepository [
	^ MaplessMongoRepository
		for: 'Mapless-Test'
		with: MaplessMongoReplicaSetPool test
]

{ #category : #tests }
MaplessMongoReplicaSetTest >> testFailToFindPrimaryhenUnavailableForTooLong [
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
