# /bin/bash
npm run build
rsync -avz -e "ssh -o 'ProxyCommand=nc -X 5 -x diode.ws %h %p'" --delete ./dist/ ubuntu@proxysettings.diode.link:/home/ubuntu/proxysettings/
