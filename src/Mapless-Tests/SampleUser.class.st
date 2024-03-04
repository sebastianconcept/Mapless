Class {
	#name : #SampleUser,
	#superclass : #Mapless,
	#category : #'Mapless-Tests-Samples'
}

{ #category : #'as yet unclassified' }
SampleUser class >> findUsername: anUsername [
	^ self getRepository
		findOne: self
		where: {('username' -> anUsername)} asDictionary
]

{ #category : #accessing }
SampleUser >> completeName [
	^ self person firstName , ' ' , self person lastName
]

{ #category : #hooks }
SampleUser >> onAfterDelete [
	super onAfterDelete.
	self afterDelete: true
]

{ #category : #hooks }
SampleUser >> onAfterDestroy [
	super onAfterDestroy.
	self afterDestroy: true
]

{ #category : #hooks }
SampleUser >> onAfterInsert [
	super onAfterInsert.
	self afterInsert: true
]

{ #category : #hooks }
SampleUser >> onAfterSave [
	super onAfterSave.
	self afterSave: true
]

{ #category : #hooks }
SampleUser >> onAfterUpdate [
	super onAfterUpdate.
	self afterUpdate: true
]

{ #category : #hooks }
SampleUser >> onAfterUpsert [
	super onAfterUpsert.
	self afterUpsert: true
]

{ #category : #hooks }
SampleUser >> onBeforeDelete [
	super onBeforeDelete.
	self beforeDelete: true
]

{ #category : #hooks }
SampleUser >> onBeforeDestroy [
	super onBeforeDestroy.
	self beforeDestroy: true
]

{ #category : #hooks }
SampleUser >> onBeforeInsert [
	super onBeforeInsert.
	self beforeInsert: true
]

{ #category : #hooks }
SampleUser >> onBeforeSave [
	super onBeforeSave.
	self beforeSave: true
]

{ #category : #hooks }
SampleUser >> onBeforeUpdate [
	super onBeforeUpdate.
	self beforeUpdate: true
]

{ #category : #hooks }
SampleUser >> onBeforeUpsert [
	super onBeforeUpsert.
	self beforeUpsert: true
]
