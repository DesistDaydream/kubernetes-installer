#!/bin/bash
#
# images 获取方式：docker images --format={{.Repository}}:{{.Tag}} | grep XXXX
source ./images.sh

function Executer(){
	Init
	for Image in ${Images[@]}; do
		RegistrySrc="${Image%/*}"
		ImagesName="${Image##*/}"
		$1 & 
	done
	rm -f /root/.docker/config.json
}

function Pull(){
	docker pull ${RegistrySrc}/${ImagesName}
}

function Push(){
	docker tag ${RegistrySrc}/${ImagesName} ${RegistryDest}/${ImagesName}
	docker push ${RegistryDest}/${ImagesName}
	docker rmi ${RegistryDest}/${ImagesName}
}

function PullAndPush(){
	docker pull ${RegistrySrc}/${ImagesName}
	docker tag ${RegistrySrc}/${ImagesName} ${RegistryDest}/${ImagesName}
	docker push ${RegistryDest}/${ImagesName}
	docker rmi ${RegistryDest}/${ImagesName}
}

function ChangeTag(){
	docker tag ${RegistrySrc}/${ImagesName} ${RegistryDest}/${ImagesName}
}

function Rmi(){
	docker rmi ${Images}
}

function Save(){
	docker save ${Images[@]} -o images.tar
}

function Init(){
	read -p "输入目的镜像仓库名:(默认为 registry.aliyuncs.com)" RegistryDest; RegistryDest=${RegistryDest:-'registry.aliyuncs.com'}
	read -p "输入目的镜像仓库名称空间:(默认为 desist-daydream)" RegistryNS; RegistryNS=${RegistryNS:-'desist-daydream'}
	RegistryDest="${RegistryDest}/${RegistryNS}"
	read -p 'Please print "yes" to continue or "no" to cancel:' AGREE

	while [ "${AGREE}" != "yes" ]; do
	    if [ "${AGREE}" == "no" ]; then
	    	Init
	    else
			echo -n 'Please print "yes" to continue or "no" to cancel:'
	        read AGREE
	    fi
	done
}

OPTIONS=(
'下载 images.sh 中的镜像'
'推送 images.sh 中的镜像到指定仓库'
'下载 images.sh 中的镜像并修改tag后推送到指定目标仓库'
'更改 images.sh 中的镜像的仓库名为目标仓库名'
'删除 images.sh 中指定的镜像'
'打包 images.sh 中的镜像'
'退出'
)
PS3="Please give me num [1-7]:"

select OPTION in "${OPTIONS[@]}";do
	case ${OPTION} in
	${OPTIONS[0]})
		Executer Pull
		;;
	${OPTIONS[1]})
		Executer Push
		;;
	${OPTIONS[2]})
		Executer PullAndPush
		;;
	${OPTIONS[3]})
		Executer ChangeTag
		;;
	${OPTIONS[4]})
		Executer Rmi
		;;
	${OPTIONS[5]})
		Save
		;;
	${OPTIONS[6]})
		echo "Program Exited, goodbye!^_^";
		exit 0
		;;
	*)
		echo "Unrecognized Number，Please use [1-7]"
		;;
	esac
done