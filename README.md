# create-app
This script is to create an application in Ant Media Server. Using this script you can create applications in your Ant Media with a defined database such as MongoDB, MongoDB serverless, or Redis.

## For Ant Media Server running in standalone mode
### MongoDB:
./create_application.sh -n live -h mongodb://localhost:27017 -u username -p password

### MongoDB Atlas:
./create_application.sh -n live -h mongodb+srv://<username>:<password>@cluster-url -u username -p password

### Redis:
./create_application.sh -n live -h redis://localhost:6379

## For Ant Media Server running in cluster mode
### MongoDB:
./create_application.sh -n live -c -h mongodb://mongodb-cluster-ip:27017 -u username -p password

### MongoDB Atlas:
./create_application.sh -n live -c -h mongodb+srv://<username>:<password>@cluster-url -u username -p password

### Redis:
./create_application.sh -n live -c -h redis://redis-host:6379

Please replace the placeholders <username>, <password>, mongodb-cluster-ip, and cluster-url with the actual values specific to your setup.

By including the -c flag, you enable cluster mode for the application deployment. Omitting the -c flag will default to standalone mode.
