actions
setReferencesFrom: someJsonStrings on: aKey of: aJsonObject
	"Set references (only if someJsonStrings feels like those)"

	 aJsonObject 
		at: aKey 
		put: (someJsonStrings collect: [:json| self makeReferenceFrom: json])