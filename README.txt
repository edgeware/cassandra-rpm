# In order to build cassandra first download latest version and install using maven local repo.
mvn install:install-file -DgroupId=org.apache.cassandra \
 	                      -DartifactId=apache-cassandra \
 	                      -Dversion=0.8.4 \
 	                      -Dclassifier=bin \
 	                      -Dpackaging=tar.gz  \
 	                      -Dfile=/PATH-TO/apache-cassandra-0.8.4-bin.tar.gz
 	                      
 	                      
# mvn clean install -Dcassandra.version=0.8.4
# Upon install success cd to target directory
# mkdir RPMS
# mkdir BUILD
# rpmbuild -v -bb --clean --define="osVerTag fc14" classes/install/share/casandra.spec
