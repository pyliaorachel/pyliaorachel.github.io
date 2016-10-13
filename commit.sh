#!/bin/bash
if [ $# -ne 1 ]
then
	echo "Should provide your commit message!"
else
	msg=$1

	jekyll build
	git add -A
	git commit -m "${msg}"
	git push origin master:source
	cd _site
	touch .nojekyll
	git add -A
	git commit -m "${msg}"
	git push origin master
	cd ..
fi