
#!/bin/bash
sudo yum update -y
sudo yum dist-upgrade -y
sudo yum install git -y
# Create our file to check for in future
#echo "installed git!" >> /home/ec2-user/installed-git.txt
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node
node -e "console.log('Running Node.js ' + process.version)"
mkdir server && cd server
npm install express
