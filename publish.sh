git pull origin master

#sh source/images/shrink_img.sh $(pwd)/source/images/blog #netlify will shrink images

git add -A
git commit -m "$1"
git push origin master
