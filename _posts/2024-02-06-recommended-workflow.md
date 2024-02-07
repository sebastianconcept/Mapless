---
layout: guide
title:  "Recommended workflow"
date:   2024-02-06 18:39:16 -0300
categories: guides
---

### Recommended workflow

The recomended workflow goes like this:

1. **Always fresh**. Do not reuse images. Install `Mapless` or the instructions of the guides here in fresh image.
2. **Always autoformat**. Custom formatting in a per team basis would be ideal. While that isn't the norm, use the autoformatter to remove friction in [PR reviews](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews).
3. **Commit changes**. Consider saving the image *a transient convenience* and consider actual saved code to be the last commit you did using [Pharo](https://pharo.org) [Git tool](https://github.com/pharo-vcs/iceberg) in the right branch.
4. **Embrace [Gitflow](https://danielkummer.github.io/git-flow-cheatsheet/)**. Develop features and fixes in new branches that you can merge on `develop` while maintaining official versions in the `master` branch earning trust from the community.
5. **Emrbace [semantic versioning](https://semver.org/)**. Use other engineers expectations about progres, fixes, improvements and compatibility between APIs of newer versions to your advantage embracing semantic versioning tagging commits. For  [Pharo](https://pharo.org) versions you can create a specific additional tag like `pharo9`, `pharo10` and `pharo11`, etc beside keeping the numbered ones and a `latest` to move the progress of your most recent one.
6. **[Smalltalk CI](https://github.com/hpi-swa/smalltalkCI)**. And GitHub Actions.
7. **Docker**. Do not make hard to use the final outcome of your work. Keep your development process easy for the next step to happen by making a containerizable build so it can be used as input in some [devops](https://en.wikipedia.org/wiki/DevOps) process.