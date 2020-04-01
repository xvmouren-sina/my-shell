#!/bin/bash
appdir=/app
catalina_base=/usr/local/tomcat
webapp=webapps
cp $appdir/target/*.war $catalina_base/$webapp
$catalina_base/bin/shutdown.sh
sleep 5
$catalina_base/bin/startup.sh


