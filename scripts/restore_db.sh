#!/bin/bash

# Set the password (consider using a more secure method like secrets or prompts)
export PGPASSWORD='postgres'

# Example psql command within the script
docker exec -i postgres-study-env_db_1 psql -U postgres < ../db_dumps/demo-big-20170815.sql

# Unset the password variable after use
unset PGPASSWORD