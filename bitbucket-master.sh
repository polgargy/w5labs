cd /var/www/
git reset --hard
git clean -f
git checkout master
git pull
make deploy
exit