#!/bin/bash

# ijustscriptedyourjob.sh
# https://github.com/kylebrewer/ijustscriptedyourjob
# Author: Kyle Brewer
# Purpose: Confirm git is installed and clone a git repository on OS X clients.

# We need to execute as root to get some of this done.
# If the executing user is not root, the script will exit with code 1.
if [ "$USER" != "root" ]; then
        echo "You are attempting to execute this process as user $USER"
        echo "Please execute the script with elevated permissions."
        exit 1
fi

# Look for existing instance(s) of git, and choose the first one.
gitbinpath=$(/usr/bin/which git | /usr/bin/head -n 1)
# Path to local git clone.
clonepath=""
# Git repo username.
repousername=""
# Git repo URL.
repourl=""
# Target for enterprise network ping test. An Active Directory server, for example. 
pingtarget=""


# Functions

function install_clt()
{
        # Install Apple's Command Line Tools package to get Git.
        # Prepare Software Update to request Command Line Tools package.
        /usr/bin/touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

        # Scan available packages for Command Line Tools.
        cltpkg=$(/usr/sbin/softwareupdate -l | /usr/bin/grep "\*.*Command Line" | /usr/bin/head -n 1 | /usr/bin/awk -F"*" '{print $2}' | /usr/bin/sed -e 's/^ *//' | /usr/bin/tr -d '\n')

        # Install only Command Line Tools.
        /usr/sbin/softwareupdate -i "$cltpkg"
}

function git_pull()
{
        # First, confirm that our repo clone's .git file exists.
        if [ -d "$clonepath"/.git ]; then
                # Repo clone .git exists. Pull any changes from the repo.
                cd "$clonepath" && "$gitbinpath" pull
        else
                # Repo clone .git does not exist. We need to rebuild the local catalog.
                # Remove any potential garbage first. Scorched earth and all that.
                /bin/rm -rf "$clonepath"
                # Now remake repo clone path, and clone the repo. Cloning will create .git/.
                /bin/mkdir -p "$clonepath"
                "$gitbinpath" clone "$repousername"@"$repourl" "$clonepath"
        fi
}


# Main

# First, we'll make sure we're within the enterprise network. Exit if outside.
/sbin/ping -q -c3 "$pingtarget" > /dev/null

# Evaluate ping response.
if [ $? -eq 0 ]; then
  # Response received. Continue with script.
  :
else
  # No response, outside of enterprise network. Exit with no changes.
  exit 0
fi

# Test for presence of git.
if [ "$gitpath" = "" ]; then
        # Git is not present. Run Command Line Tools install function.
        install_clt
else
        # Git is present. Clone/pull repo.
        git_pull
fi
