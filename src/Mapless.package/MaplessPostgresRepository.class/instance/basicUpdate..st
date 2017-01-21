actions
basicUpdate: aBSONFriendlyObject

	^ database do: [ :pg | | result |
		result := pg execute: 'UPDATE "',(aBSONFriendlyObject modelClass),'" SET 
			"value" = ''',aBSONFriendlyObject asJSONString,''' WHERE
				"key" = ''',aBSONFriendlyObject key,''';' ]