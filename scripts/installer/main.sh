#!/bin/bash
set -ue
set -o pipefail
#
# help 本工具帮助信息
function help(){
    echo -e "
Usage: bash main.sh OPTIONS
    注意：如果想要正常部署，-p 选项必须作为第一个参数\n
OPTIONS：
    -h, --help                   帮助信息
        --install                部署 k8s 集群
    -j, --join '<IP=HOST ...>'   添加一个新节点,多个节点以空格分隔，并使用引号将所有节点引用起来
    -p, --passwd <PASSWD>        服务器root密码
        --reset                  删除集群并清理环境
"
}

# init 初始化变量
function init(){
    WorkDir=$(pwd)
    source ${WorkDir}/variables/variables.sh
    if [[ ${#Nodes[@]} -gt "0" ]]; then
        AllNodes=("${Masters[@]}" "${Nodes[@]}")
    else
        AllNodes=("${Masters[@]}")
    fi
}

# confirm 确认要安装的集群节点信息
function confirm(){
    echo "Master 节点为："
    for master in ${Masters[@]}; do
        echo -e "\033[32m ${master%%=*} ${master##*=} \033[0m"
    done
    if [[ ${#Nodes[@]} -gt "0" ]]; then
        echo "Node 节点为："
        for node in ${Nodes[@]}; do
            echo -e "\033[32m ${node%%=*} ${node##*=} \033[0m"
        done
    fi
    echo "root密码为：${Password},错了可没法执行呦~"
        read -p "请确认集群节点信息是否正确(yes/no):" Confirm
    if [[ ${Confirm} != "yes" ]]; then
        exit 1
    fi
}

# 参数处理
opts=`getopt -o fhj:p: -l debug,force,help,install,join:,passwd:,reset \
     -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "terminating..." >&2 ; exit 1 ; fi
eval set -- "$opts"

# 工具入口
while true; do
    case "$1" in
    --debug)
        echo "测试单独的功能"
        init; confirm; source ${WorkDir}/config/kubeadm_config.sh; exit 0;;
    -f|--force)
        echo "添加强制执行参数，待补充"; shift;;
    -h|--help)
        help; exit 0;;
    --install)
        init; confirm; source ${WorkDir}/deployment/deployment.sh; shift;;
    -j|--join)
        init; confirm; NewNodes=($2); source ${WorkDir}/executer/join_new.sh; shift 2;;
    -p|--passwd)
        Password=$2; shift 2;;
    --reset)
        init; confirm; source ${WorkDir}/executer/reset.sh; shift;;
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
