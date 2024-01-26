"
I provide a Mapless interface to the library used for accessing Postgres.
I'll be intermediating the Mapless API to create proper commands and answers using the currently best PostgreSQL library available for Pharo.
"
Class {
	#name : #MaplessPostgresClient,
	#superclass : #Object,
	#instVars : [
		'postgresClient'
	],
	#category : #'Mapless-Postgres-Core-Connections'
}

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
	postgresClient connect
]

{ #category : #querying }
MaplessPostgresClient >> count: aMaplessClass where: someConditionsOrNil in: aMaplessPostgresRepository [
	| sql result |
	sql := self sqlForCount: aMaplessClass where: someConditionsOrNil.
	result := postgresClient query: sql.
	^ result firstFieldOfFirstRecord
]

{ #category : #actions }
MaplessPostgresClient >> createDatabaseNamed: aString [
	self postgresClient execute: 'CREATE DATABASE "' , aString , '"'
]

{ #category : #actions }
MaplessPostgresClient >> createTableFor: aMaplessClass [
	self createTableNamed: (self tableNameFor: aMaplessClass)
]

{ #category : #actions }
MaplessPostgresClient >> createTableNamed: aString [
	postgresClient
		execute:
			('CREATE TABLE {1} (id UUID PRIMARY KEY, maplessData jsonb) WITH (OIDS = FALSE)'
				format: {aString})
]

{ #category : #actions }
MaplessPostgresClient >> destroyAll: aMaplessClass where: condition [
	self postgresClient
		execute:
			('DELETE FROM {1} WHERE {2}'
				format:
					{(self tableNameFor: aMaplessClass).
					condition})
]

{ #category : #actions }
MaplessPostgresClient >> disconnect [
	postgresClient ifNotNil: [ postgresClient close ]
]

{ #category : #actions }
MaplessPostgresClient >> dropDatabaseNamed: aString [
	self postgresClient execute: 'DROP DATABASE IF EXISTS "' , aString , '"'
]

{ #category : #querying }
MaplessPostgresClient >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil in: aMaplessPostgresRepository [
	| sql result |
	sql := self
		sqlForFindAll: aMaplessClass
		where: someConditionsOrNil
		limit: aLimitOrNil
		offset: anOffsetOrNil
		sort: sortConditionsOrNil.
	result := postgresClient query: sql.
	^ result data
		collect:
			[ :resultData | self maplessFromResult: resultData in: aMaplessPostgresRepository ]
]

{ #category : #accessing }
MaplessPostgresClient >> getTableNames [
	"Answers the names of the existing tables in the database."

	^ (postgresClient listTablesInSchema: 'public') collect: #first
]

{ #category : #testing }
MaplessPostgresClient >> hasDatabaseNamed: aString [
	^ postgresClient listDatabases includes: aString
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
	postgresClient := P3Client url: anUrlOrUrlString
]

{ #category : #actions }
MaplessPostgresClient >> insert: aBSONFriendlyObject as: aMaplessClass in: aMaplessPostgresRepository [
	^ postgresClient
		execute:
			('INSERT INTO {1} VALUES (''{2}'', ''{3}'')'
				format:
					{(self tableNameFor: aMaplessClass).
					(aBSONFriendlyObject
						at: aMaplessPostgresRepository idPropertyName).
					(aBSONFriendlyObject
						at: aMaplessPostgresRepository maplessDataPropertyName)
						asJSONString})
]

{ #category : #testing }
MaplessPostgresClient >> isValid [
	^ postgresClient isConnected
]

{ #category : #actions }
MaplessPostgresClient >> maplessFromResult: anArray in: aMaplessRepository [
	| id maplessData |
	id := anArray first.
	maplessData := JsonObject
		fromAssociations: anArray second associations.
	maplessData at: aMaplessRepository idPropertyName put: id.
	^ Mapless fromJSONObject: maplessData in: aMaplessRepository
]

{ #category : #accessing }
MaplessPostgresClient >> postgresClient [
	^ postgresClient
]

{ #category : #actions }
MaplessPostgresClient >> reset [
	postgresClient reset
]

{ #category : #accessing }
MaplessPostgresClient >> sqlForCount: aMaplessClass where: someConditionsOrNil [
	^ String
		streamContents: [ :stream | 
			stream
				<<
					('SELECT COUNT(*) FROM {1}'
						format: {(self tableNameFor: aMaplessClass)}).
			someConditionsOrNil
				ifNotNil: [ stream << (' WHERE {1}' format: {someConditionsOrNil}) ] ]
]

{ #category : #accessing }
MaplessPostgresClient >> sqlForFindAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil [ 
	^ String
		streamContents: [ :stream | 
			stream
				<< ('SELECT * FROM {1}' format: {(self tableNameFor: aMaplessClass)}).
			someConditionsOrNil
				ifNotNil: [ stream << (' WHERE {1}' format: {someConditionsOrNil}) ].
			sortConditionsOrNil
				ifNotNil: [ stream << (' ORDER BY {1}' format: {sortConditionsOrNil}) ].
			aLimitOrNil
				ifNotNil: [ stream << (' LIMIT {1}' format: {aLimitOrNil}) ].
			anOffsetOrNil
				ifNotNil: [ stream << (' OFFSET {1}' format: {anOffsetOrNil}) ] ]
]

{ #category : #accessing }
MaplessPostgresClient >> tableNameFor: aMaplessClass [
	^ aMaplessClass collectionName
]

{ #category : #actions }
MaplessPostgresClient >> truncate: aMaplessClass [
	self postgresClient
		execute:
			('TRUNCATE {1}' format: {(self tableNameFor: aMaplessClass)})
]

{ #category : #actions }
MaplessPostgresClient >> update: aBSONFriendlyObject as: aMaplessClass in: aMaplessPostgresRepository [
	^ postgresClient
		execute:
			('UPDATE {1} SET {2} = ''{3}'' WHERE {4} = ''{5}'''
				format:
					{(self tableNameFor: aMaplessClass).
					aMaplessPostgresRepository maplessDataPropertyName.
					(aBSONFriendlyObject
						at: aMaplessPostgresRepository maplessDataPropertyName)
						asJSONString.
					aMaplessPostgresRepository idPropertyName.
					(aBSONFriendlyObject
						at: aMaplessPostgresRepository idPropertyName)})
]
