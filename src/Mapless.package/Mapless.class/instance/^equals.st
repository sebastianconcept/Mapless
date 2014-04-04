testing
= aModel 
	"Answers true if this model is the same as aModel.
	Note: as you can see, this won't care about identity (yes, that's intentional)."
	^ (aModel isKindOf: self) and:[
	self id = aModel id]