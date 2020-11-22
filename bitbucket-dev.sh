cd /var/www/
git reset --hard
git clean -f
git checkout dev
git pull
make deploy
exit