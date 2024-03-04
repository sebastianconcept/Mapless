Class {
	#name : #ExampleUser,
	#superclass : #Object,
	#traits : 'MaplessBehavior',
	#classTraits : 'MaplessBehavior classTrait',
	#category : #'Mapless-Behavior-Tests'
}

{ #category : #'as yet unclassified' }
ExampleUser class >> findUsername: anUsername [

	^ self getRepository
		  findOne: self
		  where: { ('username' -> anUsername) } asDictionary
]

{ #category : #accessing }
ExampleUser >> completeName [

	^ self person firstName , ' ' , self person lastName
]

{ #category : #hooks }
ExampleUser >> onAfterDestroy [

	self afterDestroy: true
]

{ #category : #hooks }
ExampleUser >> onAfterInsert [

	self afterInsert: true
]

{ #category : #hooks }
ExampleUser >> onBeforeUpdate [

	self beforeUpdate: true
]

{ #category : #hooks }
ExampleUser >> onBeforeUpsert [
	super onBeforeUpsert.
	self beforeUpsert: true
]
