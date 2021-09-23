"
I have a dictionary to translate the names of the classes in this image to the corresponding names of the collection names in the Mapless backend (camel sensitive).
"
Class {
	#name : #MaplessCustomCollectionNameResolver,
	#superclass : #MaplessResolver,
	#instVars : [
		'translations'
	],
	#category : #'Mapless-Base-Core-Resolvers'
}

{ #category : #initialization }
MaplessCustomCollectionNameResolver >> initializeTranslations [
	^ translations := Dictionary new
]

{ #category : #accessing }
MaplessCustomCollectionNameResolver >> maplessClassNameFor: aJsonObject in: aMaplessRepository [
	| classSelector |
	classSelector := aJsonObject at: '_c'.
	^ self translations
		at: classSelector
		ifAbsent: [ self error: 'This resolver could not translate ' , classSelector ]
]

{ #category : #accessing }
MaplessCustomCollectionNameResolver >> translations [
	^ translations ifNil: [ self initializeTranslations ]
]

{ #category : #accessing }
MaplessCustomCollectionNameResolver >> translations: aDictionary [
	translations := aDictionary
]
