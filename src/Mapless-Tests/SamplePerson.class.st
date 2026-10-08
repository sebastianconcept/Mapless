Class {
	#name : #SamplePerson,
	#superclass : #Mapless,
	#category : #'Mapless-Tests-Samples'
}

{ #category : #hooks }
SamplePerson >> onAfterDestroy [

	super onAfterDestroy.

	self recentlyDestroyed: true
]

{ #category : #hooks }
SamplePerson >> onAfterSave [

	super onAfterSave.

	self recentlySaved: true
]
