# Stingle API Server

## Prerequisites
* Debian, Ubuntu, RHEL, CentOS, Rocky, Fedora linux, MacOS or Windows WSL
* S3 compatible storage
* Domain name

## Intallation
```bash
./setup.sh
```
This will install docker if it's not present on the system and then start building docker image. After image is built it will start all necessary containers. When all containers are up it will start a setup process. Answer several questions and Stingle API server will be ready.

If you would like to participate in development or just build the stingle-api image yourself from sources, please refer to https://github.com/stingle/stingle-api project. 

`setup.sh` script will create config file in `configsSite` folder, named `config.override.inc.php`. Please backup `config.override.inc.php` in a safe place, in case you want to redeploy server later.

### Setup script
Let's say something is changed on the server and you want to modify your configuration. You can re-run setup script but partially:

```bash
./bin/setup-internal.sh
```
Possible options for the setup script
```
Setup script of Stingle API server
Usage:
--full                  Run full setup
--mysqlPass             MySQL password
--mysql                 MySQL setup
--systemKeys            Generate system keys
--storage               S3 storage configuration
--backup                Backup configuration
--hostname              Set a hostname
--backup-cron           Install cronjob for backups
--rm-backup-cron        Remove cronjob for backups
--update-addons-cron    Update cronjobs from addons
--rm-cron               Remove given addon's cron file
-h --help               Display this help message
```

## Backups
`setup.sh` will offer to enable backups for the instance. It is strongly advised to create a S3 compatible bucket in different region than your data container. Please don't forget to save backup kaypair and public key in a safe place, it will be needed to restore backup if you need to.

Backup will automatically dump MySQL database, archive it in .tar.gz format, then it will encrypt it with the public key (which matching private key is not present on a server and only server operator should have it). Then it will upload that encrypted blob to the configured S3 storage. In case of a config file leakage, nobody will be able to access the backups.

If you're deploying a new instance, and you already have a backup, you can automatically download, decrypt and restore it using `bin/restoreBackup.sh` script. Your backup configuration have to point to the S3 bucket where the existing backup is located, and you have to provide a backup filename (without any extensions) and a keypair to successfully restore it.

## Updates
To update your Stingle API server installation to the latest stable release run:
```bash
./bin/update.sh
```

## Accessing phpMyAdmin
By default, phpMyAdmin is running on the server, however it will respond only to calls from localhost. To access it from another machine, you will have to do port forwarding using ssh.
Just ssh to your server with the following command:

```bash
ssh -L 8800:127.0.0.1:8082 root@stingleapiserver.domain
```

Then access it from browser, by going to:
`http://localhost:8800/`

## Addons
If you have any addons present in `addons/` folder, then please change `COMPOSE_PARAMS` in `.env` file to:

```bash
COMPOSE_PARAMS="-f docker-compose.yml -f docker-compose-addons.yml"
```

After installing a new addon, typically you want to update the composer dependencies that new addon may bring. In that case please run:

```bash
./bin/composer.sh update
```

Composer is configured in such a way that it will automatically scan all folders in `addons/` folder and will find and merge all `composer.json` files.