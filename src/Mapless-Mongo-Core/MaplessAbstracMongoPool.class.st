Class {
	#name : #MaplessAbstracMongoPool,
	#superclass : #MaplessAbstractPool,
	#instVars : [
		'authenticationDatabaseName'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #'instance creation' }
MaplessAbstracMongoPool class >> local [
	^ self
		hostname: 'localhost'
		port: 27017
		username: nil
		password: nil
]

{ #category : #accessing }
MaplessAbstracMongoPool >> authenticationDatabaseName [
	^ authenticationDatabaseName
		ifNil: [ self initializeAuthenticationDatabaseName ]
]

{ #category : #accessing }
MaplessAbstracMongoPool >> authenticationDatabaseName: aString [
	authenticationDatabaseName := aString
]

{ #category : #initialization }
MaplessAbstracMongoPool >> initializeAuthenticationDatabaseName [
	^ authenticationDatabaseName := 'admin'
]

{ #category : #actions }
MaplessAbstracMongoPool >> returningUnusedClient [
	Transcript
		cr;
		show: 'Warning: returning a client that is not in among the busy ones'
]
