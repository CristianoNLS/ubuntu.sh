#!/bin/bash -e
#Ubuntu 20.04.1 LTS

#workdir
cd /home/${USER}/Downloads

#add user to sudoers
sudo grep -q "${USER} ALL=(ALL) NOPASSWD:ALL" /etc/sudoers || sudo sh -c "echo \"${USER} ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"

#ask for user inputs to do git configurations
echo "What's your name? It's going to be used to configure git username in ~/.gitconfig"
read gituser
echo "What's your email? It's going to be used to configure git email in ~/.gitconfig"
read gitemail

#update of repos and upgrade of programs + installation of basic programs
sudo apt update -qq && sudo apt upgrade -qq -y
sudo apt install vim vim-gtk3 tmux git git-lfs ssh ansible xclip nodejs npm \
                 apt-transport-https ca-certificates curl wget gnupg-agent software-properties-common -qq -y

#chrome
wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt install -f -qq -y
sudo rm -f google-chrome-stable_current_amd64.deb

#docker
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -u "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt install docker-ce docker-ce-cli containerd.io -qq -y
sudo usermod -aG docker ${USER}

#docker compose
sudo curl -sSL "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#kubectl
sudo curl -sSL "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
sudo chmod +x /usr/local/bin/kubectl
sudo grep -q "kubectl completion bash" ~/.bashrc || echo -e "\nsource <(kubectl completion bash)" >> ~/.bashrc
sudo grep -q "alias k=kubectl" ~/.bashrc || echo "alias k=kubectl" >> ~/.bashrc
sudo grep -q "complete -F __start_kubectl k" ~/.bashrc || echo "complete -F __start_kubectl k" >> ~/.bashrc
sudo grep -q "dr=\"--dry-run=client -o yaml\"" ~/.bashrc || echo "dr=\"--dry-run=client -o yaml\"" >> ~/.bashrc

#kind
sudo curl -sSL https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64 -o /usr/local/bin/kind
sudo chmod +x /usr/local/bin/kind

#helm
sudo curl -sS https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo add-apt-repository -u "deb https://baltocdn.com/helm/stable/debian/ all main"
sudo apt install helm -qq -y

#aws cli
sudo curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
rm -rf aws && unzip -qq awscliv2.zip
sudo ./aws/install -u
sudo rm -rf aws awscliv2.zip

#aws authenticator
sudo curl -sSL https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator
sudo chmod +x /usr/local/bin/aws-iam-authenticator

#terraform
sudo curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo add-apt-repository -u "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install terraform -qq -y

#vscode
wget -nv -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository -u "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt install code -qq -y

#git config
git config --global user.name "$gituser"
git config --global user.email "$gitemail"

#create git hosts config to work with pub/pvt key + git clone via ssh
if [[ ! -f ~/.ssh/config ]]; then
  cat <<EOF > /home/${USER}/.ssh/config
Host github.com
  Preferredauthentications publickey
  IdentityFile ~/.ssh/automated
Host gitlab.com
  Preferredauthentications publickey
  IdentityFile ~/.ssh/automated
Host gitserver.xxxxxxxxxx.local
  Preferredauthentications publickey
  IdentityFile ~/.ssh/automated
Host gitsoft.xxxxxxxxxx.com
  Port 221
  Preferredauthentications publickey
  IdentityFile ~/.ssh/automated
EOF
fi
test -f /home/${USER}/.ssh/automated || ssh-keygen -t rsa -b 2048 -q -N "" -C "automated" -f /home/${USER}/.ssh/automated
chmod 600 /home/${USER}/.ssh/automated

### PERSONAL CONFIGURATIONS BELOW, REMOVE IF YOU DON'T WANT ALL THAT STUFF

#stop and disable cups auto start, prevent port 631 to be opened on listening mode
sudo systemctl disable cups
sudo systemctl stop cups

#vim config to use gvim to have +xclipboard enabled
grep -q 'gvim -v' /home/${USER}/.bashrc || echo "alias vim='gvim -v'" >> /home/${USER}/.bashrc

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
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default|tr -d \')/ font 'Monospace 13'

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
bind e setw synchronize-panes #<prefix> e to turn on/off sync panes
set -g mouse on #turn on mouse
EOF

#configure 120Hz for monitor, https://wiki.archlinux.org/index.php/xrandr#Adding_undetected_resolutions
sudo mkdir -p /etc/X11/xorg.conf.d/
sudo bash -c 'cat > /etc/X11/xorg.conf.d/10-monitor.conf' << EOF
Section "Monitor"
    Identifier "eDP-1-1"
    Modeline "1920x1080_120.00"  369.50  1920 2080 2288 2656  1080 1083 1088 1160 -hsync +vsync
    Option "PreferredMode" "1920x1080_120.00"
    Option "Primary" "true"
EndSection
Section "Screen"
    Identifier "Screen0"
    Monitor "eDP-1-1"
    DefaultDepth 24
    SubSection "Display"
        Modes "1920x1080_120.00"
    EndSubSection
EndSection
EOF
rm -rf ~/.config/monitors.xml #gnome display conf file, sometimes override the /etc/X11/xorg.conf.d/10-monitor.conf settings
gsettings set org.gnome.settings-daemon.plugins.xrandr active false

#Workaround to fix laggy when adjusting fn+volumeup/down or fn+brightnessup/down
sudo sed -i 's/ modifier_map Mod3   { Scroll_Lock };/ #modifier_map Mod3   { Scroll_Lock };/' /usr/share/X11/xkb/symbols/br
