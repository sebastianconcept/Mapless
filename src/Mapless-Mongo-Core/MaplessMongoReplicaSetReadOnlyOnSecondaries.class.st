"
I pick MongoDB clients that are meant to be used read-only from any of the secondaries and read-write from the pool of connections to the primary.
"
Class {
	#name : #MaplessMongoReplicaSetReadOnlyOnSecondaries,
	#superclass : #MaplessMongoReplicaSetClientSelectionPolicy,
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #actions }
MaplessMongoReplicaSetReadOnlyOnSecondaries >> makeClientFor: aMaplessMongoReplicaSetPool [
	aMaplessMongoReplicaSetPool hasMaxClients
		ifTrue: [ MaplessMaximumPoolClientsReached signal ].
	^ self
		makeClientWith: self nextMongoUrl
		on: aMaplessMongoReplicaSetPool
]

{ #category : #actions }
MaplessMongoReplicaSetReadOnlyOnSecondaries >> makeClientWith: aMongoUrl on: aMaplessMongoReplicaSetPool [
	| newClient isAuthenticated |
	newClient := (MongoAPI mongoUrl: aMongoUrl)
		open;
		yourself.
	aMaplessMongoReplicaSetPool isUsingAuth
		ifTrue: [ isAuthenticated := aMaplessMongoReplicaSetPool authenticate: newClient.
			isAuthenticated
				ifFalse: [ ^ self error: 'Authentication failed' ] ].
	aMaplessMongoReplicaSetPool logNewClient: newClient.
	^ newClient
]

{ #category : #accessing }
MaplessMongoReplicaSetReadOnlyOnSecondaries >> makeOneClientToEveryMemberFor: aMaplessMongoReplicaSetPool [
	self mongoUrls copy
		do: [ :aMongoUrl | 
			| newClient |
			aMaplessMongoReplicaSetPool hasMaxClients
				ifTrue: [ MaplessMaximumPoolClientsReached signal ].
			[ newClient := self
				makeClientWith: aMongoUrl
				on: aMaplessMongoReplicaSetPool ]
				on: ConnectionTimedOut
				do: [ :x | 
					self mongoUrls remove: aMongoUrl.
					nil ].
			newClient
				ifNotNil: [ aMaplessMongoReplicaSetPool idleClients add: newClient ] ]
]

{ #category : #accessing }
MaplessMongoReplicaSetReadOnlyOnSecondaries >> requestClientFrom: aMaplessMongoReplicaSetPool for: aSymbol [
	"Answers a aClient instance taken from the idle clients.
	It'll create a new one if needed.
	It's a thread safe operation."

	^ aMaplessMongoReplicaSetPool clientsMonitor
		critical: [ | client |
			aMaplessMongoReplicaSetPool hasIdleClients
				ifFalse: [ self makeOneClientToEveryMemberFor: aMaplessMongoReplicaSetPool ].
			client := aMaplessMongoReplicaSetPool idleClients
				detect: [ :e | e isType: aSymbol ]
				ifNone: [ aSymbol = #readWrite
						ifTrue: [ 
							aMaplessMongoReplicaSetPool allClients do: #resetIsPrimary.
							MaplessUnavailableMaster signal ]
						ifFalse: [ nil ] ].
			(client isNil or: [ client isValid not ])
				ifTrue: [ client ifNotNil: [ aMaplessMongoReplicaSetPool remove: client ].
					client := self makeClientFor: aMaplessMongoReplicaSetPool ].
			(client isType: aSymbol)
				ifFalse: [ self requestClientFrom: aMaplessMongoReplicaSetPool for: aSymbol ]
				ifTrue: [ aMaplessMongoReplicaSetPool idleClients
						remove: client
						ifAbsent: [ nil ].
					client
						ifNotNil: [ aMaplessMongoReplicaSetPool busyClients add: client ].
					client ] ]
]

{ #category : #accessing }
MaplessMongoReplicaSetReadOnlyOnSecondaries >> requestReadOnlyClientFrom: aMaplessMongoReplicaSetPool [
	^ self requestClientFrom: aMaplessMongoReplicaSetPool for: #readOnly
]

{ #category : #accessing }
MaplessMongoReplicaSetReadOnlyOnSecondaries >> requestReadWriteClientFrom: aMaplessMongoReplicaSetPool [
	^ self requestClientFrom: aMaplessMongoReplicaSetPool for: #readWrite
]
