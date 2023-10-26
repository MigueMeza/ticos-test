#!/bin/bash

# Variables
PROJECT_ARN="arn:aws:devicefarm:us-west-2:723718931296:project:bb57733a-a935-4cfd-b9f3-e9ac685585fe"  # Nombre del proyecto en AWS Device Farm
DEVICE_POOL_NAME="phone1"    # Nombre del grupo de dispositivos en AWS Device Farm
APK_FILE="test.apk"             # Nombre del archivo APK
#TEST_SPEC_FILE="sample-appium-testspec.yml"  # Nombre del archivo de especificación de prueba (debe estar en el mismo directorio que este script)
DEVICE_POOL_ARN="arn:aws:devicefarm:us-west-2:723718931296:devicepool:bb57733a-a935-4cfd-b9f3-e9ac685585fe/0cf4cfb6-3554-4bf7-804a-6f7ce0a0cb6a"  # ARN del grupo de dispositivos (obtén este valor de AWS Console)
echo "ok1"

# Sube el archivo APK a AWS Device Farm
upload_result=$(aws devicefarm create-upload  --name $APK_FILE --type ANDROID_APP --project-arn $PROJECT_ARN )
echo "ok2"

# Se extrae el ARN del upload
app_arn=$(echo $upload_result | jq -r '.upload.arn')
echo $app_arn
rn=$(aws devicefarm get-upload –-arn $app_arn)
echo "ok3"
STR="devicefarm schedule-run --project-arn $PROJECT_ARN --app-arn $app_arn --device-pool-arn $DEVICE_POOL_ARN --name MyTest  --test '{"type": "BUILTIN_FUZZ"}'"
echo $STR

# Sube el archivo de especificación de prueba a AWS Device Farm
#aws devicefarm create-upload --project-name $PROJECT_NAME --name $TEST_SPEC_FILE --type APPIUM_JAVA_TESTNG_TEST_SPEC
#test_spec_arn=$(echo $upload_result | jq -r '.upload.arn')

# Inicia una ejecución de prueba en AWS Device Farm
#run_result=$(aws devicefarm schedule-run --project-name $PROJECT_NAME --app-arn $upload_arn --device-pool-arn $DEVICE_POOL_ARN --name "MyTestRun" --test '{"type": "APPIUM_JAVA_TESTNG", "testPackageArn": "'$test_spec_arn'"}')
run_result=$(aws devicefarm schedule-run --project-arn $PROJECT_ARN --app-arn $app_arn --device-pool-arn $DEVICE_POOL_ARN --name MyTest  --test '{"type": "BUILTIN_FUZZ"}')
echo "ok4"

# Extrae el ARN de la ejecución de prueba
run_arn=$(echo $run_result | jq -r '.run.arn')
echo "ok5"

# Espera hasta que la ejecución de prueba finalice
while true; do
    status=$(aws devicefarm get-run --arn $run_arn --query "run.status" --output text)
    if [[ $status == "COMPLETED" ]]; then
        echo "Run completed successfully."
        break
    elif [[ $status == "ERRORED" || $status == "STOPPED" ]]; then
        echo "Run encountered an error or was stopped."
        exit 1
    else
        echo "Waiting for the run to finish..."
        sleep 10  # Adjust the polling interval as needed (in seconds)
    fi
done
echo "ok6"

# Obtiene el estado del resultado de la ejecución
result=$(aws devicefarm get-run --arn $run_arn)
echo "ok7"

# Imprime el estado del resultado
echo "Resultado de la ejecución de prueba:"
echo $result
echo "ok8"