accessing
id: anId

	^ self data 
		at: self currentRepository idAttribute 
		put: anId