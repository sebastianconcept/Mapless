accessing
instancesOf: aMaplessClass where: someConditions
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^self instancesOf: aMaplessClass where: someConditions limit: nil offset: nil