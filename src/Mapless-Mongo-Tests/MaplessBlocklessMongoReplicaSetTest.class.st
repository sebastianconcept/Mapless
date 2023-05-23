Class {
	#name : #MaplessBlocklessMongoReplicaSetTest,
	#superclass : #MaplessMongoReplicaSetTest,
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #actions }
MaplessBlocklessMongoReplicaSetTest >> newRepository [
	^ self
		setConcernsIn:
			(MaplessMongoRepository
				for: 'Mapless-Test'
				with: MaplessBlocklessMongoReplicaSetPool test)
]
