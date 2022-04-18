Class {
	#name : #MaplessSQLiteClient,
	#superclass : #Object,
	#instVars : [
		'sqliteClient'
	],
	#category : #'Mapless-SQLite-Core'
}

{ #category : #accessing }
MaplessSQLiteClient class >> openOn: aFilenameOrKeyword [
	^ self new initializeOn: aFilenameOrKeyword
]

{ #category : #actions }
MaplessSQLiteClient >> close [
	self disconnect
]

{ #category : #actions }
MaplessSQLiteClient >> connect [
	postgresClient connect
]

{ #category : #querying }
MaplessSQLiteClient >> count: aMaplessClass where: someConditionsOrNil in: aMaplessPostgresRepository [
	| sql result |
	sql := self sqlForCount: aMaplessClass where: someConditionsOrNil.
	result := postgresClient query: sql.
	^ result firstFieldOfFirstRecord
]

{ #category : #actions }
MaplessSQLiteClient >> createDatabaseNamed: aString [
	self postgresClient execute: 'CREATE DATABASE "' , aString , '"'
]

{ #category : #actions }
MaplessSQLiteClient >> createTableFor: aMaplessClass [
	self createTableNamed: (self tableNameFor: aMaplessClass)
]

{ #category : #actions }
MaplessSQLiteClient >> createTableNamed: aString [
	sqliteClient
		execute:
			('CREATE TABLE {1} (id TEXT PRIMARY KEY, maplessData TEXT)'
				format: {aString})
]

{ #category : #actions }
MaplessSQLiteClient >> destroyAll: aMaplessClass where: condition [
	self postgresClient
		execute:
			('DELETE FROM {1} WHERE {2}'
				format:
					{(self tableNameFor: aMaplessClass).
					condition})
]

{ #category : #actions }
MaplessSQLiteClient >> disconnect [
	postgresClient ifNotNil: [ postgresClient close ]
]

{ #category : #actions }
MaplessSQLiteClient >> dropDatabaseNamed: aString [
	self postgresClient execute: 'DROP DATABASE IF EXISTS "' , aString , '"'
]

{ #category : #querying }
MaplessSQLiteClient >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil in: aMaplessPostgresRepository [
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
MaplessSQLiteClient >> getTableNames [
	"Answers the names of the existing tables in the database."

	^ sqliteClient tableNames
]

{ #category : #testing }
MaplessSQLiteClient >> hasDatabaseNamed: aString [
	^ postgresClient listDatabases includes: aString
]

{ #category : #testing }
MaplessSQLiteClient >> hasTableFor: aMaplessClass [
	^ self hasTableNamed: (self tableNameFor: aMaplessClass)
]

{ #category : #testing }
MaplessSQLiteClient >> hasTableNamed: aString [
	^ self getTableNames includes: aString asLowercase
]

{ #category : #initialization }
MaplessSQLiteClient >> initializeOn: aFilenameOrKeyword [
	sqliteClient := SQLite3Connection openOn: aFilenameOrKeyword
]

{ #category : #actions }
MaplessSQLiteClient >> insert: serializableObject as: aMaplessClass in: aMaplessSQLiteRepository [
	^ sqliteClient
		execute:
			('INSERT INTO {1} VALUES (''{2}'', ''{3}'')'
				format:
					{(self tableNameFor: aMaplessClass).
					(serializableObject at: aMaplessSQLiteRepository idPropertyName).
					(serializableObject
						at: aMaplessSQLiteRepository maplessDataPropertyName)
						asJSONString})
]

{ #category : #testing }
MaplessSQLiteClient >> isValid [
	^ sqliteClient isOpen
]

{ #category : #actions }
MaplessSQLiteClient >> maplessFromResult: anArray in: aMaplessRepository [
	| id maplessData |
	id := anArray first.
	maplessData := JsonObject
		fromAssociations: anArray second associations.
	maplessData at: aMaplessRepository idPropertyName put: id.
	^ Mapless fromJSONObject: maplessData in: aMaplessRepository
]

{ #category : #accessing }
MaplessSQLiteClient >> postgresClient [
	^ postgresClient
]

{ #category : #actions }
MaplessSQLiteClient >> reset [
	sqliteClient close
]

{ #category : #accessing }
MaplessSQLiteClient >> sqlForCount: aMaplessClass where: someConditionsOrNil [
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
MaplessSQLiteClient >> sqlForFindAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil [ 
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
MaplessSQLiteClient >> tableNameFor: aMaplessClass [
	^ aMaplessClass collectionName
]

{ #category : #actions }
MaplessSQLiteClient >> truncate: aMaplessClass [
	self postgresClient
		execute:
			('TRUNCATE {1}' format: {(self tableNameFor: aMaplessClass)})
]

{ #category : #actions }
MaplessSQLiteClient >> update: aBSONFriendlyObject as: aMaplessClass in: aMaplessPostgresRepository [
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
