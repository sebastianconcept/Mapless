actions
basicInsert: aBSONFriendlyObject

	^ database do: [ :pg | | result |
		result := pg execute: 'INSERT INTO "',(aBSONFriendlyObject modelClass),'" VALUES (
			''',aBSONFriendlyObject key,''',
			''',aBSONFriendlyObject asJSONString,''');' ]