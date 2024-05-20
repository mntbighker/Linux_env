#!/bin/sh

if ! [ -f $HOME/Linux_env/.tmux.conf ]; then
  echo -e "Please git clone into $HOME before running run.sh\n"
  exit
fi

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

# sudo dnf -y config-manager --set-enabled ol8_appstream # Oracle
# sudo dnf -y install epel-release-el8 # Oracle
sudo dnf -y install epel-release # RHEL
sudo crb enable
sudo dnf -y install gcc gcc-c++ luarocks zsh npm tmux wget ninja-build cmake # for neovim
git clone --branch v0.9.0 https://github.com/neovim/neovim
cd neovim
make CMAKE_BUILD_TYPE=Release
make CMAKE_INSTALL_PREFIX=$HOME/.local install
