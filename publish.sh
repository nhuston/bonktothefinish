git pull origin master

sh source/images/shrink_img.sh $(pwd)/source/images/blog

git add -A
git commit -m "$1"
git push origin master

middleman deploy
