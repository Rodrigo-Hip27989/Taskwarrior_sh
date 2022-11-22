#!/bin/sh
# -*- ENCODING: UTF-8 -*-

#ESTILOS DE LETRAS
tipo_bold_fuente_yellow="\e[1;33m"
tipo_bold_fuente_cyan="\e[1;36m"
tipo_bold_fuente_green="\e[1;32m"
tipo_bold_fuente_white="\e[1;37m"
#ESTILOS DE LETRAS TITULOS
tipo_bold_fuente_green_fondo_blue="\e[1;32;44m"
TITULO=${0#*./}

# ***************************************** FUNCION PRINCIPAL

taskwarrior(){
	local file_name="TaskList"
	local file_directory="../../About__Software/Android/Data__Exports/"
	choose_option_menu "$file_name" "$file_directory"
}

# ***************************************** MENÚ DE OPCIONES

choose_option_menu(){
	local file_name=$1
	local file_directory=$2
	local opcion=""
	local canceldo=0;
	clear
	cd "$file_directory"
    opcion=$(dialog --title "$TITULO" \
         --stdout \
         --menu "\nUtilidades para Lista de Tareas\
                           \n\nElige una opción" 18 60 20 \
              1 " Importar Tareas" \
	          2 " Exportar Tareas" \
              3 " Ver Datos del Archivo JSON" \
              4 " Borrar Registro de Tareas Eliminadas")
    cancelado=$?
	case $opcion in
		1) import_task ;;
		2) export_task "${file_name}__$(date +'%Y_%m_%d_%H%M').json";;
		3) show_file_task "$file_directory";;
		4) borrar_registros_tareas;;
	esac
	cd .. && cd ..
    if [[ $cancelado = 0 ]]; then
        choose_option_menu "$file_name" "$file_directory"
    fi
        clear && exit
}

# ***************************************** OPCIONES DEL MENU - USANDO DIALOG

export_task(){
    local cancelado
	local file_name=$1

    file_name=$(dialog --stdout --title "Exportación de Archivo JSON" --inputbox "\n\n Nombre del Archivo: " 12 45 "$file_name")
    cancelado=$?

    if [[ $cancelado -eq 0 ]]; then
    	validate_and_export_file "$file_name"
    else
        mensaje_dialog_small "\n\n Exportación cancelada!"
    fi
}

import_task(){
    local cancelado
    local file_name
    local file_name_and_full_path="null"

    file_name_and_full_path=$(dialog --stdout --title "Importación de Archivo JSON" --fselect "$(pwd)/" 15 67)
    cancelado=$?

    if [[ $cancelado -eq 0 ]]; then
        file_name=$(get_file_name_in_full_path $file_name_and_full_path)
        validate_and_import_file "$file_name"
    else
        mensaje_dialog_small "\n\n Importación cancelada!" && show_how_select_file
    fi
}

show_file_task(){
    local cancelado
    local file_name
    local file_directory=$1
    local file_name_and_full_path="null"
    cd "$file_directory"

    file_name_and_full_path=$(dialog --stdout --title "Visualizar de Archivo JSON" --fselect "$(pwd)/" 15 67)
    cancelado=$?

    if [[ $cancelado -eq 0 ]]; then
        file_name=$(get_file_name_in_full_path $file_name_and_full_path)
        validate_and_show_file_json "$file_name"
    else
        mensaje_dialog_small "\n\n Visualización cancelada!" && show_how_select_file
    fi
}

# ***************************************** OPCIONES DEL MENU

validate_and_export_file(){
	local file_name=$1
	if [[ $(validate_file_name "json" $file_name) = "true" ]]; then
        task export > $file_name && mensaje_dialog_small "\n\n Exportación completada!" && show_details_file "$file_name"
    else
        export_task $file_name
    fi
}

validate_and_import_file(){
    local file_name=$1
    if [[ $(validate_file_name "json" $file_name) = "true" ]]; then
        task import $file_name && mensaje_dialog_small "\n\n Importación completada!"
	else
        import_task
    fi
}

validate_and_show_file_json(){
	local file_name=$1
	if [[ $(validate_file_name "json" $file_name) = "true" ]]; then
        clear && echo -e "\n$tipo_bold_fuente_green_fondo_blue Archivo \n\n$file_name\e[0m\n" && cat $file_name | jq && esperar_tecla_enter
    else
        show_file_task
    fi
}

validate_file_name(){
	local requested_file_extension=$1
	local file_name=$2
    local file_extension=$(get_file_extension $file_name)
    if [[ ${#file_name} -gt 0 ]]; then
        if [[ $file_extension = $requested_file_extension ]]; then
            echo "true"
        else
            mensaje_dialog_small "\n\n El tipo de archivo debe ser ${requested_file_extension^^}!"
         fi
    else
        mensaje_dialog_small "\n\n El nombre del archivo es nulo o vacío!"
    fi
}

borrar_registros_tareas(){
    local eliminar_tareas=`yes | task purge`
    clear && echo -e "\n$tipo_bold_fuente_green_fondo_blue Resultado: \e[0m \n$tipo_bold_fuente_yellow\n$eliminar_tareas\e[0m"
	esperar_tecla_enter
}

# ***************************************** UTILIDADES DE FUNCIONES

get_file_name_in_full_path(){
    local file_name_and_full_path=$@
    local file_directory=$(pwd)
    echo "${file_name_and_full_path:(${#file_directory}+1):(${#file_name_and_full_path})}"
}

get_file_extension(){
    local file_name=$@
    echo "${file_name#*.}"
}

# ***************************************** MENSAJES

show_how_select_file(){
    local about_import_export="\n How select file?\n\n * Use TAB and UP/DOWN keys to move.\n\n * Use SPACE key to select an option"
    mensaje_dialog_small "$about_import_export"
}

show_details_file(){
    local file_name=$1
    local details_import_export="\
        \nDetalles del archivo\
        \n\n* Nombre del Archivo: \n\n $file_name
        \n\n* Directorio: \n\n $(pwd)/"
    mensaje_dialog_medium "$details_import_export"
}

esperar_tecla_enter(){
	echo -e "\n$tipo_bold_fuente_green_fondo_blue Presione una ENTER para continuar\e[0m" && read
}

# ***************************************** TIPOS DE MENSAJES DIALOG

mensaje_dialog_medium(){
    local mensaje_dialog=$@
    clear
    $(dialog --title "$TITULO" \
         --stdout \
         --msgbox "$mensaje_dialog" 16 45)
}

mensaje_dialog_small(){
    local mensaje_dialog=$@
    clear
    $(dialog --title "$TITULO" \
         --stdout \
         --msgbox "$mensaje_dialog" 12 45)
}

# ***************************************** OTROS MENSAJES

taskwarrior
