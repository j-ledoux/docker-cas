#!/bin/sh

DIR=$(dirname "$(readlink -f $0)")
container_name=common-auth-cas

http_port=$1
https_port=$2

if [ "$http_port" = "" ]; then
	http_port=8000
fi

if [ "$https_port" = "" ]; then
        https_port=8500
fi

if [ "$(ls -al  runtime/webapps/ | grep 'cas$')" = "" ]; then
	echo "Running first initialization of $container_name."
	docker run -d \
	--name $container_name \
	-v $DIR/runtime/webapps:/usr/local/tomcat7/webapps \
	-v $DIR/runtime/server.xml:/usr/local/tomcat7/conf/server.xml \
	tb4mmaggots/tomcat 
	sleep 60
	docker stop $container_name
	docker rm $container_name
	echo "$container_name initialization finished."
fi

if ["$(docker ps -a | grep common-auth-cas)" = ""]; then
	echo "Starting new CAS service $container_name."
	docker run -d \
	--name $container_name \
	-p "$http_port:8080"\
	-p "$https_port:8443" \
	-v $DIR/runtime/webapps:/usr/local/tomcat7/webapps \
	-v $DIR/runtime/create_keystore:/runtime/create_keystore \
	-v $DIR/runtime/server.xml:/usr/local/tomcat7/conf/server.xml \
	-v $DIR/runtime/pac4jContext.xml:/usr/local/tomcat7/webapps/cas/WEB-INF/spring-configuration/pac4jContext.xml \
	-v $DIR/runtime/cas.properties:/usr/local/tomcat7/webapps/cas/WEB-INF/cas.properties \
	tb4mmaggots/tomcat
else
echo "Starting existing CAS service $container_name."
	docker start $container_name
fi
