#!/bin/bash
# Authors of SlowFetch: Chatgpt, Cupbaordmanufacturer, Aeternusdio.
# SLOWFETCH IS DUEL LICENCED UNDER THE GNU AND MIT LICENCES RESPECTIVELY.
# The MIT License (MIT)
#
# Copyright (c) 2024 Apache Software Production. (ASP)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# SLOWFETCH IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
Version=1.2

# Define ANSI escape codes for colors
red='\033[0;31m'
green='\033[0;32m'
blue='\033[0;34m'
reset='\033[0m'

# Function to get distribution information
get_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ -n "$PRETTY_NAME" ]; then
            DISTRIBUTION="$PRETTY_NAME"
        elif [ -n "$NAME" ] && [ -n "$VERSION" ]; then
            DISTRIBUTION="$NAME $VERSION"
        fi
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRIBUTION="$DISTRIB_DESCRIPTION"
    elif [ -f /etc/debian_version ]; then
        DISTRIBUTION="Debian $(cat /etc/debian_version)"
    elif [ -f /etc/redhat-release ]; then
        DISTRIBUTION="Red Hat $(cat /etc/redhat-release)"
    else
        DISTRIBUTION="$(uname -s) $(uname -r)"
    fi
    os="${red}OS:${reset} $DISTRIBUTION"
}

# Function to get CPU information
get_cpu_info() {
    CPU_INFO=$(grep -m1 'model name' /proc/cpuinfo | cut -d':' -f2 | sed 's/^[ \t]*//')
    cpu="${red}CPU:${reset} $CPU_INFO"
}

# Function to get memory information
get_memory_info() {
    TOTAL_MEM=$(free -h | awk '/^Mem:/ {print $2}')
    TOTAL_SWP=$(free -h | awk '/^Swap:/ {print $2}')
    mem="${red}Memory:${reset} $TOTAL_MEM"
    swp="${red}Swap:${reset} $TOTAL_SWP"
}

# Function to get kernel version
get_kernel_version() {
    KERNEL_VERSION=$(uname -r)
    kernal="${red}Kernel:${reset} $KERNEL_VERSION"
}

# Function to get uptime
get_uptime() {
    UPTIME=$(uptime -p)
    up="${red}Uptime:${reset} $UPTIME"
}

# Function to get GPU information - will fix later
get_gpu() {
    GPU_INFO=$(lspci | grep -i vga | cut -d":" -f3)
    gpu="${red}GPU:${reset} $GPU_INFO"
}


get_host() {
    length=$((width * 2))
    FHOST="$USER@$HOSTNAME"
    hostlength=${#FHOST}
    center=$(((length - hostlength) / 2)) # epic centering magic
    space=$(yes " " | head -n $center | tr -d '\n')
}

get_disk() {
    disk_i=$(df -h | awk '$NF=="/"{printf "%s / %s (%s used)", $3,$2,$5}')
    disk_info="${red}Disk:${reset} $disk_i"
}

ip_config() {
    pr_ip=$(hostname -I | awk '{print $1}')
    pu_ip=$(curl -s ifconfig.me)
    private_ip="${red}Private IP:${reset} $pr_ip"
    public_ip="${red}Public IP:${reset} $pu_ip"
}

compare_size() {
    max_length=0
    FHOST2="$USER@$HOSTNAME"
    # Iterate through the strings
    for str in "$display_info" "$de_info" "$public_ip" "$private_ip" "$FHOST2" "$os" "$kernal" "$cpu" "$gpu" "$mem" "$swp" "$up" "$disk_info"; do

        # Calculate the length of the current string
        length=${#str}

        # Compare the length with the current maximum length
        if (( length > max_length )); then
            max_length=$length
        fi
    done

    width=$(($max_length / 2))

    if [[ $width =~ ^[0-9]+$ ]]; then
        if !(( $width % 2 == 0 )); then
            (( width++ ))
        fi
    fi

    widthprint=$(yes "─" | head -n $width | tr -d '\n')
}

get_display_manager() {
    display_info="${red}DM:${reset} $XDG_SESSION_TYPE"
}

# Function to get desktop environment
get_desktop_environment() {
    de_info="${red}DE:${reset} $XDG_CURRENT_DESKTOP"
}

print_color_box() {
    echo -ne "\e[48;5;$1m    \e[0m"
}

# Function to print color boxes in two columns
print_color_boxes() {
    local colors=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)
    local num_colors=${#colors[@]}
    local row_colors=8

    for ((i=0; i<$num_colors; i+=row_colors)); do
        local row=""
        for ((j=0; j<row_colors; j++)); do
            local index=$((i + j))
            if [ $index -lt $num_colors ]; then
                row+=$(print_color_box "${colors[$index]}")
            fi
        done
        echo -e "$row"
    done
}

# Function to display system information
show_system_info() {
    echo -e " ${blue}┌${widthprint}⊙${widthprint}┐${reset}"
    echo -e "   ${blue}$(tput bold)$(tput setaf 4)$space${red}$FHOST${blue}$(tput sgr0)${reset}"
    echo -e " ${blue}└${widthprint}⊙${widthprint}┘${reset}"
    echo -e " ${blue}┌${widthprint}⊙${widthprint}┐${reset}"
    echo -e " $os"
    echo -e " $kernal"
    echo -e " $up"
    echo -e " $display_info"
    echo -e " $de_info"
    echo -e " $cpu"
    echo -e " $gpu"
    echo -e " $mem"
    echo -e " $swp"
    echo -e " $disk_info"
    echo -e " $private_ip"
    echo -e " $public_ip"
    echo -e " ${blue}└${widthprint}⊙${widthprint}┘${reset}"  # i think we are echoing stuff
    print_color_boxes
}


# Make it work
get_distribution
get_cpu_info
get_memory_info
get_kernel_version
get_uptime
get_gpu
get_disk
ip_config
get_display_manager
get_desktop_environment
compare_size
get_host
show_system_info

