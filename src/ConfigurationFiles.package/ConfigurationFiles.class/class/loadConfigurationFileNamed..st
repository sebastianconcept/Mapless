actions
loadConfigurationFileNamed: aConfKey
	^ self configurations
		at: aConfKey
		put: (SpEnvironment evaluate: ((SpFilename named: 'conf') construct: aConfKey, '.conf') contentsOfEntireFile in: nil)