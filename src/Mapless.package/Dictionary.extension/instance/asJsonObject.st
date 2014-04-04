*mapless
asJsonObject
	"Answers a JSON object based on the contents of this dictionary."
	
	^ [:json|
		self keysAndValuesDo: [ :k :v| 
			json at: k put: v].
		json ] value: JsonObject new 
		