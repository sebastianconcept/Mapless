accessing
instanceOf: aMapless atId: anId

	^ self  
		instanceOf: aMapless 
		where: (self idAttribute, ' = ''', anId, '''')