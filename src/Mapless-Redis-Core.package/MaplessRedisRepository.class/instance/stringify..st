actions
stringify: aByteArray
	"Answers a string encoding of aByteArray"
	
	^ aByteArray asString base64Encoded 