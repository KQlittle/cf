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
