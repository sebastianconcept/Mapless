Class {
	#name : #ExampleUser,
	#superclass : #Object,
	#traits : 'MaplessBehavior @ {#maplessBehaviorOnAfterDestroy -> #onAfterDestroy. #maplessBehaviorOnAfterInsert -> #onAfterInsert. #maplessBehaviorOnBeforeUpdate -> #onBeforeUpdate. #maplessBehaviorOnBeforeUpsert -> #onBeforeUpsert}',
	#classTraits : 'MaplessBehavior classTrait',
	#category : #'Mapless-Behavior-Tests'
}

{ #category : #querying }
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

	self maplessBehaviorOnAfterDestroy.
	self afterDestroy: true
]

{ #category : #hooks }
ExampleUser >> onAfterInsert [

	self maplessBehaviorOnAfterInsert.
	self afterInsert: true
]

{ #category : #hooks }
ExampleUser >> onBeforeUpdate [

	self maplessBehaviorOnBeforeUpdate.
	self beforeUpdate: true
]

{ #category : #hooks }
ExampleUser >> onBeforeUpsert [

	self maplessBehaviorOnBeforeUpsert.
	self beforeUpsert: true
]
