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

sudo dnf -y install gcc-c++ luarocks zsh npm tmux wget ninja-build cmake # for neovim
git clone https://github.com/neovim/neovim
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.local"
make install

# https://github.com/sxyazi/yazi
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup update
cargo install --locked --git https://github.com/sxyazi/yazi.git yazi-fm yazi-cli

cd $HOME
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
