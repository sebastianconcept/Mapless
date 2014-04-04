actions
fromJSONObject: aJsonObject

	^ self new
		oid: aJsonObject oid;
		modelClass: aJsonObject modelClass;
		yourself 