
n goodmorning(){
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
#    tmux split-window -t rax3:0.1 -h

    # Start up all my crap.
    tmux send-keys -t rax3:0.0 "ssh shellbox" C-m 
    tmux send-keys -t rax3:0.0 "tmux attach -d" C-m 
    tmux send-keys -t rax3:0.1 "mutt" C-m 
    tmux send-keys -t rax3:0.2 "irssi" C-m 

    # Again, more finch stuff.
#    tmux send-keys -t rax3:0.2 "weechat-curses" C-m
#    tmux send-keys -t rax3:0.3 "irssi" C-m
    tmux attach -d -t rax3
} 


function keyscan() {
        for sshkey in $(ls ~/.ssh/*.key); do
                ssh-add -t 10h $sshkey
        done    
}

function cya(){ 
    datestring=$(date +%Y%m%d.%H%m)
    cp $1{,-$datestring};
}

