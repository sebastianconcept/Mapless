actions
at: anId 

	^ self at: anId ifAbsent: [ MaplessCacheFail signal: 'Model not found at ', anId ]