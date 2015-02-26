actions
setSubModels
	"On demand creates sub models regarding 
	to the JSON data this instance."

	self data keysAndValuesDo: [ :k :v |
		self setSubModelsAt: k with: v ]