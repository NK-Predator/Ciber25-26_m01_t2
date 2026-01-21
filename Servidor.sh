#!/bin/bash

echo "Server RECTP_0.9"

PORT=9999

ACTUAL_VERSION="0.9"

ACTUAL_HEADER="RECTP"

SERVER_DIR="server"

mkdir -p $SERVER_DIR

    echo "0. LISTEN"

    DATA=$(nc -l -p "$PORT")

    echo "Data received: $DATA"

    HEADER=`echo "$DATA" | cut -d " " -f 1`
    VERSION=`echo "$DATA" | cut -d " " -f 2`

     echo "3. TEST"

     echo "Data recieved: $DATA"

    if [ "$HEADER" != "$ACTUAL_HEADER" ]
    then
        echo "ERROR 1: Wrong Header"
	sleep 1
        echo "HEADER_KO ERROR:HEADER" | nc $IP_CLIENT -q 0 $PORT
        exit 1
    fi

    if [ "$VERSION" != "$ACTUAL_VERSION" ]
    then
        echo "ERROR 2: Wrong Version"
	sleep 1
        echo "HEADER_KO" | nc $IP_CLIENT -q 0 $PORT
        continue
    fi

    IP_CLIENT=$(echo $DATA | cut -d " " -f3)

    if [ "$IP_CLIENT" == "" ]
    then 
	    echo "Error: Ip del cliente mal formada"
	    exit 4
    fi

    HASH=$(echo "$DATA" | cut -d " " -f 4)

    HASH_TEST=$(echo "$IP_CLIENT" | md5sum | cut -d " " -f 1)



    if [ "$HASH" != "$HASH_TEST" ]
    then
	   echo "Error: Hash cliente mal formado"
	   exit 4
    fi

    echo "3.1 RESPONSE"
    sleep 1
    echo "HEADER_OK VERSION_OK" | nc $IP_CLIENT -q 0 $PORT

    echo "4. LISTEN"

    FILE_DATA=$(nc -l -p "$PORT")

    echo "Data recieved: '$FILE_DATA'"

    FILE_NAME=$(echo "$FILE_DATA" | cut -d " " -f 2)
    FILE_PREFIX=$(echo "$FILE_DATA" | cut -d " " -f 1)
    FILE_HASH=$(echo "$FILE_DATA" | cut -d " " -f 3)

    if [ "$FILE_PREFIX" != "FILE_NAME" ]
    then
	    echo "ERROR: Wrong file prefix"
	    sleep 1
	    echo "FILE_NAME_OK" | nc $IP_CLIENT -q 0 $PORT
	    exit 1
    fi

FILE_HASH_TEST=$(echo "$FILE_NAME" | md5sum | cut -d " " -f 1)

    if [ "$FILE_HASH" != "$FILE_HASH_TEST" ]
    then
	    echo "Error: El hash no coincide."
	    sleep 1
	    
    fi

    echo "File name: $FILE_NAME"

    TARGET_DIRECTORY="server/$FILE_NAME"

    echo "8.2 RESPONSE FILE NAME OK"

    sleep 1
    echo "FILE_NAME_OK" | nc $IP_CLIENT -q 0 $PORT

    echo "9. LISTEN. FILE DATA"

    echo "13. STORE FILE DATA"
    
    nc -l -p $PORT > $SERVER_DIR/$FILE_NAME

    echo "File recieved at: $SERVER_DIR/$FILE_NAME"

    echo "14. SEND. FILE_DATA_OK"

    sleep 1
    echo "FILE_DATA_OK" | nc $IP_CLIENT -q 0 $PORT

    echo "LISTEN. FILE_DATA_HASH"

    DATA=$(nc -l -p $PORT)

    FILE_DATA_HASH=$(cat $FILE_NAME | md5sum | cut -d " " -f 1)

    if [ "$FILE_DATA_HASH" != "$DATA" ]
    then
		echo "SEND. FILE_DATA_HASH_KO"
		exit 1
    fi

    echo "SEND. FILE_DATA_HASH_OK"

    echo "FILE_DATA_HASH_OK"  | nc $IP_CLIENT -q 0 $PORT

    echo "TODO LISTO!"
    
    exit 0
    
