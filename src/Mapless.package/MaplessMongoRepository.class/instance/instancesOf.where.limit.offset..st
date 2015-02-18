accessing
instancesOf: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	| result databaseCollection |

	databaseCollection := self databaseCollectionNamed: aMaplessClass name asString.
	result := databaseCollection query:[:q | 
		aLimitOrNil ifNotNil: [ :limit | q limit: limit ].
		anOffsetOrNil ifNotNil: [ :offset | q offset: offset ].
		q where: someConditions].
	^(result isNil and:[result isEmpty])
		ifTrue: [ #() ]
		ifFalse: [ (aMaplessClass fromJSONObjects: result) collect: [ :each | self onAfterRead: each ] ]