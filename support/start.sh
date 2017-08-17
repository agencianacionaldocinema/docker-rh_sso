#!/bin/bash
EXTRA_PARAMS=$@
if [ -f /opt/jboss/ancine-realm.json ] ; then
  echo Realm import file found, starting creation of realm, roles, users and clients.
  /opt/jboss/rh-sso-7.1/bin/standalone.sh -c standalone.xml -b 0.0.0.0 -bmanagement 0.0.0.0 -Dkeycloak.migration.action=import -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.file=/opt/jboss/ancine-realm.json -Dkeycloak.migration.strategy=IGNORE_EXISTING $EXTRA_PARAMS
else
  /opt/jboss/rh-sso-7.1/bin/standalone.sh -c standalone.xml -b 0.0.0.0 -bmanagement 0.0.0.0 $EXTRA_PARAMS
fi

