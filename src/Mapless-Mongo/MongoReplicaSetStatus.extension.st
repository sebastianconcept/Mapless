Extension { #name : #MongoReplicaSetStatus }

{ #category : #'*Mapless-Mongo' }
MongoReplicaSetStatus >> secondaryMembers [
	^ self members select: #isSecondary
]
