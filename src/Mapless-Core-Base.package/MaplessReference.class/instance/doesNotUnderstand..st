accessing
doesNotUnderstand: aMessage
	"The idea behind this DNU is to use the selector as setters or getter 
	delegating to data (aJsonObject)"
		
	^ self model 
		perform: aMessage 
		selector withArguments: aMessage arguments 	