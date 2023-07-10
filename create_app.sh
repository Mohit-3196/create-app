#!/bin/bash

# Script to create an application in Ant Media Server

# Function to display usage instructions
usage() {
  echo "Usage:"
  echo "$0 -n APPLICATION_NAME [-p INSTALLATION_PATH] [-w true|false] [-c true|false] [-m MONGO_HOST] [-u MONGO_USER] [-s MONGO_PASS] [-f WAR_FILE] [-r REDIS_HOST]"
  echo "Options:"
  echo "-n: Name of the application that you want to create. (Mandatory)"
  echo "-p: Path is the installation location of Ant Media Server. Default: /usr/local/antmedia"
  echo "-w: Flag to deploy the application as a war file. Default: false"
  echo "-c: Flag to deploy the application in cluster mode. Default: false"
  echo "-m: MongoDB host. Mandatory if in cluster mode, optional otherwise"
  echo "-u: MongoDB user. Mandatory if in cluster mode, optional otherwise"
  echo "-s: MongoDB password. Mandatory if in cluster mode, optional otherwise"
  echo "-f: War file path for custom app deployment"
  echo "-r: Redis host. Mandatory if in cluster mode, optional otherwise"
  echo "-pu: MongoDB port. Default: 27017"
  echo "-ps: Redis port. Default: 6379"
  echo "-h: Print this usage"
  echo " "
  echo "Example: "
  echo "$0 -n live -w"
  echo " "
  echo "If you have any questions, send an email to contact@antmedia.io"
}

# Print all parameters passed to the script
echo "All parameters: $@"

ERROR_MESSAGE="Error: Application creation failed. Please check the error in the terminal and refer to the instructions."

AMS_DIR=/usr/local/antmedia
AS_WAR=false
IS_CLUSTER=false
MONGO_PORT=27017
REDIS_PORT=6379

# Parse command-line options
while getopts 'n:p:w:h:c:m:u:s:f:r:pu:ps:' option; do
  case "${option}" in
    n) APP_NAME=${OPTARG} ;;
    p) AMS_DIR=${OPTARG} ;;
    w) AS_WAR=${OPTARG} ;;
    c) IS_CLUSTER=${OPTARG} ;;
    m) MONGO_HOST=${OPTARG} ;;
    u) MONGO_USER=${OPTARG} ;;
    s) MONGO_PASS=${OPTARG} ;;
    f) WAR_FILE=${OPTARG} ;;
    r) REDIS_HOST=${OPTARG} ;;
    pu) MONGO_PORT=${OPTARG} ;;
    ps) REDIS_PORT=${OPTARG} ;;
    h) usage
       exit 1 ;;
  esac
done

# Check if APPLICATION_NAME is provided as an argument
if [ -z "$APP_NAME" ]; then
  APP_NAME=$1

  if [ ! -z "$2" ]; then
    AMS_DIR=$2
  fi
fi

# Check if APPLICATION_NAME is still missing
if [[ -z "$APP_NAME" ]]; then
  echo "Error: Missing parameter APPLICATION_NAME. Check the instructions below."
  usage
  exit 1
fi

# Set the WAR file path if not provided
if [[ -z "$WAR_FILE" ]]; then
  WAR_FILE=$AMS_DIR/StreamApp*.war
fi

# Set AS_WAR flag to false if not provided
if [[ -z "$AS_WAR" ]]; then
  AS_WAR=false
fi

# Validate MongoDB cluster mode parameters if specified
if [[ "$IS_CLUSTER" == "true" ]]; then
  if [[ -z "$MONGO_HOST" ]]; then
    echo "Please set MongoDB host, username, and password for cluster mode."
    usage
    exit 1
  fi
fi

# Format the AMS_DIR path
case $AMS_DIR in
  /*) AMS_DIR=$AMS_DIR ;;
  *) AMS_DIR=$PWD/$AMS_DIR ;;
esac

APP_NAME_LOWER=$(echo $APP_NAME | awk '{print tolower($0)}')
APP_DIR=$AMS_DIR/webapps/$APP_NAME
RED5_PROPERTIES_FILE=$APP_DIR/WEB-INF/red5-web.properties
WEB_XML_FILE=$APP_DIR/WEB-INF/web.xml

# Create the application directory
mkdir $APP_DIR
#check_result

# Copy the WAR file to the application directory
echo $AMS_DIR
cp $WAR_FILE $APP_DIR
#check_result

cd $APP_DIR
#check_result

WAR_FILE_NAME=$(basename $WAR_FILE)

# Unzip the WAR file
unzip $WAR_FILE_NAME
#check_result

# Remove the WAR file
rm $WAR_FILE_NAME
#check_result

OS_NAME=$(uname)

if [[ "$OS_NAME" == 'Darwin' ]]; then
  SED_COMPATIBILITY='.bak'
fi

# Update MongoDB configuration in red5-web.properties
if [[ -n "$MONGO_HOST" ]]; then
  sed -i $SED_COMPATIBILITY 's#db.type=.*#db.type=mongodb#' $RED5_PROPERTIES_FILE
  sed -i $SED_COMPATIBILITY 's#db.host=.*#db.host='$MONGO_HOST':'$MONGO_PORT'#' $RED5_PROPERTIES_FILE
  sed -i $SED_COMPATIBILITY 's#db.user=.*#db.user='$MONGO_USER'#' $RED5_PROPERTIES_FILE
  sed -i $SED_COMPATIBILITY 's#db.password=.*#db.password='$MONGO_PASS'#' $RED5_PROPERTIES_FILE
fi

# Update Redis configuration in red5-web.properties
if [[ -n "$REDIS_HOST" ]]; then
  sed -i $SED_COMPATIBILITY 's#db.type=.*#db.type=redis#' $RED5_PROPERTIES_FILE
  sed -i $SED_COMPATIBILITY 's#db.host=.*#db.host='$REDIS_HOST':'$REDIS_PORT'#' $RED5_PROPERTIES_FILE
fi

# Update other properties in red5-web.properties
sed -i $SED_COMPATIBILITY 's#webapp.dbName=.*#webapp.dbName='$APP_NAME_LOWER'.db#' $RED5_PROPERTIES_FILE
sed -i $SED_COMPATIBILITY 's#webapp.contextPath=.*#webapp.contextPath=/'$APP_NAME'#' $RED5_PROPERTIES_FILE
sed -i $SED_COMPATIBILITY 's#db.app.name=.*#db.app.name='$APP_NAME'#' $RED5_PROPERTIES_FILE
sed -i $SED_COMPATIBILITY 's#db.name=.*#db.name='$APP_NAME_LOWER'#' $RED5_PROPERTIES_FILE

# Update display name and context path in web.xml
sed -i $SED_COMPATIBILITY 's#<display-name>StreamApp#<display-name>'$APP_NAME'#' $WEB_XML_FILE
sed -i $SED_COMPATIBILITY 's#<param-value>/StreamApp#<param-value>/'$APP_NAME'#' $WEB_XML_FILE

# Create a symbolic link for cluster mode
if [[ "$IS_CLUSTER" == "true" ]]; then
  ln -s $WAR_FILE $AMS_DIR/webapps/root/$APP_NAME.war
fi

# Perform additional operations based on AS_WAR flag
if [[ $AS_WAR == "true" ]]; then
  echo "Application will be deployed as a WAR file"
  cd $APP_DIR
  zip -r ../$APP_NAME.war *
  rm -r $APP_DIR
else
  echo "Application is deployed as a directory."
  chown -R antmedia:antmedia $APP_DIR -f
fi

echo "$APP_NAME is created."
