#!/bin/sh

export PGPASSWORD="password"
psql -h localhost -p 5432 -U postgres -d demo
