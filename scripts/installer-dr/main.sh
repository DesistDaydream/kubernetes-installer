#!/bin/bash
set -ue
set -o pipefail
#
# help 本工具帮助信息
function help(){
    echo "注意：如果想要正常部署，-p 选项必须作为第一个参数
Usage: bash main.sh OPTIONS
OPTIONS：
-h, --help                  帮助信息
    --install               部署 k8s 集群的前置负载均衡器
-p, --passwd <PASSWD>       服务器root密码
"
}

# init 初始化变量
function init(){
    WorkDir=$(pwd)
    source ${WorkDir}/variables/variables.sh
}

# confirm 确认要安装的集群节点信息
function confirm(){
    for dr in ${DR[@]}; do
        echo -e "\033[32m ${dr%%=*} ${dr##*=} \033[0m"
    done
    echo "root密码为：${Password},错了可没法执行呦~"
        read -p "请确认集群节点信息是否正确(yes/no):" Confirm
    if [[ ${Confirm} != "yes" ]]; then
        exit 1
    fi
}

# 参数处理
opts=`getopt -o fhp: -l debug,force,help,install,passwd: \
     -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "terminating..." >&2 ; exit 1 ; fi
eval set -- "$opts"

# 工具入口
while true; do
    case "$1" in
    --debug)
        echo "测试文件分发"
        confirm
        source ${WorkDir}/executer/send_files.sh
        exit 0
        ;;
    -f|--force)
        echo "添加强制执行参数，待补充"; shift;;
    -h|--help)
        help; exit 0;;
    --install)
        init; confirm; source ${WorkDir}/executer/executer.sh; shift;;
    -p|--passwd) 
        Password=$2; shift 2;;
    --) 
        shift
        break
        ;;
    *)
        echo "internal error!"
        exit 1
        ;;
    esac
    # shift
done
