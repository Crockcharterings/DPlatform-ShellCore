#!/bin/sh

if [ $1 = update ]
then
  cd /home/laverna/static-laverna
  git pull
  whiptail --msgbox "Laverna updated!" 8 32
  break
fi
[ $1 = remove ] && userdel -r laverna && whiptail --msgbox && (rm /etc/nginx/sites-*/laverna; systemctl nginx restart) && "Laverna removed!" 8 32 && break

# Define port
whiptail --title "Laverna port" --clear --inputbox "Enter a port number for Laverna. default:[8007]" 8 32 2> /tmp/temp
read port < /tmp/temp
port=${port:-8007}

# Install unzip if not installed
hash unzip 2>/dev/null || $install unzip

# Add Laverna user
useradd -m laverna

# Go to its directory
cd /home/laverna

#  Clone the prebuilt static version
git clone https://github.com/Laverna/static-laverna

# Change the owner from root to git
chown -R laverna:laverna /home/laverna/static-laverna

# Create Nginx configuration file
cat > /etc/nginx/sites-available/laverna <<EOF
server  {
    listen $port;
    root /home/laverna/static-laverna;
    index index.html;
    server_name \$hostname;
    error_log /var/log/nginx/laverna.log warn;
    access_log /var/log/nginx/laverna.log combined;
        location ~* \.(jpg|jpeg|gif|css|png|js|ico|html)$ {
          access_log off;
          expires max;
        }
        location ~ /\.ht {
          deny all;
        }
}
EOF

# Symlink sites-enabled to sites-available
ln -s /etc/nginx/sites-available/laverna /etc/nginx/sites-enabled/laverna

# Deelete the default nginx server block
rm /etc/nginx/sites-enabled/default
# Reload Nginx
systemctl nginx restart

whiptail --msgbox "Laverna installed!

Open http://$IP:$port in your browser" 12 48
