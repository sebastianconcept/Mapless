accessing
findId: anId

	^ self find: (Dictionary new
					at: 'id' put: anId;
					yourself)