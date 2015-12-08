function goodmorning(){
    # do the ssh-agent stuff
    eval $(ssh-agent -s)
    if test "$SSH_AUTH_SOCK"; then
        ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
    fi  
    keyscan
    # Fire up tmux, set layouts, etc.
    tmux new-session -s rax3 -d
    for i in {0..1}; do  
        tmux split-window -t rax3:0.0 -v; 
    done

    tmux select-layout -t rax3:0 even-vertical

    # When I get around to using finch
    ## tmux split-window -t rax3:0.1 -h

    # For pianobar
    tmux split-window -t rax:0.0 -h

    # Start up all my crap.
    tmux send-keys -t rax3:0.0 "ssh shellbox" C-m 
    tmux send-keys -t rax3:0.0 "tmux attach -d" C-m 
    tmux send-keys -t rax3:0.1 "mutt" C-m 
    tmux send-keys -t rax3:0.2 "irssi" C-m 
    tmux send-keys -t rax3:0.3 "pianobar" C-m 

    # Again, more finch stuff.
    # These pane numbers are jacked up, will need adjustment when I move to finch.
    ## tmux send-keys -t rax3:0.2 "weechat-curses" C-m
    ## tmux send-keys -t rax3:0.3 "irssi" C-m
    tmux attach -d -t rax3
} 

function keyscan() {
        for sshkey in $(ls ~/.ssh/*.key); do
                ssh-add -t 10h $sshkey
        done    
}


# Aliases

function ssl_check(){
    while getopts ":d" opt; do 
        case $opt in 
            d)
                local _debug_enabled='yes'
            ;;
        esac
    done

    REMHOST=$1
    REMPORT=${2:-443}

    thecert=$(echo | openssl s_client -connect ${REMHOST}:${REMPORT} 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')

    function sedstuff() {
            [[ "$2" == "issuer" ]] && local _openssl_arg='-issuer' && local _sed_arg='issuer' 
            [[ "$2" == "subject" ]] && local _openssl_arg='-subject' && local _sed_arg='subject' 
             echo "$1" | openssl x509 -noout ${_openssl_arg} -in /dev/stdin | sed -e "s/${_sed_arg}=\ //g" \
                    -e 's/\/O=/\nOrganization:|/g' \
                    -e 's/\/C=/Country:|/g' \
                    -e 's/\/OU=/\nOrganizational Unit:|/g' \
                    -e 's/\/CN=/\nCommon Name:|/g' \
                    -e 's/\/L=/\nCity:|/g' \
                    -e 's/\/ST=/\nState:|/g' \
                    -e 's/\/emailAddress=/\nE-Mail:|/g' \
                    -e 's/\/postalCode=/\nPostal Code:|/g' \
                    -e 's/\/streetAddress=/\nStreet Address:|/g' | column -t -s '|'
    }
    [ ! -z $_debug_enabled ] && echo -e "$thecert\n"
    echo -e "Issued By\n--------------------------------"
    sedstuff "$thecert" "issuer"
    echo
    echo -e "Issued To\n--------------------------------"
    sedstuff "$thecert" "subject"
    echo
    echo -e "Validity\n--------------------------------"
    echo "$thecert" | openssl x509 -noout -startdate -in /dev/stdin | sed 's/notBefore=/From: /g'
    echo "$thecert" | openssl x509 -noout -enddate -in /dev/stdin | sed 's/notAfter=/Till: /g'
    echo
    echo -e "Fingerprint\n-------------------------------"
    echo "$thecert" | openssl x509 -noout -in /dev/stdin -fingerprint | sed 's/^.*=//g'
    echo
    echo -e "Subject Alternative Names\n-------------------------------"                                                
    echo "$thecert" | openssl x509 -noout -in /dev/stdin -text | grep 'DNS:' | sed -e 's/DNS://g' -e 's/               //g' -e 's/\,\ /\n/g' | sort
    unset opt _debug_enabled _sed_arg _openssl_arg thecert
}

check_ssl_file(){


thecert=$(cat $1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')


echo  "$thecert"
echo
echo Issued By
echo --------------------------------
echo  "$thecert" | openssl x509 -noout -issuer -in /dev/stdin | sed s/issuer=\ // | sed 's/\/O=/\nOrganization: /g' | sed 's/\/C=/Country: /g' | sed 's/\/OU=/\nOrganizational Unit: /g' | sed 's/\/CN=/\nCommon Name: /g' | sed 's/\/L=/\nCity: /g' | sed 's/\/ST=/\nState: /g' | sed 's/\/emailAddress=/\nE-Mail: /g' | sed 's/\/postalCode=/\nPostal Code: /g' | sed 's/\/streetAddress=/\nStreet Address: /g'
echo
echo Issued To
echo --------------------------------
echo  "$thecert" | openssl x509 -noout -subject -in /dev/stdin | sed s/subject=\ // | sed 's/\/O=/\nOrganization: /g' | sed 's/\/C=/Country: /g' | sed 's/\/OU=/\nOrganizational Unit: /g' | sed 's/\/\CN=/\nCommon Name: /g' | sed 's/\/ST=/\nState: /g' | sed 's/\/L=/\nCity: /g' | sed 's/\/emailAddress=/\nE-Mail: /g' | sed 's/\/postalCode=/\nPostal Code: /g' | sed 's/\/streetAddress=/\nStreet Address: /g'
echo
echo Validity
echo --------------------------------
echo  "$thecert" | openssl x509 -noout -startdate -in /dev/stdin | sed 's/notBefore=/From: /g'
echo  "$thecert" | openssl x509 -noout -enddate -in /dev/stdin | sed 's/notAfter=/Till: /g'
echo
}


function doing_this(){
	echo -ne "$TXT_YLW$1$TXT_RESET"
}

function done_box(){
	echo -n -e "$1[$TXT_GREEN DONE $TXT_RESET]\n"
}

function check_ip() {
    echo "$1    $(curl -sH "Accept: application/json" http://whois.arin.net/rest/ip/$1 |  sed -e 's/[{}]/''/g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | egrep '(customer|org)Ref' | sed 's/\"//g'| cut -d : -f 3)"

}

function gtfo(){
    xscreensaver-command -lock
    /home/ag/.gitrepos/bin/gitsync.sh
}


