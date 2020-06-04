#!/bin/bash

echo 创建 CA 目录
mkdir -p demoCA/{certs,newcerts,crl,private}
touch demoCA/index.txt
echo "01" > demoCA/serial

echo 生成CA密钥
openssl genrsa -des3 -out ca.key 2048
echo 生成CA根证书
openssl req -sha256 -new -x509 -days 365 -key ca.key -out ca.crt \
    -subj "/C=CN/ST=GD/L=SZ/O=lee/OU=study/CN=testRoot"
echo 生成服务器密钥
openssl genrsa -des3 -out server.key 2048
echo 生成服务器证书请求文件
openssl req -new \
    -sha256 \
    -key server.key \
    -subj "/C=CN/ST=GD/L=SZ/O=lee/OU=study/CN=bdstatic.com" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf "[SAN]\nsubjectAltName=IP:192.168.50.177")) \
    -out server.csr
echo CA签署服务器证书
openssl ca -in server.csr \
        -md sha256 \
        -keyfile ca.key \
    -cert ca.crt \
    -extensions SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf "[SAN]\nsubjectAltName=IP:192.168.50.177")) \
    -out server.crt