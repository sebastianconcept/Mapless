"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestMaplessRedisTests,
	#superclass : #PackageManifest,
	#category : #'Mapless-Redis-Tests-Manifest'
}

{ #category : #'code-critics' }
ManifestMaplessRedisTests class >> ruleRBSentNotImplementedRuleV1FalsePositive [
	^ #(#(#(#RGPackage #(#'Mapless-Redis-Tests')) #'2022-03-13T13:50:33.48498-03:00') )
]
