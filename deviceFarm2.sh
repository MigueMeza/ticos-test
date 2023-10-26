#!/bin/bash

# Variables
PROJECT_ARN="arn:aws:devicefarm:us-west-2:480127788555:project:0350d16f-da9c-43f7-a14c-dc25fb82c8b5"
DEVICE_POOL_ARN="arn:aws:devicefarm:us-west-2:723718931296:devicepool:bb57733a-a935-4cfd-b9f3-e9ac685585fe/0cf4cfb6-3554-4bf7-804a-6f7ce0a0cb6a"
APP_PATH="test.apk"
TEST_SPEC_PATH="./testSpec.yaml"
echo "ok1"

# Subir la aplicación
app_upload=$(aws devicefarm create-upload --project-arn "$PROJECT_ARN" --name $APP_PATH --type ANDROID_APP --project-arn $PROJECT_ARN --output text)
echo $app_upload
echo "ok2"

# Crear una especificación de pruebas (reemplaza 'tu_especificacion_de_pruebas.yaml' con el nombre real del archivo)
#test_spec_arn=$(aws devicefarm create-upload --project-arn "$PROJECT_ARN" --name "MyTestSpec" --type APPIUM_JAVA_TESTNG_TEST_SPEC --query 'upload.arn' --output text)
#aws devicefarm upload-remote-access-session \
#    --remote-access-session-arn "$test_spec_arn" \
#    --name "MyTestSpec" \
#    --type APPIUM_JAVA_TESTNG_TEST_SPEC \
#    --path "$TEST_SPEC_PATH"
#echo "ok3"

# Iniciar la ejecución de pruebas
aws devicefarm schedule-run \
    --project-arn "$PROJECT_ARN" \
    --app-arn "$app_upload" \
    --device-pool-arn "$DEVICE_POOL_ARN" \
    --name "MyRun" \
    --test '{"type": "BUILTIN_FUZZ"}'
echo "ok4"

# Esperar a que las pruebas finalicen
while true; do
    status=$(aws devicefarm get-run --arn "$session_arn" --query 'run.status' --output text)
    if [ "$status" == "COMPLETED" ]; then
        break
    elif [ "$status" == "ERRORED" ] || [ "$status" == "STOPPED" ]; then
        echo "Error al ejecutar pruebas"
        exit 1
    fi
    sleep 60
done

# Obtener los resultados de las pruebas
results=$(aws devicefarm get-run --arn "$session_arn" --query 'run.result' --output text)
echo "Resultado de las pruebas: $results"
