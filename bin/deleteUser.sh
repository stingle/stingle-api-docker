#!/bin/bash
bin/dockerExec.sh "/var/www/html/cgi.php module=v2 page=tools subpage=deleteUser $@"