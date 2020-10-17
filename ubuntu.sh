#!/bin/bash -e
#Ubuntu 20.04.1 LTS

#workdir
cd /home/${USER}/Downloads

#add user to sudoers
sudo grep "${USER} ALL=(ALL) NOPASSWD:ALL" /etc/sudoers || sudo sh -c "echo \"${USER} ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"

#update of repos and upgrade of programs + installation of basic programs
echo "apt update running" && sudo apt update -y -qq
sudo apt upgrade -y -qq
sudo apt install vim vim-gtk3 tmux git git-lfs ssh ansible xclip -y
sudo apt-mark manual libfprint-2-tod1 #in the future it may not be necessary anymore

#chrome
wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt install -f -y
sudo rm -f google-chrome-stable_current_amd64.deb

#docker
sudo apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
echo "apt update running" && sudo apt update -qq
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker ${USER}

#docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#kubectl
sudo curl -L "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
sudo chmod +x /usr/local/bin/kubectl
sudo grep "kubectl completion bash" ~/.bashrc || echo "source <(kubectl completion bash)" >> ~/.bashrc
sudo grep "alias k=kubectl" ~/.bashrc || echo "alias k=kubectl" >> ~/.bashrc
sudo grep "complete -F __start_kubectl k" ~/.bashrc || echo "complete -F __start_kubectl k" >> ~/.bashrc
sudo grep "dr=\"--dry-run=client -o yaml\"" ~/.bashrc || echo "dr=\"--dry-run=client -o yaml\"" >> ~/.bashrc

#kind
sudo curl -L https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64 -o /usr/local/bin/kind
sudo chmod +x /usr/local/bin/kind

#helm
sudo curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
echo "apt update running" && sudo apt update -qq
sudo apt install helm

#aws cli
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -qq awscliv2.zip
sudo ./aws/install
sudo rm -rf aws awscliv2.zip

#aws authenticator
sudo curl -L https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator
sudo chmod +x /usr/local/bin/aws-iam-authenticator

#terraform
sudo curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
echo "apt update running" && sudo apt update -qq
sudo apt install terraform -y

#vscode
wget -nv -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo rm -f packages.microsoft.gpg
echo "apt update running" && sudo apt update -qq
sudo apt install code

#stop and disable cups auto start, prevent port 631 to be opened on listening mode
sudo systemctl disable cups
sudo systemctl stop cups

#cid to join domain
#sudo add-apt-repository ppa:emoraes25/cid -y
#echo "apt update running" && sudo apt update -qq
#sudo apt install cid -y
#echo -e "\nJoin domain: sudo cid join domain=x user=x pass=x"

#vim config to use gvim to have +xclipboard enabled
grep 'gvim -v' /home/${USER}/.bashrc || echo -e "\nalias vim='gvim -v'" >> /home/${USER}/.bashrc

#favorite apps in gnome dash-to-dock
gsettings set org.gnome.shell favorite-apps "['google-chrome.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'code.desktop']"

#disable events-sounds like sounds when pressing keys on terminal
gsettings set org.gnome.desktop.sound event-sounds false
gsettings set org.gnome.desktop.sound input-feedback-sounds false

#gedit settings
gsettings set org.gnome.gedit.preferences.editor scheme cobalt

#gnome dark theme
gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark

#shortcut super+e open home folder
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"

#set terminal font to monospace size 14 for default profile
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default|tr -d \')/ use-system-font false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default|tr -d \')/ font 'Monospace 14'

#one click to open folders on nautilus file manager
gsettings set org.gnome.nautilus.preferences click-policy 'single'

#disable mouse+touchpad natural scrolling
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false

#config dash-to-dock
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 50
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'

#disable desktop icons
gsettings set org.gnome.shell.extensions.desktop-icons show-home false
gsettings set org.gnome.shell.extensions.desktop-icons show-trash false

#enable gnome hot corner
gsettings set org.gnome.desktop.interface enable-hot-corners true

#change privacy options
gsettings set org.gnome.desktop.privacy remember-recent-files false
gsettings set org.gnome.desktop.privacy send-software-usage-stats false
gsettings set org.gnome.desktop.privacy report-technical-problems false

#disable desktop folder on nautilus left panel and desktop usage
gsettings set org.gnome.desktop.background show-desktop-icons false

#keep just wanted folders on the nautilus left panel
cat <<EOF > ~/.config/user-dirs.dirs 
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_DOCUMENTS_DIR="$HOME/Documents"
EOF

#keep just wanted folders on the nautilus left panel
sudo bash -c 'cat > /etc/xdg/user-dirs.defaults' << EOF
DOWNLOAD=Downloads
DOCUMENTS=Documents
EOF

#delete not wanted folders on /home/${USER}/
rm -rf "/home/${USER}/Music"
rm -rf "/home/${USER}/Templates"
rm -rf "/home/${USER}/Public"
rm -rf "/home/${USER}/Videos"
rm -rf "/home/${USER}/Pictures"
rm -rf "/home/${USER}/Desktop"

#.vimrc
cat <<EOF > /home/${USER}/.vimrc
set nocompatible   "Disable compatible mode with vi
set ttyfast        "Rendering fast
set showmode       "Show mode = Insert, Normal, Visual
set showcmd        "Show commands you are typing
set number         "Show line number
set noswapfile     "No swap file
set tabstop=2      "Tab to space 2 spaces
set shiftwidth=2   "Tab to space 2 spaces
set expandtab      "Tab to space 2 spaces
set autoindent     "Copy indent from current line when starting a new one
set encoding=utf-8 "Encoding
syntax on          "Turn on syntax highlighting
set clipboard^=unnamed,unnamedplus "Enable global copy/paste
EOF

#.tmux.conf
cat <<EOF > /home/${USER}/.tmux.conf
unbind C-b                 #delete prefix ctrl+b
set -g prefix C-a          #create new prefix with ctrl+a
bind-key C-a send-prefix   #press ctrl+a to send prefix
set -g allow-rename off    #disable auto rename of windows
set -g base-index 1        #start count windows at 1
set -g pane-base-index 1   #start count pane at 1
set -g history-limit 90000 #increase the buffer 
bind h select-pane -L      #<prefix> h to switch focus to left pane
bind j select-pane -D      #<prefix> j to switch focus to down pane
bind k select-pane -U      #<prefix> k to switch focus to up pane
bind l select-pane -R      #<prefix> l to switch focus to right pane
bind s split-window -v     #<prefix> s for horizontal split
bind v split-window -h     #<prefix> v for vertical split
setw -g mode-keys vi       #enable vi mode, copy to sys clip <prefix>[vy
bind -T copy-mode-vi v send-keys -X begin-selection  #enable selection with v
bind -T copy-mode-vi r send-keys -X rectangle-toggle #rectangle toggle with r
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -se c -i'
EOF

#create gitlab config
ssh-keygen -t rsa -b 2048 -q -N "" -C "automated" -f /home/${USER}/.ssh/gitlab_automated
chmod 600 /home/${USER}/.ssh/gitlab_automated
if [[ ! -f ~/.ssh/config ]]; then
  cat <<EOF > /home/${USER}/.ssh/config 
Host gitserver.xxxxxxxxxx.local
  Preferredauthentications publickey
  IdentityFile ~/.ssh/gitlab_automated

Host gitsoft.xxxxxxxxxx.com
  Port 221
  Preferredauthentications publickey
  IdentityFile ~/.ssh/gitlab_automated
EOF
fi
echo -e "\nADD THAT PUB KEY ON GITLAB:"
cat /home/${USER}/.ssh/gitlab_automated.pub
