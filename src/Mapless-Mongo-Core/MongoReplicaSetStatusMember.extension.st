Extension { #name : #MongoReplicaSetStatusMember }

{ #category : #'*Mapless-Mongo-Core' }
MongoReplicaSetStatusMember >> isArbiter [
	"Arbiters do not replicate data and exist solely to participate in elections.
	Eligible to vote.
	https://www.mongodb.com/docs/manual/reference/replica-states"
	^self state = 7
]

{ #category : #'*Mapless-Mongo-Core' }
MongoReplicaSetStatusMember >> isDown [
	^self state = 8
]

{ #category : #'*Mapless-Mongo-Core' }
MongoReplicaSetStatusMember >> isRecovering [
	"Members either perform startup self-checks, 
	or transition from completing a rollback or resync. 
	Data is not available for reads from this member. 
	Eligible to vote.
	https://www.mongodb.com/docs/manual/reference/replica-states"
	^self state = 3
]

{ #category : #'*Mapless-Mongo-Core' }
MongoReplicaSetStatusMember >> isRemoved [
	"This member was once in a replica set but was subsequently removed.
	https://www.mongodb.com/docs/manual/reference/replica-states"
	^self state = 10
]

{ #category : #'*Mapless-Mongo-Core' }
MongoReplicaSetStatusMember >> isRollback [
	"This member is actively performing a rollback. 
	Eligible to vote. Data is not available for reads from this member.
	Starting in version 4.2, MongoDB kills all in-progress user operations 
	when a member enters the ROLLBACK state.
	https://www.mongodb.com/docs/manual/reference/replica-states"
	^self state = 9
]

{ #category : #'*Mapless-Mongo-Core' }
MongoReplicaSetStatusMember >> isStartup [
	"Not yet an active member of any set. 
	All members start up in this state. 
	The mongod parses the replica set configuration 
	document while in STARTUP.
	https://www.mongodb.com/docs/manual/reference/replica-states"
	^self state = 0
]

{ #category : #'*Mapless-Mongo-Core' }
MongoReplicaSetStatusMember >> isStartup2 [
	"The member has joined the set and is running an initial sync. 
	Eligible to vote.
	NOTE
	Starting in MongoDB 5.0, if the member was newly added to the replica set, 
	it is not eligible to vote and cannot be elected during the initial sync process.
	https://www.mongodb.com/docs/manual/reference/replica-states"
	^self state = 5
]

{ #category : #'*Mapless-Mongo-Core' }
MongoReplicaSetStatusMember >> isUnkown [
	"The member's state, as seen from another member of the set, is not yet known.
	https://www.mongodb.com/docs/manual/reference/replica-states"
	^self state = 5
]
