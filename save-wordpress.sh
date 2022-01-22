#!/bin/bash

# variables
ftpsite="srvftp"
ftpuser="didier"
ftppass="pass"
ftpdir="/backups/"
wppath="/var/www/"
wpfolder="domain.com"
nullfolder="/tmp/null"

# supprimer les vieilles sauvegarde de plus de 5 jours
find $ftpdir* -type d -mtime +2 -exec rm -rdf {} \;

# Si déjà sauvegardé aujourd'hui on sort
if [ -d "$ftpdir"wordpress-$(date +"%d-%m-%Y")"" ]; then
  echo "bye"
  else

  # creation  du dossier local recevant les backups
  mkdir -v $ftpdir"wordpress-$(date +"%d-%m-%Y")"
  # creation  du dossier recevant les dump de la base mysql dans l'arborescence du site Wordpress
  mkdir -v $wppath$wpfolder$ftpdir"wordpress-$(date +"%d-%m-%Y")"
  # Dump de la base Wordpress 
  mysqldump -u root -pS@ral0me --databases wordpress --skip-dump-date --ignore-table=mysql.event --single-transaction --quick --add-drop-table > $wppath$wpfolder$ftpdir"wordpress-$(date +"%d-%m-%Y")"/save-wordpress-sql.dump
  # Tar compressé de l'arborescence du site Wordpress qui contient aussi le Dump SQL
  cd $wppath
  tar -v -cpPzf $ftpdir"wordpress-$(date +"%d-%m-%Y")"/WordpressBackup.$(date +"%Y-%m-%d").tar.gz $wpfolder/
# transfert en FTP du fichier tar vers le serveur FTP
lftp -u $ftpuser,$ftppass $ftpsite << EOF
cd $ftpdir
put $ftpdir"wordpress-$(date +"%d-%m-%Y")"/WordpressBackup.$(date +"%Y-%m-%d").tar.gz
EOF

fi
# clear
echo "fin du script"
