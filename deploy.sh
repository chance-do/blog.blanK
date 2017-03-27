#!/bin/bash
echo -e "\033[31m Deploying updates to GitHub...\033[0m"

msg="rebuilding site `date`"

if [ $# -eq 1 ]
  then msg="$1"
fi

# update blog.blanK
git add .

git commit -m "$msg"

git push origin master

# Build the project.
hugo 

# Init Deploy folder
mkdir deploy_git

cd deploy_git/

git init

git remote add origin git@github.com:mjyi/mjyi.github.io.git

git pull origin master

cp -R ../public/* .

git add .

git commit -m "$msg"

# Push source and build repos.
git push origin master

echo -e "\033[31m Finished \033[0m"
