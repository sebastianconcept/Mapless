accessing
findId: anId

	^ self findOne: (Dictionary new 
						at: self idAttribute put: anId;
						yourself)