# 使用前需修改 defaults 目录下的变量值
1. **docker** 相关变量，该文件用于配置 docker 运行时参数，主要作用于 daemon.json 文件。
   1. `docker.version` 指定要安装的 docker 版本
   1. `docker.registryMirrors` 指定要使用的 docker 加速
   1. `docker.execOpts` 指定要给 docker 配置的 exec-opts 字段添加的参数
   1. `docker.options` 用于修改 docker.service 的运行时参数
   1. `docker.insecureRegistries` 用于指定 docker 可以操作的不安全的镜像仓库的地址