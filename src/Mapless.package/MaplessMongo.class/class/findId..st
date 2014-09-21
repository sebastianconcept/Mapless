accessing
findId: anId

	^ self findOne: (Dictionary new
					at: 'id' put: anId;
					yourself)