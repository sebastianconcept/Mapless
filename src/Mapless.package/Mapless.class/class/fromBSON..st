accessing
fromBSON: someBSONData

	^ self fromJSONObject: (BSON read: someBSONData readStream) asJsonObject 