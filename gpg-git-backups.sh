#!/bin/bash
stagedir="$HOME/.encrypt-staging"
repodir="$HOME/.gitrepos"
keyuser="<FOOBAR>"                                                                                                

function push(){
    tar -czvf $stagedir/daily.tar.gz $repodir
    cd $stagedir
    gpg -er $keyuser $stagedir/daily.tar.gz
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
    tar -zxvf $stagedir/daily.tar.gz -C $repodir/
    rm $stagedir/daily.tar.gz
}

function usage(){
    echo
    echo "$0 (push|pull)"
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
    * ) 
        usage
        exit 1
esac

