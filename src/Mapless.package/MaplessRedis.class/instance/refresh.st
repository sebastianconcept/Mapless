actions
refresh

	| result |
	
	result := self class valueAt: self id.
	result ifNil:[ self error: 'Model not stored: ', self id ].

	data := (self class jsonObjectFromValue: result) asJsonObject 