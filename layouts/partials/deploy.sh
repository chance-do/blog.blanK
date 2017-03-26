echo -e "\033[31m Deploying to GitHub...\033[0m"

msg="rebuilding at `date`"

if [ $# -eq 1 ]
  then msg="$1"
fi

# update
git add .

git commit -m "$msg"

git push origin master

hugo 

mkdir deploy_git

cd deploy_git/

git init

git remote add origin git@github.com:mjyi/mjyi.github.io.git

git pull origin master

cp -R ../public/* .

git add .

git commit -m "$msg"

git push origin master

echo -e "\033[31m Over!\033[0m"

