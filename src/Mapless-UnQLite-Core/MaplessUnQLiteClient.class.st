"
I'm the facade of the concrete library that will give us access to UnQLite
"
Class {
	#name : #MaplessUnQLiteClient,
	#superclass : #Object,
	#instVars : [
		'unqliteClient'
	],
	#category : #'Mapless-UnQLite-Core-Connections'
}

{ #category : #accessing }
MaplessUnQLiteClient class >> on: aDatabaseFileName [
	^ self new
		initializeOn: aDatabaseFileName;
		yourself
]

{ #category : #actions }
MaplessUnQLiteClient >> close [
	unqliteClient ifNotNil: [ unqliteClient close ]
]

{ #category : #querying }
MaplessUnQLiteClient >> count: aMaplessClass where: someConditionsOrNil in: aMaplessPostgresRepository [
	| sql result |
	sql := self sqlForCount: aMaplessClass where: someConditionsOrNil.
	result := unqliteClient query: sql.
	^ result firstFieldOfFirstRecord
]

{ #category : #actions }
MaplessUnQLiteClient >> destroy: aMapless [
	unqliteClient deleteAt: (self namespacedIdOf: aMapless)
]

{ #category : #actions }
MaplessUnQLiteClient >> destroyAll: aMaplessClass where: condition [

	self flag: #review.
	"can be implemented in bulk?"
	self halt
]

{ #category : #actions }
MaplessUnQLiteClient >> disconnect [
	self close
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

{ #category : #testing }
MaplessUnQLiteClient >> hasDatabaseNamed: aDatabaseFileName [
	^ aDatabaseFileName asFileReference exists
]

{ #category : #initialization }
MaplessUnQLiteClient >> initializeOn: aDatabaseFileName [
	unqliteClient := PqDatabase open: aDatabaseFileName
]

{ #category : #actions }
MaplessUnQLiteClient >> insert: aBSONFriendlyObject as: aMaplessClass in: aMaplessPostgresRepository [
	| key postgresClient serialized |
	key := self namespacedIdOf: aBSONFriendlyObject.
	serialized := BSON write: aBSONFriendlyObject.
	^ unqliteClient at: key put: serialized
]

{ #category : #testing }
MaplessUnQLiteClient >> isValid [
	^ unqliteClient isOpen
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
MaplessUnQLiteClient >> namespaced: propertyName of: aStorable [
	^ '{1}:{2}:{3}'
		format:
			{(aStorable at: '_c').
			propertyName.
			(aStorable at: propertyName)}
]

{ #category : #accessing }
MaplessUnQLiteClient >> namespacedIdOf: aStorable [
	^ self namespaced: 'id' of: aStorable
]

{ #category : #actions }
MaplessUnQLiteClient >> reset [
	unqliteClient close
]

{ #category : #actions }
MaplessUnQLiteClient >> truncate: aMaplessClass [
	self postgresClient
		execute:
			('TRUNCATE {1}' format: {(self tableNameFor: aMaplessClass)})
]

{ #category : #accessing }
MaplessUnQLiteClient >> unqliteClient [
	^ unqliteClient
]

{ #category : #actions }
MaplessUnQLiteClient >> update: aBSONFriendlyObject as: aMaplessClass in: aMaplessPostgresRepository [
	^ unqliteClient
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
