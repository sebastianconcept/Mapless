actions
unstringify: aString
	"Answers a the bytearray encoded into aString"
	
	^ aString base64Decoded asByteArray