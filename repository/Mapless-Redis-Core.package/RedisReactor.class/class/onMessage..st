reactions
onMessage: aMessage

	| id |

	[id := aMessage readStream upTo: $.; upToEnd]
		on: Error 
		do:[:x| ^ Transcript cr; show: 'Unknown Redis message: ', aMessage asString].

	self onChangeAt: id
	