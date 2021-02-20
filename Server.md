wget http://security.debian.org/debian-security/pool/updates/main/libo/libonig/libonig4_6.1.3-2+deb9u2_amd64.deb
wget http://ftp.uk.debian.org/debian/pool/main/j/jq/libjq1_1.5+dfsg-1.3_amd64.deb
wget http://ftp.uk.debian.org/debian/pool/main/j/jq/libjq-dev_1.5+dfsg-1.3_amd64.deb

and install them with dpkg -i

follow instructions on
https://github.com/SymbolixAU/googlePolylines/issues/50

```
apt install git-core
useradd git
```

as git user create ltn-traffic-recorder:
```bash
su git
cd /home/$USER
mkdir ltn-traffic-recorder
mkdir -p code/ltn-traffic-recorder
mkdir .ssh
touch .ssh/authorized_keys
chmod 700 .ssh
chmod 644 .ssh/authorized_keys
# add ssh keys
chmod go-w .
```
