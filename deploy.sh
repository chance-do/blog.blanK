#!/bin/bash
echo -e "\033[31m Deploying updates to GitHub...\033[0m"

msg="rebuilding site `date`"

if [ $# -eq 1 ]
  then msg="$1"
fi

rm -rf public
# update blog.blanK
git add .

git commit -m "$msg"

git push origin master

# Build the project.
hugo 

# Init Deploy folder
deployPath="deploy_git/"

if [ ! -d "$deployPath" ]; then
	mkdir "$deployPath"
	cd "$deployPath"
	git init
	git remote add origin git@github.com:mjyi/mjyi.github.io.git
	git pull origin master
else
	cd "$deployPath"
	git fetch origin
	git checkout master
	git reset --hard origin/master
	git pull origin master

fi


cp -R ../public/* .

git add .

git commit -m "$msg"

# Push source and build repos.
git push origin master

echo -e "\033[31m Finished \033[0m"
