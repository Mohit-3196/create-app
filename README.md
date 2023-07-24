# create-app
This script is to create an application in Ant Media Server. Using this script you can create applications in your Ant Media with a defined database such as MongoDB, and Redis.

### MapDB:
`sudo ./create_app.sh -n myapp`

### Standalone Mode Using Redis as the Database:
- Without Username and Password:
`sudo ./create_app.sh -n myapp -h redis://localhost:6379`
- With Username and Password:
`sudo ./create_app.sh -n myapp -h redis://username:password@localhost:6379`

### Cluster Mode Using Redis as the Database:
- Without Username and Password:
`sudo ./create_app.sh -n myapp -c true -h redis://localhost:6379`
- With Username and Password:
`sudo ./create_app.sh -n myapp -c true -h redis://username:password@localhost:6379`

### Standalone Mode Using MongoDB as the Database:
- Without Username and Password:
`sudo ./create_app.sh -n myapp -h mongodb://localhost:27017`
- With Username and Password:
`sudo ./create_app.sh -n myapp -h mongodb://username:password@localhost:27017`

### Cluster Mode Using MongoDB as the Database:
- Without Username and Password:
`sudo ./create_app.sh -n myapp -c true -h mongodb://mongodb-cluster-ip:27017`
- With Username and Password:
`sudo ./create_app.sh -n myapp -c true -h mongodb://username:password@mongodb-cluster-ip:27017`


Please replace the placeholders myapp, localhost, username, password, and mongodb-cluster-ip, etc. with the actual values specific to your setup.

By including the -c flag, you enable cluster mode for the application deployment. Omitting the -c flag will default to standalone mode.
