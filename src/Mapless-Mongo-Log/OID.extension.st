Extension { #name : #OID }

{ #category : #'*Mapless-Mongo-Log' }
OID >> neoJsonOn: neoJSONWriter [
	neoJSONWriter writeOID: self
]
