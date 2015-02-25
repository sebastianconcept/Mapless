accessing
instancesOf: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."
				
	^ database do: [ :pg | | result |
		result := pg execute: 'SELECT VALUE FROM "',
			(aMaplessClass name),'" WHERE ',someConditions,';'.
			
		(result isNil or: [ 
		result resultSets isEmpty ])
			ifTrue: [ #() ]
			ifFalse: [ result resultSets first rows collect: [ :row | | json |
						json := Json readFrom: row data first readStream.
						self onAfterRead: (aMaplessClass fromJSONObject: json)] ] ]