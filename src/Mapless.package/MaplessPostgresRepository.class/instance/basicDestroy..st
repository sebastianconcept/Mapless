actions
basicDestroy: aBSONFriendlyObject

	^ database do: [ :pg | | result |
		result := pg execute: 'DELETE FROM "',(aBSONFriendlyObject modelClass),'" * WHERE
				"key" = ''',aBSONFriendlyObject key,''';' ]