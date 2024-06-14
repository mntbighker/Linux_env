#!/bin/sh

if ! [ -f $HOME/Linux_env/.tmux.conf ]; then
  echo -e "Please git clone into $HOME before running run.sh\n"
  exit
fi

cd $HOME
wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz
mkdir -p ~/.local/bin
mv eza ~/.local/bin/
rm -f ~/.zcompdump*; compinit
git clone https://github.com/eza-community/eza.git $HOME/.local/eza
cat << 'EOF' >> ~/.zshrc

# Eza
export FPATH="$HOME/.local/eza/completions/zsh:$FPATH"' >> ~/.zshrc
EOF

rm -rf .config
mv Linux_env/.config .
mv Linux_env/.tmux.conf .
echo -e "### Type exit after the oh-my-zsh install script finishes, to complete setup ###\n"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

rm ./.zshrc
mv Linux_env/.zshrc .
rm -rf Linux_env

# sudo dnf -y config-manager --set-enabled ol8_appstream # Oracle
# sudo dnf -y install epel-release-el8 # Oracle
sudo dnf -y install epel-release # RHEL
sudo crb enable # RHEL
sudo dnf -y group install "Development Tools"
sudo dnf -y install gcc-c++ luarocks zsh npm tmux wget ninja-build cmake # for neovim
git clone https://github.com/neovim/neovim
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.local"
make install

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin
rm -rf ~/.fzf/

cat << 'EOF' >> ~/.zshrc

# ---- FZF -----
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

EOF

dnf copr enable tkbcopr/fd
dnf install fd

cat << 'EOF' >> ~/.zshrc

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

EOF

cat << 'EOF' >> ~/.zshrc

# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

EOF

curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
# https://github.com/nanotee/zoxide
cat << 'EOF' >> ~/.zshrc

eval "$(zoxide init zsh --cmd cd)"
EOF

echo "run source ~/.zshrc or re-login\n"
