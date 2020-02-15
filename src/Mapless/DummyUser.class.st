Class {
	#name : #DummyUser,
	#superclass : #Mapless,
	#category : #'Mapless-Models'
}

{ #category : #'as yet unclassified' }
DummyUser class >> findUsername: anUsername [

	^self currentRepository 
		instanceOf: self 
		where: (JsonObject newFromPairs: {'username' . anUsername})
]

{ #category : #accessing }
DummyUser >> completeName [

	^ self person firstName, ' ', self person lastName
]

{ #category : #reactions }
DummyUser >> onAfterDelete [

	super onAfterDelete.
	
	self afterDelete: true
]

{ #category : #reactions }
DummyUser >> onAfterDestroy [

	super onAfterDestroy.
	
	self afterDestroy: true
]

{ #category : #reactions }
DummyUser >> onAfterInsert [

	super onAfterInsert.
	
	self afterInsert: true
]

{ #category : #reactions }
DummyUser >> onAfterSave [

	super onAfterSave.
	
	self afterSave: true
]

{ #category : #reactions }
DummyUser >> onAfterUpdate [

	super onAfterUpdate.
	
	self afterUpdate: true
]

{ #category : #reactions }
DummyUser >> onBeforeDelete [

	super onBeforeDelete.
	
	self beforeDelete: true
]

{ #category : #reactions }
DummyUser >> onBeforeDestroy [

	super onBeforeDestroy.
	
	self beforeDestroy: true
]

{ #category : #reactions }
DummyUser >> onBeforeInsert [

	super onBeforeInsert.
	
	self beforeInsert: true
]

{ #category : #reactions }
DummyUser >> onBeforeSave [

	super onBeforeSave.
	
	self beforeSave: true
]

{ #category : #reactions }
DummyUser >> onBeforeUpdate [

	super onBeforeUpdate.
	
	self beforeUpdate: true
]
