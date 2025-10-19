#!/bin/bash

# Add a new migration
if [ "$1" = "add" ]; then
    if [ -z "$2" ]; then
        echo "Usage: ./migrations.sh add <migration-name>"
        exit 1
    fi
    dotnet ef migrations add "$2" --project Hyrox.Api.csproj
# Update database
elif [ "$1" = "update" ]; then
    dotnet ef database update --project Hyrox.Api.csproj
# Remove last migration
elif [ "$1" = "remove" ]; then
    dotnet ef migrations remove --project Hyrox.Api.csproj
else
    echo "Usage: ./migrations.sh [add <migration-name>|update|remove]"
    exit 1
fi