Extension { #name : #MongoReplicaSetStatus }

{ #category : #'*Mapless-Mongo-Core' }
MongoReplicaSetStatus >> secondaryMembers [
	^ self members select: #isSecondary
]
