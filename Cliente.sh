

#!/bin/bash


PORT=9999

ACTUAL_VERSION="0.9"

SERVER_IP="192.168.225.141"

FILE_NAME="audio.wav"

echo "Cliente del protocolo RECTP v0.9"

echo "1. SEND. Enviamos la cabecera al servidor"

IP_LOCAL=$(ip -4 a | grep "scope global" | awk '{print $2}' | cut -d "/" -f1)
#IP_LOCAL=$(ip -4 a | grep "scope global" | tr -s " " | cut -d " " -f3 | cut -d "/" -f1)
#IP_LOCAL=$(ip route get 1 | awk '{print $7}')

HASH=$(echo "$IP_LOCAL" | md5sum | cut -d " " -f 1)

sleep 1
echo "RECTP $ACTUAL_VERSION $IP_LOCAL $HASH" | nc $SERVER_IP -q 0 $PORT

echo "2. LISTEN"

RESPONSE=`nc -l -p $PORT`

	echo "Contestación Servidor: $RESPONSE"

HEADER=`echo "$RESPONSE" | cut -d " " -f1`
VERSION=`echo "$RESPONSE" | cut -d " " -f2`

echo "5. TEST. Header Response"

if [ "$HEADER" != "HEADER_OK" ]
then
	echo "ERROR: Header erróneo"

	exit 1
fi

if [ "$VERSION" != "VERSION_OK" ]
then
	echo "ERROR: Versión errónea"

	exit 1

fi

echo "6. SEND. Nombre de archivo"

sleep 1

FILE_HASH=$(echo "$FILE_NAME" | md5sum | cut -d " " -f 1)

echo "FILE_NAME $FILE_NAME $FILE_HASH" | nc $SERVER_IP -q 0 $PORT

echo "7. LISTEN. Respuesta Servidor"

RESPONSE=`nc -l -p $PORT`

echo  "Respuesta servidor: $RESPONSE"

if [ "$RESPONSE" != "FILE_NAME_OK" ]
then 
	echo "ERROR: Nombre Incorrecto"

	exit 2
fi


echo "11. SEND. FILE DATA"

sleep 1
cat $FILE_NAME | nc $SERVER_IP -q 0 $PORT

echo "12. LISTEN"

RESPONSE=$(nc -l -p $PORT)

echo "16. TEST. FILE_DATA_OK"

if [ "$RESPONSE" != "FILE_DATA_OK" ]
then
	echo "ERROR 3: Datos del archivo erróneos"

	exit 3
fi

echo "17. SEND. FILE_DATA_HASH"

FILE_DATA_HASH=$(cat $FILE_NAME | md5sum | cut -d " " -f 1)

echo $FILE_DATA_HASH | nc $SERVER_IP -q 0 $PORT

RESPONSE=$(nc -l -p $PORT)

if [ "$RESPONSE" != "FILE_DATA_HASH_OK" ]
	echo "ERROR: File Data Hash incorrect."
	exit 4
fi

echo "TODO LISTO!"

exit 0
