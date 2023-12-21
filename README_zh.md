# TransCert
一个简单的工具，允许您从服务器获取 SSL 证书。 

[English](https://github.com/Keviince/TransCert/blob/main/README.md)

## 要求
[acme.sh](https://github.com/acmesh-official/acme.sh)  
gpg  
tar  
sha256sum  

## 用法
### push_cert.sh
在通过 acme.sh 获取新证书后，运行此脚本来打包您的证书并为其生成一个 sha256 哈希值。  
之后，此脚本将自动将证书及其哈希值移动到 Web 服务器目录，以便客户端可以访问它们。  

一旦您下载了此脚本，请记得在其中更改以下 3 个变量。  
|变量|描述|
|--------|-----------|
|CERT_HOME|存储 Web 服务器用于发布的证书的位置。|
|ACME_HOME|您安装 acme.sh 的位置。|
|CERT_PASSWORD|您希望加密证书的密码。|

___

### pull_cert.sh
运行此脚本将检查本地证书的 sha256 哈希值。  
如果与服务器上的签名不匹配或本地没有证书，则脚本将自动下载服务器上的最新证书并进行解密和解压缩。  
替换最新证书与旧证书后，此脚本将重新加载 nginx（可以是任何操作）。  

一旦您下载了此脚本，请记得在其中更改以下 2 个变量。  
|变量|描述|
|--------|-----------|
|CERT_SERVER|证书发布服务器的 URL。|
|after_pull|安装证书后需要执行的操作。|  

在使用此脚本从服务器拉取证书时，您需要提供以下 3 个参数。
|变量|描述|
|--------|-----------|
|--domain|证书的域名。|
|--location|您希望证书放置的位置。|
|--password|解密证书所需的密码。|  

用法:  
`
sh pull_cert.sh --domain=[域名] --password=[密码] --location=[位置]
`
