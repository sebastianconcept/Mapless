accessing
findOne: someConditions 
	"Answer a collection of instances of the receiver that meet with someConditions from the repository."

	^self currentRepository instanceOf: self where: someConditions 
		