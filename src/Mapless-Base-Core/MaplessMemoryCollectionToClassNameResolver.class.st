Class {
	#name : #MaplessMemoryCollectionToClassNameResolver,
	#superclass : #MaplessResolver,
	#category : #'Mapless-Base-Core-Resolvers'
}

{ #category : #accessing }
MaplessMemoryCollectionToClassNameResolver >> conditionForClass: aMaplessClass [
	^ [ :each | each class = aMaplessClass ]
]
