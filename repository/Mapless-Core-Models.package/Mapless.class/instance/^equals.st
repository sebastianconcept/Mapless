testing
= aModel 
	"Answers true if this model is meant to be the same as aModel.

	Note: as you can see by the implementation, this:
	1. won't care about in-image identity
	2. will do care about in-database identity 
	3. is not the right method if you want to compare 
	the contained information with the one in aModel."
	
	^ (aModel class = self class) and:[
	self id = aModel id ]