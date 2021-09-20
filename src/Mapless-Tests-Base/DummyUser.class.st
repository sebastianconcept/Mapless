Class {
	#name : #DummyUser,
	#superclass : #Mapless,
	#category : #'Mapless-Tests-Base-Samples'
}

{ #category : #'as yet unclassified' }
DummyUser class >> findUsername: anUsername [
	^ self currentRepository
		findOne: self
		where:
			(JsonObject
				newFromPairs:
					{'username'.
					anUsername})
]

{ #category : #accessing }
DummyUser >> completeName [
	^ self person firstName , ' ' , self person lastName
]

{ #category : #hooks }
DummyUser >> onAfterDelete [
	super onAfterDelete.
	self afterDelete: true
]

{ #category : #hooks }
DummyUser >> onAfterDestroy [
	super onAfterDestroy.
	self afterDestroy: true
]

{ #category : #hooks }
DummyUser >> onAfterInsert [
	super onAfterInsert.
	self afterInsert: true
]

{ #category : #hooks }
DummyUser >> onAfterSave [
	super onAfterSave.
	self afterSave: true
]

{ #category : #hooks }
DummyUser >> onAfterUpdate [
	super onAfterUpdate.
	self afterUpdate: true
]

{ #category : #hooks }
DummyUser >> onAfterUpsert [
	super onAfterUpsert.
	self afterUpsert: true
]

{ #category : #hooks }
DummyUser >> onBeforeDelete [
	super onBeforeDelete.
	self beforeDelete: true
]

{ #category : #hooks }
DummyUser >> onBeforeDestroy [
	super onBeforeDestroy.
	self beforeDestroy: true
]

{ #category : #hooks }
DummyUser >> onBeforeInsert [
	super onBeforeInsert.
	self beforeInsert: true
]

{ #category : #hooks }
DummyUser >> onBeforeSave [
	super onBeforeSave.
	self beforeSave: true
]

{ #category : #hooks }
DummyUser >> onBeforeUpdate [
	super onBeforeUpdate.
	self beforeUpdate: true
]

{ #category : #hooks }
DummyUser >> onBeforeUpsert [
	super onBeforeUpsert.
	self beforeUpsert: true
]
