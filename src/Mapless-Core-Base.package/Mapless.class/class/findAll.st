accessing
findAll 
	"Answer a collection with all receiver instances from the repository."

	^self currentRepository instancesOf: self where: Dictionary new 