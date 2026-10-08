Class {
	#name : #MaplessMemoryCollectionToClassNameResolver,
	#superclass : #MaplessResolver,
	#category : #'Mapless-Base-Resolvers'
}

{ #category : #accessing }
MaplessMemoryCollectionToClassNameResolver >> conditionForClass: aMaplessClass [
	^ [ :each | each class = aMaplessClass ]
]
