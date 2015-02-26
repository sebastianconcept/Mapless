actions
jsonWriteOn: aStream 

	| payload |

	payload := Dictionary new.
	payload at: 'modelClass' put: modelClass.
	payload at: 'message' put: message.
	payload at: 'modelId' put: modelId.

	payload
		at: 'id'
		put: (SecureHashAlgorithm new hashMessage: payload asJsonString).

	payload jsonWriteOn: aStream