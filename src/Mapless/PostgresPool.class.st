Class {
	#name : #PostgresPool,
	#superclass : #MaplessAbstractPool,
	#category : #'Mapless-Postgres'
}

{ #category : #actions }
PostgresPool >> close: aPostgressConnection [

	aPostgressConnection isConnected ifTrue: [
		aPostgressConnection flushAll; quit ]
]

{ #category : #accessing }
PostgresPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."
	^ PostgresCurrentClient
]

{ #category : #actions }
PostgresPool >> ifUnavailablePurge: aPostgressConnection [
	"Tests aPostgressConnection and remove it from this pool if invalid."

	aPostgressConnection isConnected ifFalse: [ 
		self remove:  aPostgressConnection ]
]

{ #category : #actions }
PostgresPool >> makeClient [
	"Returns a new client so it can be (re)used in the pool"

	| connection |
	self flag: #reimplementWithNewerClient.
	"connection := PGConnection new."
	self flag: #implementWithoutDependencyOnConfigurationFiles.
	"	connection
		connectionArgs:
			(PGConnectionArgs
				hostname: (ConfigurationFiles at: #Postgres at: #host)
				portno: (ConfigurationFiles at: #Postgres at: #port)
				databaseName: (ConfigurationFiles at: #Postgres at: #database)
				userName: (ConfigurationFiles at: #Postgres at: #username)
				password: (ConfigurationFiles at: #Postgres at: #password));
		startup."
	^ connection
]

{ #category : #reactions }
PostgresPool >> onLogout: aRedisClient [
	
	self remove: aRedisClient
]

{ #category : #actions }
PostgresPool >> purgeUnavailable [
	"Removes any client that might be expired or unreacheable."
	
	self busyClients copy do: [ :e | self ifUnavailablePurge: e ].
	self idleClients copy do: [ :e | self ifUnavailablePurge: e ]
]

{ #category : #actions }
PostgresPool >> remove: aRedisClient [

	self close: aRedisClient.

	super remove: aRedisClient
]
