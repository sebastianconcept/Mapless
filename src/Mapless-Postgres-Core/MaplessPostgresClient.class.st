"
I provide a Mapless interface to the library used for accessing Postgres.
I'll be intermediating the Mapless API to create proper commands and answers using the currently best PostgreSQL library available for Pharo.
"
Class {
	#name : #MaplessPostgresClient,
	#superclass : #Object,
	#instVars : [
		'p3Client'
	],
	#category : #'Mapless-Postgres-Core-Connections'
}

{ #category : #accessing }
MaplessPostgresClient class >> idPropertyName [
	"Answers 'id' and we're using it as Postgres 
	primary key for the Mapless table of any given Mapless class."

	^ 'id'
]

{ #category : #accessing }
MaplessPostgresClient class >> maplessDataPropertyName [
	"Answers'maplessData' as the column name 
	where we're going to use the Postgres JSON blob."

	^ 'maplessData'
]

{ #category : #accessing }
MaplessPostgresClient class >> url: anUrlOrUrlString [
	^ self new initializeOn: anUrlOrUrlString
]

{ #category : #actions }
MaplessPostgresClient >> close [
	self disconnect
]

{ #category : #actions }
MaplessPostgresClient >> connect [
	p3Client connect
]

{ #category : #actions }
MaplessPostgresClient >> createDatabaseNamed: aString [
	self p3 execute: 'CREATE DATABASE "' , aString , '"'
]

{ #category : #actions }
MaplessPostgresClient >> createTableFor: aMaplessClass [
	self createTableNamed: (self tableNameFor: aMaplessClass)
]

{ #category : #actions }
MaplessPostgresClient >> createTableNamed: aString [
	p3Client
		execute:
			('CREATE TABLE {1} (id UUID PRIMARY KEY, maplessData jsonb) WITH (OIDS = FALSE)'
				format: {aString})
]

{ #category : #actions }
MaplessPostgresClient >> destroyAll: aMaplessClass where: condition [
	self p3
		execute:
			('DELETE FROM {1} WHERE {2}'
				format:
					{(self tableNameFor: aMaplessClass).
					condition})
]

{ #category : #actions }
MaplessPostgresClient >> disconnect [
	p3Client ifNotNil: [ p3Client close ]
]

{ #category : #actions }
MaplessPostgresClient >> dropDatabaseNamed: aString [
	self p3 execute: 'DROP DATABASE IF EXISTS "' , aString , '"'
]

{ #category : #accessing }
MaplessPostgresClient >> getTableNames [
	"Answers the names of the existing tables in the database."

	^ p3Client listTablesInSchema: 'public'
]

{ #category : #testing }
MaplessPostgresClient >> hasDatabaseNamed: aString [
	^ p3Client listDatabases includes: aString
]

{ #category : #testing }
MaplessPostgresClient >> hasTableFor: aMaplessClass [
	^ self hasTableNamed: (self tableNameFor: aMaplessClass)
]

{ #category : #testing }
MaplessPostgresClient >> hasTableNamed: aString [
	^ self getTableNames includes: aString asLowercase
]

{ #category : #initialization }
MaplessPostgresClient >> initializeOn: anUrlOrUrlString [
	p3Client := P3Client url: anUrlOrUrlString
]

{ #category : #actions }
MaplessPostgresClient >> insert: aBSONFriendlyObject as: aMaplessClass [
	^ p3Client
		execute:
			('INSERT INTO {1} VALUES (''{2}'', ''{3}'')'
				format:
					{(self tableNameFor: aMaplessClass).
					(aBSONFriendlyObject at: self class idPropertyName).
					(aBSONFriendlyObject at: self class maplessDataPropertyName)
						asJSONString})
]

{ #category : #testing }
MaplessPostgresClient >> isValid [
	^ p3Client isConnected
]

{ #category : #accessing }
MaplessPostgresClient >> p3 [
	^ p3Client
]

{ #category : #actions }
MaplessPostgresClient >> reset [
	p3Client reset
]

{ #category : #accessing }
MaplessPostgresClient >> tableNameFor: aMaplessClass [
	^ aMaplessClass collectionName
]

{ #category : #actions }
MaplessPostgresClient >> truncate: aMaplessClass [
	self p3
		execute:
			('TRUNCATE {1}' format: {(self tableNameFor: aMaplessClass)})
]
