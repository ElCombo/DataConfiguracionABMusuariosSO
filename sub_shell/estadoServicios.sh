function desactivarServicio()
{
    if systemctl disable $sname.service
    then
	echo "Servicio desactivado"
    else
	echo "Error desconocido: $?"
    fi
    read a
}

function activarServicio()
{
    if systemctl enable $sname.service
    then
	echo "Servicio activado"
    else
	echo "Error desconocido: $?"
    fi
    read a
}

function correrServicio()
{
    if systemctl start $sname.service
    then
	echo "Servicio iniciado"
    else
	echo "Error desconocido: $?"
    fi
    read a
}

function correrServicio()
{
    if systemctl stop $sname.service
    then
	echo "Servicio parado"
    else
	echo "Error desconocido: $?"
    fi
    read a
}

function buscarServicio()
{
    echo -n "Qué servicio quiere buscar? (ej: sshd, informix, network, et al) "
    read sname
    if ! echo $sname | grep -E "^[a-zA-Z]+$" 2>/dev/null
    then
	echo "Nombre inválido"
	return
    fi
    state=$(systemctl status $sname.service | grep "Loaded" -d' ' -f7 | tr -d ';')
    activ=$(systemctl status $sname.service | grep "Active" -d' ' -f6 | tr -d '()')
    echo "$sname": $state $activ
    nombres=("Activar", "Desactivar", "Correr", "Detener", "Ver_Mensajes")
    direcciones=(activarServicio, desactivarServicio, correrServicio, pararServicio, mensajesServicio)
    menu "nombres[@]" "direcciones[@]"
}

function estadoServicios()
{
    inp=-1
    while [ $inp -lt 0 ]; do
	serviciosActivados=($(systemctl list-unit-files --state=enabled | tail -n +2 | head -n -2 | cut -d' ' -f1 | grep -vE "target|@"))
	for ((i=0;i<${#serviciosActivados[@]};++i)); do
	    echo $i")" ${serviciosActivados[$i]}
	    state=($(systemctl status ${serviciosActivados[$i]} | grep Active:))
	    #		echo $data;
	    echo -n "Estado: ";
	    echo ${state[1]} # | grep 'Active:' | cut -d' ' -f5
	done
        echo -n "Desea ver los mensajes de algún servicio? [0;${#serviciosActivados[@]}): "
	read inp
	if [ "$inp" == "" ]
	then
	    return
	elif ! echo $inp | grep -E "^[0-9]{1,9}$" > /dev/null;
	then
	    echo "Debe ser un número"
	    inp=-1
	    read ff
	elif [ \( $inp -lt 0 \) -o \( $inp -ge ${#serviciosActivados[@]} \) ]
	then
	    echo "Debe estar en [0;${#serviciosActivados[@]})"
	    inp=-1
	    read ff
	else
	    echo "Viendo mensajes de ${serviciosActivados[$inp]}"
	    journalctl --unit=${serviciosActivados[$inp]}
	    inp=-1
	    read ff
	fi
    done
}
