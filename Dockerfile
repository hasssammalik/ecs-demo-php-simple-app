FROM 673536892860.dkr.ecr.ap-southeast-2.amazonaws.com/android-test-2:base

# Setup NewRelic
RUN apt-get install apt-transport-https
RUN echo "license_key: 3aa24f89edd3803af1b24d5ce51c44b2bb2af136" |  tee -a /etc/newrelic-infra.yml
RUN echo "display_name: Android CI/CD" >> /etc/newrelic-infra.yml
RUN curl https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg |  apt-key add -
RUN echo "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt trusty main" | tee -a /etc/apt/sources.list.d/newrelic-infra.list
RUN apt-get update -y
RUN apt-get install newrelic-infra -y

# Setup Apache2
RUN rm -rf /var/www/html
RUN git clone https://github.com/sevennetwork/7live-android /var/www/html
WORKDIR /var/www/html/
RUN git checkout develop
RUN pwd
RUN chmod 777 gradlew

# Setup security
RUN cp /security/release_keystore.properties /var/www/html/
RUN chmod 400 release_keystore.properties
RUN cp /security/mediafoundry.keystore /var/www/html/app/
RUN chmod 400 /var/www/html/app/mediafoundry.keystore

# Setup tests and build
RUN ./gradlew clean testSeventennisReleaseUnitTest --no-daemon
RUN ./gradlew assembleSeventennisRelease --no-daemon --stacktrace --debug
RUN cp -r /var/www/html/app/build/reports/tests/seventennisRelease /var/www/html/

# Support Gradle
ENV TERM dumb

# Expose Apache2
EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

#tesasdasdasd t