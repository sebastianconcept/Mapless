"
I'm the Mapless API that access SQLite functions
"
Class {
	#name : #MaplessSQLiteClient,
	#superclass : #Object,
	#instVars : [
		'sqliteClient'
	],
	#category : #'Mapless-SQLite'
}

{ #category : #accessing }
MaplessSQLiteClient class >> openOn: aFilenameOrKeyword [
	^ self new initializeOn: aFilenameOrKeyword
]

{ #category : #actions }
MaplessSQLiteClient >> close [

	sqliteClient ifNotNil: [ sqliteClient close ]
]

{ #category : #querying }
MaplessSQLiteClient >> count: aMaplessClass where: someConditionsOrNil in: aMaplessPostgresRepository [

	| sql result |
	sql := self sqlForCount: aMaplessClass where: someConditionsOrNil.
	result := sqliteClient execute: sql.
	^ result onlyRow first
]

{ #category : #actions }
MaplessSQLiteClient >> createDatabaseNamed: aString [

	sqliteClient execute: ('CREATE DATABASE "{1}"' format: { aString })
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

	sqliteClient execute: ('DELETE FROM {1} WHERE {2}' format: { 
				 (self tableNameFor: aMaplessClass).
				 condition })
]

{ #category : #actions }
MaplessSQLiteClient >> dropDatabaseNamed: aString [

	"There is no DROP database in SQLite.
	If you want to detroy a database, you just delete its file."

	self shouldNotImplement
]

{ #category : #querying }
MaplessSQLiteClient >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil in: aMaplessPostgresRepository [

	| sql result all |
	sql := self
		       sqlForFindAll: aMaplessClass
		       where: someConditionsOrNil
		       limit: aLimitOrNil
		       offset: anOffsetOrNil
		       sort: sortConditionsOrNil.
	result := sqliteClient execute: sql.
	all := OrderedCollection new.
	result do: [ :sqliteRow | 
		all add:
			(self maplessFromResult: sqliteRow in: aMaplessPostgresRepository) ].
	^ all
]

{ #category : #accessing }
MaplessSQLiteClient >> getTableNames [
	"Answers the names of the existing tables in the database."

	^ sqliteClient tableNames
]

{ #category : #testing }
MaplessSQLiteClient >> hasTableFor: aMaplessClass [
	^ self hasTableNamed: (self tableNameFor: aMaplessClass)
]

{ #category : #testing }
MaplessSQLiteClient >> hasTableNamed: aString [

	^ sqliteClient tableNames includes: aString
]

{ #category : #initialization }
MaplessSQLiteClient >> initializeOn: aFilenameOrKeyword [
	sqliteClient := SQLite3Connection openOn: aFilenameOrKeyword
]

{ #category : #actions }
MaplessSQLiteClient >> insert: serializableObject as: aMaplessClass in: aMaplessSQLiteRepository [

	^ sqliteClient execute:
		  ('INSERT INTO {1} VALUES (''{2}'', {3})' format: { 
				   (self tableNameFor: aMaplessClass).
				   (serializableObject at: aMaplessSQLiteRepository idPropertyName).
				   (serializableObject at:
					    aMaplessSQLiteRepository maplessDataPropertyName)
					   asJSONString printString })
]

{ #category : #testing }
MaplessSQLiteClient >> isValid [
	^ sqliteClient isOpen
]

{ #category : #actions }
MaplessSQLiteClient >> maplessFromResult: sqliteRow in: aMaplessRepository [

	| id maplessData |
	id := sqliteRow first.
	maplessData := Json readFrom: sqliteRow values second readStream.
	maplessData at: aMaplessRepository idPropertyName put: id.
	^ Mapless fromJSONObject: maplessData in: aMaplessRepository
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
MaplessSQLiteClient >> sqliteClient [
	^ sqliteClient
]

{ #category : #accessing }
MaplessSQLiteClient >> tableNameFor: aMaplessClass [
	^ aMaplessClass collectionName
]

{ #category : #actions }
MaplessSQLiteClient >> truncateAll [

	self getTableNames do: [ :tableName | 
		self truncateTableNamed: tableName ]
]

{ #category : #actions }
MaplessSQLiteClient >> truncateMapless: aMaplessClass [

	"Deletes all in the table corresponding to the given mapless class."

	^ self truncateTableNamed: (self tableNameFor: aMaplessClass)
]

{ #category : #actions }
MaplessSQLiteClient >> truncateTableNamed: aTableNameString [

	"Deletes all rows in the corresponding table (table won't be destroyed)."

	sqliteClient execute:
		('DELETE from {1}' format: { aTableNameString })
]

{ #category : #actions }
MaplessSQLiteClient >> update: aBSONFriendlyObject as: aMaplessClass in: aMaplessPostgresRepository [

	^ sqliteClient execute:
		  ('UPDATE {1} SET {2} = {3} WHERE {4} = ''{5}''' format: { 
				   (self tableNameFor: aMaplessClass).
				   aMaplessPostgresRepository maplessDataPropertyName.
				   (aBSONFriendlyObject at:
					    aMaplessPostgresRepository maplessDataPropertyName)
					   asJSONString printString.
				   aMaplessPostgresRepository idPropertyName.
				   (aBSONFriendlyObject at:
					    aMaplessPostgresRepository idPropertyName) })
]
