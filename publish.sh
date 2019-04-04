git pull origin master

#netflify shrinks imgs, but does not convert to diff file types. Keep image shrinking
# sh source/images/shrink_img.sh $(pwd)/source/images/blog
python3 source/images/shrink_imgs.py

git add -A
git commit -m "$1"
git push origin master
