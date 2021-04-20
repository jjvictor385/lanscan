#!/usr/bin/bash

declare -A args

in=1
fn=254

args=(['-i']=in ['-f']=fn ['-m']=fmt)
argv=($@)
thisfile=$0

usage() {
	cat << EOF
Simples scanner de redes domésticas. Saiba quem mais está usando-a.

Este programa usa o envio de pacotes ICMP para o range especificado, por exemplo:

$thisfile -i 100 -f 110 -m 192.168.1.x

Isso escaneará de 192.168.1.1 até 192.168.1.100, e dirá quais outros
hosts estão em sua rede. Certifique-se de que esse é realmente o range
que seu servidor DHCP oferece. Caso não tenha certeza, especifique apenas
o formato usando [-m <format>]

Writed by John
Have a nice Day.
EOF
}

setvalue() {
	test -z $2 && echo "$1 precisa de um valor." && exit 1
	declare -g ${args[$1]}=$2
}

arrayInclude() {
	arr=()
	f=false
	for x in $@; do
		if [ $x = _ ]; then
			f=true
			continue
		fi
		if $f; then
			arr+=($x)
		fi
	done
	for x in ${arr[@]}; do
		if [ $x = $1 ]; then
			return 0
		fi
	done
	return 1
}

scan() {
	found=0
	echo "Inicializando scaneamento [${3/x/$1-$2}]"
	for n in $(seq $1 $2); do
		host=${3/x/$n}
		ping -c1 -w 1 $host > /dev/null 2> /dev/null
		if [ $? -eq 0 ]; then
			echo "Host encontrado: $host"
			found=$((found+1))
		fi
	done
	[ $found -lt 2 ] && gh="Foi encontrado $found host" || gh="Foram encontrados $found hosts"
	echo "Pronto. $gh no alcance especificado."
}

for idx in ${!argv[@]}; do
	arg=${argv[$idx]}
	nxt=${argv[$((idx+1))]}
	if [ $arg = "-h" -o $arg = "--help" ]; then
		usage
		exit 0
	fi
	if [[ ! $arg == -* ]]; then
		continue
	fi
	if ! arrayInclude $arg _ ${!args[@]}; then
		echo "Comando inválido: $arg"
		exit 1
	fi
	setvalue $arg "$nxt"
done

if [ -z $fmt ]; then
	echo "Você precisa expecificar ao menos o alvo. Use -h ou --help para ajuda."
	exit 1
fi

scan $in $fn $fmt
