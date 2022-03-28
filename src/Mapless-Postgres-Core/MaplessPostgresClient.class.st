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

{ #category : #querying }
MaplessPostgresClient >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil in: aMaplessPostgresRepository [
	| sql result |
	sql := self
		sqlForFindAll: aMaplessClass
		where: someConditionsOrNil
		limit: aLimitOrNil
		offset: anOffsetOrNil
		sort: sortConditionsOrNil
		in: aMaplessPostgresRepository.
	result := p3Client query: sql.
	^ result data
		collect:
			[ :resultData | self maplessFromResult: resultData in: aMaplessPostgresRepository ]
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
MaplessPostgresClient >> insert: aBSONFriendlyObject as: aMaplessClass in: aMaplessPostgresRepository [
	^ p3Client
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
	^ p3Client isConnected
]

{ #category : #actions }
MaplessPostgresClient >> maplessFromResult: anArray [
	| id maplessData maplessClass |
	id := anArray first.
	maplessData := JsonObject
		fromAssociations: anArray second associations.
	maplessClass := Smalltalk
		at: maplessData _c asSymbol
		ifAbsent: [ MaplessClassNotFound
				signal:
					('The {1} class was not found in this image'
						format: {maplessData _c asString}) ].
					
	self halt.
	^ maplessClass 
]

{ #category : #actions }
MaplessPostgresClient >> maplessFromResult: anArray in: aMaplessPostgresRepository [
	| id maplessData |
	id := anArray first.
	maplessData := JsonObject
		fromAssociations: anArray second associations.
	maplessData at: aMaplessPostgresRepository idPropertyName put: id.
	^ Mapless fromJSONObject: maplessData in: aMaplessPostgresRepository
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
MaplessPostgresClient >> sqlForFindAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil in: aMaplessPostgresRepository [
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
	self p3
		execute:
			('TRUNCATE {1}' format: {(self tableNameFor: aMaplessClass)})
]
