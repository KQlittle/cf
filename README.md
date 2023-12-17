# cf
```
docker run \
    -itd \
    --name dns-ip \
    --restart always \
    --network=host \
    -v $(pwd)/dns-ip:/opt \
    kwxos/cfaliddns:latest
```

