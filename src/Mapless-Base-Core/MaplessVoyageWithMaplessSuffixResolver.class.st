"
I help with using a Voyage backend creating Mapless and MaplessReferences out of data meant for Voyage documents.
"
Class {
	#name : #MaplessVoyageWithMaplessSuffixResolver,
	#superclass : #MaplessResolver,
	#instVars : [
		'suffix'
	],
	#category : #'Mapless-Base-Core-Resolvers'
}

{ #category : #testing }
MaplessVoyageWithMaplessSuffixResolver >> canRepresentSubMapless: anObject in: aMaplessRepository [
	"Answers true if anObject can represent a sub mapless."

	^ (super canRepresentSubMapless: anObject in: aMaplessRepository)
		or: [ self isVoyageReference: anObject in: aMaplessRepository ]
]

{ #category : #testing }
MaplessVoyageWithMaplessSuffixResolver >> isVoyageReference: anObject in: aMaplessRepository [
	"Answers true if anObject has the keys and values of a voyage reference."

	^ anObject isDictionary
		and: [ anObject size = 3
				and: [ (anObject includesKey: '__id')
						and: [ (anObject includesKey: '#instanceOf')
								and: [ anObject includesKey: '#collection' ] ] ] ]
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> maplessClassNameFor: aJsonObject in: aMaplessRepository [
	^ (self isVoyageReference: aJsonObject in: aMaplessRepository)
		ifTrue: [ (aJsonObject at: '#instanceOf') , suffix ]
		ifFalse: [ aJsonObject at: '_c' ]
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> referenceDataFrom: aJsonObject in: aMaplessRepository [
	^ (MaplessResolver
		isVoyageReference: aJsonObject
		in: aMaplessRepository)
		ifTrue: [ JsonObject new
				at: aMaplessRepository idPropertyName put: aJsonObject __id;
				at: '_c' put: (aJsonObject at: '#instanceOf') , suffix;
				yourself ]
		ifFalse: [ aJsonObject ]
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> suffix [
	^ suffix
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> suffix: anObject [
	suffix := anObject
]
