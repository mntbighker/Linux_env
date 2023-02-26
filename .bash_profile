# bash_profile

# Load .profile, containing login, non-bash related initializations.
if [ -f ~/.profile ]; then
    source ~/.profile
fi

# Load .bashrc, containing non-login related bash initializations.
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin:$HOME/local/bin

export PATH
