"
Flow models are meant to be treated as aggregates.

We don't care here about identity.

Why?

Because the idea is that you keep these objects small and uncomplicated enough to be more efficienty serialized/deserialized in JSON for using it is some sort of noSQL persistence support.

Mapless uses MaplessBehavior. A subclass of Mapless keeps Mapless as its superclass. A class that already has another superclass uses MaplessBehavior directly.
"
Class {
	#name : #Mapless,
	#superclass : #Object,
	#traits : 'MaplessBehavior',
	#classTraits : 'MaplessBehavior classTrait',
	#category : #'Mapless-Base-Models'
}

{ #category : #testing }
Mapless class >> isAbstract [
	"Answers true if the model class is abstract.
	Very useful to subclassify a family of model classes 
	of which wouldn't make sense to create instances.

	You can (sub) implement where nessesary in an abstract model like this:
	
	^ self == AnAbstractModelClass"

	^ self == Mapless
]

{ #category : #printing }
Mapless class >> pluralName [
	"Answers the plural name used by an API.
	Subclasses of Mapless still receive the application-responsibility warning. The trait method answers the same words without that warning."

	self deprecated: 'Application responsibility'.
	^ self singularName , 's'
]

{ #category : #printing }
Mapless class >> singularName [
	"Answers the singular name used by an API.
	Subclasses of Mapless still receive the application-responsibility warning. The trait method answers the same words without that warning."

	self deprecated: 'Application responsibility'.
	^ self name asLowercase
]
