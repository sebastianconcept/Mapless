Class {
	#name : #MaplessStandalonePostgresPool,
	#superclass : #MaplessAbstractPool,
	#instVars : [
		'databaseName'
	],
	#category : #'Mapless-Postgres-Core-Connections'
}

{ #category : #'instance creation' }
MaplessStandalonePostgresPool class >> local [
	^ self
		hostname: 'localhost'
		port: 5432
		username: 'username'
		password: 'password'
]

{ #category : #actions }
MaplessStandalonePostgresPool >> close: aPostgressConnection [
	aPostgressConnection isConnected
		ifTrue: [ aPostgressConnection
				flushAll;
				quit ]
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ PostgresCurrentClient
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> databaseName [
	^ databaseName
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> databaseName: anObject [
	databaseName := anObject
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> getConnectionUrl [
	^ ZnUrl new
		scheme: 'psql';
		host: hostname;
		port: port;
		username: username;
		password: password;
		/ databaseName
]

{ #category : #actions }
MaplessStandalonePostgresPool >> ifUnavailablePurge: aPostgressConnection [
	"Tests aPostgressConnection and remove it from this pool if invalid."

	aPostgressConnection isConnected
		ifFalse: [ self remove: aPostgressConnection ]
]

{ #category : #actions }
MaplessStandalonePostgresPool >> makeClient [
	"Returns a new client so it can be (re)used in the pool"

	| postgresClient |
self halt.
	postgresClient := P3Client url: self getConnectionUrl.
	"	connection
		connectionArgs:
			(PGConnectionArgs
				hostname: (ConfigurationFiles at: #Postgres at: #host)
				portno: (ConfigurationFiles at: #Postgres at: #port)
				databaseName: (ConfigurationFiles at: #Postgres at: #database)
				userName: (ConfigurationFiles at: #Postgres at: #username)
				password: (ConfigurationFiles at: #Postgres at: #password));
		startup."
]

{ #category : #reactions }
MaplessStandalonePostgresPool >> onLogout: aRedisClient [
	self remove: aRedisClient
]

{ #category : #actions }
MaplessStandalonePostgresPool >> purgeUnavailable [
	"Removes any client that might be expired or unreacheable."

	self busyClients copy do: [ :e | self ifUnavailablePurge: e ].
	self idleClients copy do: [ :e | self ifUnavailablePurge: e ]
]

{ #category : #actions }
MaplessStandalonePostgresPool >> remove: aRedisClient [
	self close: aRedisClient.
	super remove: aRedisClient
]
