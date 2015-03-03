actions
fromJSONObject: aJsonObject

	^ self new
		id: (aJsonObject at: Mapless idAttribute);
		modelClass: aJsonObject modelClass;
		yourself 