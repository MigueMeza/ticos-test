#!/bin/bash

# Variables
PROJECT_ARN="arn:aws:devicefarm:us-west-2:480127788555:project:0350d16f-da9c-43f7-a14c-dc25fb82c8b5"
#test device pool
DEVICE_POOL_ARN="arn:aws:devicefarm:us-west-2:480127788555:devicepool:0350d16f-da9c-43f7-a14c-dc25fb82c8b5/3d156911-a086-4a8c-aaea-55853c012a6d"
#DEVICE_POOL_ARN="arn:aws:devicefarm:us-west-2:480127788555:devicepool:0350d16f-da9c-43f7-a14c-dc25fb82c8b5/e35b0bd1-9657-4f78-b44b-99dad91d96ea"
APP_PATH="aeromexicoapp.ipa"
TEST_SPEC_PATH="./testSpec.yaml"
echo "ok1"

# Subir la aplicación
#app_upload_result=$(aws devicefarm create-upload --project-arn "$PROJECT_ARN" --name $APP_PATH --type IOS_APP --project-arn $PROJECT_ARN)
#app_upload=$(echo $app_upload_result | jq -r '.upload.arn')
#echo $app_upload
#echo "ok2"
#rslt=$(aws devicefarm get-upload --arn $app_upload)
#echo $rslt

# Crear una especificación de pruebas (reemplaza 'tu_especificacion_de_pruebas.yaml' con el nombre real del archivo)
#test_spec_arn=$(aws devicefarm create-upload --project-arn "$PROJECT_ARN" --name "MyTestSpec" --type APPIUM_JAVA_TESTNG_TEST_SPEC --query 'upload.arn' --output text)
#aws devicefarm upload-remote-access-session \
#    --remote-access-session-arn "$test_spec_arn" \
#    --name "MyTestSpec" \
#    --type APPIUM_JAVA_TESTNG_TEST_SPEC \
#    --path "$TEST_SPEC_PATH"
#echo "ok3"

# Iniciar la ejecución de pruebas
run_result=$( aws devicefarm schedule-run \
    --project-arn "$PROJECT_ARN" \
    --app-arn "arn:aws:devicefarm:us-west-2:480127788555:upload:0350d16f-da9c-43f7-a14c-dc25fb82c8b5/4694ebb3-50fe-47d9-959d-28b77fe544a5" \
    --device-pool-arn "$DEVICE_POOL_ARN" \
    --name "MyRun" \
    --test '{"type": "BUILTIN_FUZZ"}')
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


# Obtener los resultados de las pruebas
results=$(aws devicefarm get-run --arn "$session_arn" --query 'run.result' --output text)
echo "Resultado de las pruebas: $results"
