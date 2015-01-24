actions
fromJSONObject: aJsonObject

	^ self new
		id: (aJsonObject at: MaplessMongo idAttribute);
		modelClass: aJsonObject modelClass;
		yourself 