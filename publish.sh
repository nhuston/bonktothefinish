git pull origin master

git add -A
git commit -m "$1"
git push origin master

middleman deploy
