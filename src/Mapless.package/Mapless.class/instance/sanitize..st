actions
sanitize: someFields 	
	"Removes someFields from the receiver."
	
	someFields do:[:key|
		self data removeKey: key ifAbsent: [nil] ]