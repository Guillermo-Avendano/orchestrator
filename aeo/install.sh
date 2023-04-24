
#!/bin/bash

source "../env.sh"
source "$kube_dir/common/common.sh"

DBFILE_TEMPLATE=database/template/aeo_4.3.1.60.sql

DBFILE=database/aeo_4.3.1.60.sql

cp $DBFILE_TEMPLATE $DBFILE

replace_tag_in_file $DBFILE "<database_user>" $POSTGRESQL_USERNAME;
replace_tag_in_file $DBFILE "<database_password>" $POSTGRESQL_PASSWORD;
replace_tag_in_file $DBFILE "<database_name>" $POSTGRESQL_DBNAME;
replace_tag_in_file $DBFILE "<postgres_port>" $POSTGRESQL_PORT;

terraform apply 
