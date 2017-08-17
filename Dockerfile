FROM jboss/base-jdk:8

ENV SSO rh-sso-7.1.0.zip
ENV SSO_PATCH rh-sso-7.1.2-patch.zip
ENV SSO_INSTALLS_URL https://www.dropbox.com/sh/6nd9w26h8i9q7kj/AAAGl75-MEWpOtBP0OMH_6Qfa/rh-sso-7.1.0.zip?dl=1
ENV SSO_PATCH_INSTALLS_URL https://www.dropbox.com/sh/6nd9w26h8i9q7kj/AAAdhD63_exVOHSXmPPBE8lsa/rh-sso-7.1.2-patch.zip?dl=1
ENV JBOSS_HOME /opt/jboss/rh-sso-7.1
ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV PROXY_ADDRESS_FORWARDING false

USER root
COPY support/start.sh /opt/jboss/
RUN chmod +x /opt/jboss/start.sh

USER jboss

RUN curl -O -J -L $SSO_INSTALLS_URL \
    && curl -O -J -L $SSO_PATCH_INSTALLS_URL \
    && unzip -qo /opt/jboss/$SSO \
    && cd ~/rh-sso-7.1/bin && ./jboss-cli.sh --command="patch apply ../../rh-sso-7.1.2-patch.zip" \
    && rm -rf ~/$SSO ~/$SSO_PATCH

COPY support/setLogLevel.xsl /opt/jboss/rh-sso-7.1/

RUN /opt/jboss/rh-sso-7.1/bin/add-user-keycloak.sh --user admin --password ancine1!

RUN java -jar /usr/share/java/saxon.jar -s:/opt/jboss/rh-sso-7.1/standalone/configuration/standalone.xml -xsl:/opt/jboss/rh-sso-7.1/setLogLevel.xsl -o:/opt/jboss/rh-sso-7.1/standalone/configuration/standalone.xml


#Enabling Proxy address forwarding so we can correctly handle SSL termination in front ends such as an OpenShift Router or Apache Proxy
RUN sed -i -e 's/<http-listener /& proxy-address-forwarding="${env.PROXY_ADDRESS_FORWARDING}" /' $JBOSS_HOME/standalone/configuration/standalone.xml
RUN sed -i -e 's/<https-listener /& proxy-address-forwarding="${env.PROXY_ADDRESS_FORWARDING}" /' $JBOSS_HOME/standalone/configuration/standalone.xml

EXPOSE 8080 8443 

CMD ["/opt/jboss/start.sh"]