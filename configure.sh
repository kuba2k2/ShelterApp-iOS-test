#configure.sh VNC_USER_PASSWORD VNC_PASSWORD FRP_SERVER

#disable spotlight indexing
sudo mdutil -i off -a

#Create new account
sudo dscl . -create /Users/vncuser
sudo dscl . -create /Users/vncuser UserShell /bin/bash
sudo dscl . -create /Users/vncuser RealName "VNC User"
sudo dscl . -create /Users/vncuser UniqueID 1001
sudo dscl . -create /Users/vncuser PrimaryGroupID 80
sudo dscl . -create /Users/vncuser NFSHomeDirectory /Users/vncuser
sudo dscl . -passwd /Users/vncuser $1
sudo dscl . -passwd /Users/vncuser $1
sudo createhomedir -c -u vncuser > /dev/null

sudo sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' "INSERT INTO access VALUES('kTCCServicePostEvent','com.apple.screensharing.agent',0,2,4,1,NULL,NULL,0,'UNUSED',NULL,0,1639743960,NULL,NULL,'UNUSED',1764130243);"
sudo sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' "INSERT INTO access VALUES('kTCCServiceScreenCapture','com.apple.screensharing.agent',0,2,4,1,NULL,NULL,0,'UNUSED',NULL,0,1639743960,NULL,NULL,'UNUSED',1764130243);"

#Enable VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes 

#VNC password - http://hints.macworld.com/article.php?story=20071103011608872
echo $2 | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

#Start VNC/reset changes
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate

#install frp
brew install frpc

#configure frpc and start it
frpc tcp -n rdp -s $3 -P 7000 -l 5900 -r 7001 &
