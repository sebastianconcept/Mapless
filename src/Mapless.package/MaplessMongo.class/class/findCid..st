accessing
findCid: anId

	^ self findOne: (Dictionary new 
						at: 'cid' put: anId;
						yourself)