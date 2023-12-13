# cf
```
docker run \
    -itd \
    --name cfip \
    --restart always \
    --network=host \
    -v $(pwd)/cfip:/opt \
    kwxos/cfaliddns:latest
```

在/cfip目录中放入config文件
