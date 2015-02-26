accessing
find: someConditions 
	"Answer a collection of instances of the receiver that meet with someConditions from the repository."

	^self currentRepository instancesOf: self where: someConditions 
		