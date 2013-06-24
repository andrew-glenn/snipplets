#!/bin/bash
# Git/gpg backup script
# Andrew Glenn
#
#
# You'll need to adjust --strip-components=3 to how deep your repo is.
# This is based on a /home/user/.gitrepos or /Users/user/.gitrepos flow. 
#
stagedir="$HOME/.encrypt-staging"
repodir="$HOME/.gitrepos"
key_email="foo@bar.com"
g_server="git.example.com"
g_user="Joe.User"
g_repo="foobar-repo.git"


function push(){
    tar -czvf $stagedir/daily.tar.gz $repodir >/dev/null 2>&1
    cd $stagedir
    gpg -er $key_email $stagedir/daily.tar.gz
    git add daily.tar.gz.gpg
    git commit -m "Daily Commit"
    git push -u origin master
    rm $stagedir/daily.tar.gz
}

function pull(){
    cd $stagedir
    git pull origin master
    mv $stagedir/daily.tar.gz.gpg /tmp/
    gpg -d /tmp/daily.tar.gz.gpg > $stagedir/daily.tar.gz
    tar -zxvf $stagedir/daily.tar.gz -C $repodir/ --strip-components=3  >/dev/null 2>&1
    rm $stagedir/daily.tar.gz
}

function fixstuff(){
    rm -rf $stagedir
    mkdir -p $stagedir
    cd $stagedir
    git init
    git remote add origin $g_server:$g_user/$g_repo
}

function usage(){
    echo
    echo "$0 (push|pull|reset)"
    echo
}

input="$(echo $1 | tr '[:upper:]' '[:lower:]')"

case "$input" in
    "push" )
         push
     ;;
    "pull" )
        pull
    ;;
    "reset" )
        fixstuff
    ;;
    * ) 
        usage
        exit 1
esac

