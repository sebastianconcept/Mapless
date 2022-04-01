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
MaplessUnQLiteClient >> findOne: aMaplessClass atId: anId in: aMaplessPostgresRepository [
	| result key |

	key := self namespaced: 'id' of: aMaplessClass valued: anId.
	result := unqliteClient at: key.
	^ self maplessFromResult: (BSON read: result readStream) in: aMaplessPostgresRepository 
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
MaplessUnQLiteClient >> maplessFromResult: aDictionarish in: aMaplessPostgresRepository [
	^ Mapless
		fromJSONObject: (JsonObject fromAssociations: aDictionarish associations)
		in: aMaplessPostgresRepository
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
MaplessUnQLiteClient >> namespaced: propertyName of: aMaplessClass valued: aValue [
	^ '{1}:{2}:{3}'
		format:
			{aMaplessClass name.
			propertyName.
			aValue}
]

{ #category : #accessing }
MaplessUnQLiteClient >> namespacedIdOf: aStorable [
	^ self namespaced: 'id' of: aStorable
]

{ #category : #accessing }
MaplessUnQLiteClient >> namespacedIdOf: aMaplessClass valued: aValue [
	^ self namespaced: 'id' of: aMaplessClass valued: aValue
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
