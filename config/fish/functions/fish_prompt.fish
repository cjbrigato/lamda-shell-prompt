function fish_title
 hostname
end




function _common_section
    printf $c1
    printf $argv[1]
    printf $c0
    printf ""
    printf $c2
    printf $argv[2]
    printf $argv[3]
    printf $c0
    printf " "
    set_color normal

end

function section
    _common_section $argv[1] $c3 $argv[2] $ce
end

function error
    _common_section $argv[1] $ce $argv[2] $ce
end


function git_branch
    set -g git_branch (git rev-parse --abbrev-ref HEAD ^ /dev/null)
    if [ $status -ne 0 ]
        set -ge git_branch
        set -g git_dirty_count 0
    else
        set -g git_dirty_count (git status --porcelain  | wc -l | sed "s/ //g")
    end
end

function fish_prompt
    # $status gets nuked as soon as something else is run, e.g. set_color
    # so it has to be saved asap.
    set -l last_status $status

    if [ $last_status -ne 0 ]
        set_color red
        echo -e -n $last_status ''
        set -ge status
    else
        set_color normal
    end
    echo -e -n "λ "
    set_color normal
end

function fish_right_prompt

    # c0 to c4 progress from dark to bright
    # ce is the error colour
    set -g c0 (set_color 005284)
    set -g c1 (set_color 0075cd)
    set -g c2 (set_color 009eff)
    set -g c3 (set_color 6dc7ff)
    set -g c4 (set_color ffffff)
    set -g ce (set_color $fish_color_error)

    # Clear the line because fish seems to emit the prompt twice. The initial
    # display, then when you press enter.
    # printf "\033[K"

    # Current Directory
    # 1st sed for colourising forward slashes
    # 2nd sed for colourising the deepest path (the 'm' is the last char in the
    # ANSI colour code that needs to be stripped)
    printf $c1
    # echo -e (pwd | sed "s,/,$c0/$c1,g" | sed "s,\(.*\)/[^m]*m,\1/$c3,")  # full
    echo -e (prompt_pwd | sed "s,/,$c0/$c1,g" | sed "s,\(.*\)/[^m]*m,\1/$c3,")
    echo -e " "



    # Show last execution time 
    set -g taken $CMD_DURATION
    if not set -q taken
	 set -g taken '0'
    end
         if test $taken -gt 10 ^ /dev/null
	     set -g taken (echo "scale=2; $taken/1000"|bc -l)
             error T $taken
         end

    # Show loadavg when too high
    set -l load1m (uptime | grep -o '[0-9]\+\.[0-9]\+' | head -n1)  # LINUX 
    #  set -l load1m (sysctl -n vm.loadavg | awk '{print $2}')  # FOR MAC
    set -l load1m_test (math $load1m \* 100 / 1)
    #if test $load1m_test -gt 100
        error L $load1m
    #end

    # Show disk usage when low
    set -l du (df / | tail -n1 | sed "s/  */ /g" | cut -d' ' -f 5 | cut -d'%' -f1)
    #if test $du -gt 80
        error / $du
    #end

    # Virtual Env
    if set -q VIRTUAL_ENV
        section env (basename "$VIRTUAL_ENV")
    end

    # Git branch and dirty files
    git_branch
    if set -q git_branch
        #set out $git_branch
        if test $git_dirty_count -gt 0
            set out "$out$c0$ce$git_dirty_count "
        end
	set_color yellow
        printf "G"
	set_color normal
	printf $out
    end

    # Current time
    printf (date "+$c2%H$c0:$c2%M$c0:$c2%S ")

    echo $c4
    set_color normal

end
