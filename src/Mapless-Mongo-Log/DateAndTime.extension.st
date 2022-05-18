Extension { #name : #DateAndTime }

{ #category : #'*Mapless-Mongo-Log' }
DateAndTime >> neoJsonOn: neoJSONWriter [
	neoJSONWriter writeDateAndTime: self
]
