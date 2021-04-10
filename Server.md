The server is Debian Jessie and sadly libjq-dev is not available there, instead we can manually newer js libs:

```
wget http://security.debian.org/debian-security/pool/updates/main/libo/libonig/libonig4_6.1.3-2+deb9u2_amd64.deb
wget http://ftp.uk.debian.org/debian/pool/main/j/jq/libjq1_1.5+dfsg-1.3_amd64.deb
wget http://ftp.uk.debian.org/debian/pool/main/j/jq/libjq-dev_1.5+dfsg-1.3_amd64.deb
```

and install them with `dpkg -i`.
Then in R we can install the required packages:
```bash
R -e 'install.packages(c('googleway', 'RPostgres', 'DBI', 'jsonlite'), repos='https://cran.rstudio.com/')"
```
NOTE there was an issue with googlePolylines so might need to follow instructions on [issue](https://github.com/SymbolixAU/googlePolylines/issues/50)

Then add to the crontab

```
0 6,7,7.5,8,8.5,9,9.5,10,11,12,13,14,15,15.5,16,16.5,17,17.5,18,18.5,19,20,21 * * * cd  /home/git/code/ata-traffic-recorder && /usr/bin/Rscript ./store_directions.R >> /var/log/ata-traffic-recorder.log 2>&1
```

## Git

```
apt install git-core
useradd git
```

as git user create ata-traffic-recorder:
```bash
su git
cd /home/$USER
mkdir ata-traffic-recorder
cd ata-traffic-recorder
git init --bare
cp hooks/post-update.sample hooks/post-update
sed -i 's/^exec //' hooks/post-update
echo 'echo `git --git-dir /home/git/ata-traffic-recorder --work-tree /home/git/code/ata-traffic-recorder checkout main -f`' >> hooks/post-update
mkdir -p code/ata-traffic-recorder
mkdir .ssh
touch .ssh/authorized_keys
chmod 700 .ssh
chmod 644 .ssh/authorized_keys
# add ssh keys
chmod go-w .
```
