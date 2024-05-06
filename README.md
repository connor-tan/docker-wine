# docker-wine
参考了
https://github.com/huan/docker-wine
的实现，升级wine到9.0版本。系统使用ubuntu:jammy镜像，同时将wine设置为win7 64位架构，你也可以修改dockerfile中83行为win10
# 使用方式
git clone https://github.com/connor-tan/docker-wine.git
cd docker-wine
docker build -t docker-wine .

## 备注
有条件的挂一下代理，不然很有可能会构建不成功
