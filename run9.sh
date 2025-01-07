#!/bin/sh

if ! [ -f $HOME/Linux_env/.zshrc ]; then
  echo -e "Please git clone into $HOME before running run.sh\n"
  exit
fi

if ! [ -f /usr/bin/nvim ]; then
  sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms # RHEL
  sudo dnf config-manager --set-enabled ol9_codeready_builder # Oracle
  sudo dnf config-manager --set-enabled crb # Rocky
  sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm # RHEL
  sudo dnf -y install oracle-epel-release-el9 # Oracle
  sudo dnf -y install epel-release # Rocky
  sudo dnf -y group install "Development Tools"
fi

sudo dnf -y install gcc-c++ zsh lua lua-devel npm tmux wget ninja-build cmake # for neovim
wget https://luarocks.org/releases/luarocks-3.11.1.tar.gz
tar zxpf luarocks-3.11.1.tar.gz
cd luarocks-3.11.1
./configure && make && sudo make install
cd ../
rm -rf luarocks*

git clone https://github.com/neovim/neovim
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.local"
make install

rm ~/.zshrc
mv Linux_env/.zshrc .

cat << 'EOF' >> ~/.zshrc

# ---- FZF -----
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

EOF

sudo dnf copr enable tkbcopr/fd -y
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit fd -y

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

alias ls='eza'
EOF

# https://github.com/sxyazi/yazi
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup update
cargo install --locked --git https://github.com/sxyazi/yazi.git yazi-fm yazi-cli

cargo install eza

cat << 'EOF' >> ~/.zshrc

alias ls='eza'
EOF

cat << 'EOF' >> ~/.zshrc

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
EOF

cd $HOME
rm -rf .config
mv Linux_env/.config .
mv Linux_env/.tmux.conf .
echo -e "### Type exit after the oh-my-zsh install script finishes, to complete setup ###\n"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

rm -rf Linux_env

echo "run source ~/.zshrc or re-login\n"
