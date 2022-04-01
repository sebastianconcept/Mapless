Class {
	#name : #MaplessUnQLiteClient,
	#superclass : #Object,
	#instVars : [
		'unqliteClient'
	],
	#category : #'Mapless-UnQLite-Core-Connections'
}

{ #category : #accessing }
MaplessUnQLiteClient class >> local [
	^ self new
]

{ #category : #actions }
MaplessUnQLiteClient >> close [
	self disconnect
]

{ #category : #actions }
MaplessUnQLiteClient >> connect [
	postgresClient connect
]

{ #category : #querying }
MaplessUnQLiteClient >> count: aMaplessClass where: someConditionsOrNil in: aMaplessPostgresRepository [
	| sql result |
	sql := self sqlForCount: aMaplessClass where: someConditionsOrNil.
	result := postgresClient query: sql.
	^ result firstFieldOfFirstRecord
]

{ #category : #actions }
MaplessUnQLiteClient >> createDatabaseNamed: aString [
	self postgresClient execute: 'CREATE DATABASE "' , aString , '"'
]

{ #category : #actions }
MaplessUnQLiteClient >> createTableFor: aMaplessClass [
	self createTableNamed: (self tableNameFor: aMaplessClass)
]

{ #category : #actions }
MaplessUnQLiteClient >> createTableNamed: aString [
	postgresClient
		execute:
			('CREATE TABLE {1} (id UUID PRIMARY KEY, maplessData jsonb) WITH (OIDS = FALSE)'
				format: {aString})
]

{ #category : #actions }
MaplessUnQLiteClient >> destroyAll: aMaplessClass where: condition [
	self postgresClient
		execute:
			('DELETE FROM {1} WHERE {2}'
				format:
					{(self tableNameFor: aMaplessClass).
					condition})
]

{ #category : #actions }
MaplessUnQLiteClient >> disconnect [
	postgresClient ifNotNil: [ postgresClient close ]
]

{ #category : #actions }
MaplessUnQLiteClient >> dropDatabaseNamed: aString [
	self postgresClient execute: 'DROP DATABASE IF EXISTS "' , aString , '"'
]

{ #category : #querying }
MaplessUnQLiteClient >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil in: aMaplessPostgresRepository [
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
MaplessUnQLiteClient >> getTableNames [
	"Answers the names of the existing tables in the database."

	^ postgresClient listTablesInSchema: 'public'
]

{ #category : #testing }
MaplessUnQLiteClient >> hasDatabaseNamed: aString [
	^ postgresClient listDatabases includes: aString
]

{ #category : #testing }
MaplessUnQLiteClient >> hasTableFor: aMaplessClass [
	^ self hasTableNamed: (self tableNameFor: aMaplessClass)
]

{ #category : #testing }
MaplessUnQLiteClient >> hasTableNamed: aString [
	^ self getTableNames includes: aString asLowercase
]

{ #category : #initialization }
MaplessUnQLiteClient >> initializeOn: anUrlOrUrlString [
	postgresClient := P3Client url: anUrlOrUrlString
]

{ #category : #actions }
MaplessUnQLiteClient >> insert: aBSONFriendlyObject as: aMaplessClass in: aMaplessPostgresRepository [
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
MaplessUnQLiteClient >> isValid [
	^ postgresClient isConnected
]

{ #category : #actions }
MaplessUnQLiteClient >> maplessFromResult: anArray in: aMaplessPostgresRepository [
	| id maplessData |
	id := anArray first.
	maplessData := JsonObject
		fromAssociations: anArray second associations.
	maplessData at: aMaplessPostgresRepository idPropertyName put: id.
	^ Mapless fromJSONObject: maplessData in: aMaplessPostgresRepository
]

{ #category : #accessing }
MaplessUnQLiteClient >> postgresClient [
	^ postgresClient
]

{ #category : #actions }
MaplessUnQLiteClient >> reset [
	postgresClient reset
]

{ #category : #accessing }
MaplessUnQLiteClient >> sqlForCount: aMaplessClass where: someConditionsOrNil [
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
MaplessUnQLiteClient >> sqlForFindAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil [ 
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
MaplessUnQLiteClient >> tableNameFor: aMaplessClass [
	^ aMaplessClass collectionName
]

{ #category : #actions }
MaplessUnQLiteClient >> truncate: aMaplessClass [
	self postgresClient
		execute:
			('TRUNCATE {1}' format: {(self tableNameFor: aMaplessClass)})
]

{ #category : #actions }
MaplessUnQLiteClient >> update: aBSONFriendlyObject as: aMaplessClass in: aMaplessPostgresRepository [
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
