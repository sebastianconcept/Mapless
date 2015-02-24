actions
readFrom: aStream

	| json newJob |

	newJob := self new.

	json := Json readFrom: aStream.

	^ newJob 
		modelClass: (Smalltalk at: ( json at: 'modelClass' ) asSymbol);
		message: ( json at: 'message' ) asSymbol;
		modelId: (json at: 'modelId');
		id: (json at: 'id');
		yourself