#!/bin/bash
# Script to download and ensure you have the latest apollo schema. 
# If you want the latest delete schema.graphqls and run the script

cd PocketKit/Sources/ApolloCodegen

if [ ! -f "../Sync/schema.graphqls" ]; then
    xcrun -sdk macosx swift run ApolloCodegen download-schema
fi

#Always generate the latest from the schema file
xcrun -sdk macosx swift run ApolloCodegen generate

# propagate the xcrun call's return code to Xcode

exit $?
