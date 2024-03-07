#!/bin/bash
rm -rf ip.txt ipv6.txt informlog
mkdir -p /opt/ddns_log
config_file="/opt/config"
if [ ! -e "$config_file" ]; then
  cat > /opt/config << EOF
#!/bin/bash
##################################静雨·安蝉>>blog.kwxos.top#########################################
## 4.2 
## 推送可选IP数量到cloudflare，暂时只支持CF，且不支持IP可用性检测
## 修复代码运行bug和逻辑
###################################################################################################
##运行模式ipv4 or ipv6 默认为：ipv4
#指定工作模式为ipv4还是ipv6
IP_ADDR=ipv4
###################################################################################################
##Cloudflare配置
#选择CF更新是否开启，true为开启CF更新，为false将不会更新
cf=false
##cloudflare配置
#是否开启小黄云true为开启，false为关闭
proxy=false
#更新A记录条数,只能大于等于一条记录，当为多ip推送时（numip值大于1），将不会进行ip可用性检测
#且需修改sltime参数，使其循环运行，建议sltime=432000，休眠5天
numip="1"
#cloudflare账号邮箱
x_email=xxxxx@qq.com
#填写需要DDNS的完整域名
hostname=xxx.xxxx.xxx
#区域 ID,域名右下角获取
zone_id=xxxxxxxxx7d14e5152f9xxxxxxxxx
#Global API Key,在https://dash.cloudflare.com/profile/api-tokens获取
api_key=xxxxxxxb4cxxxxxxxxxx
###################################################################################################
##阿里云配置
#选择阿里云是否开启，true为开启阿里云更新，为false将不会更新
ali=false
#需要更新的域名ddns.example.com
#设置需要DDNS的域名：example.com
AliDDNS_DomainName="xxxx.xxxx"
# 设置需要DDNS的主机名：ddns
AliDDNS_SubDomainName="xx"
# 设置域名记录的TTL (生存周期)
# 免费版产品最低为600(10分钟)~86400(1天), 付费版(企业版)包括以上范围, 还可以按照购买产品配置设置为：
# 600(10分钟)、120(2分钟)、60(1分钟)、10(10秒)、5(5秒)、1(1秒), 
# 请按照自己的产品配置和DDNS解析速度需求妥善配置TTL值, 免费版设置低于600的TTL将会报错。
AliDDNS_TTL="600"
# 设置阿里云的AccessKeyId/AccessKeySecret,
# 可在 https://ak-console.aliyun.com/ 处获取 ,
# 推荐使用 https://ram.console.aliyun.com/#/user/list 生成的AK/SK, 更安全
# 设置阿里云的Access Key
AliDDNS_AK="xxxxxxxxxxxxxxx"
# 设置阿里云的Secret Key
AliDDNS_SK="xxxxxxxxxxxxxxxxxxxxx"
###################################################################################################
##DNSpod配置
#选择DNSpod是否开启，true为开启DNSpod更新，为false将不会更新
DNSpod=false
#需要更新的域名ddns.example.com
#设置需要DDNS的域名：example.com
domain="xxx.xxxx"
# 设置需要DDNS的主机名：ddns
sub_domain="xx"
# 设置域名记录的TTL (生存周期)
# 免费版产品最低为600(10分钟)~86400(1天), 付费版(企业版)包括以上范围, 还可以按照购买产品配置设置为：
# 600(10分钟)、120(2分钟)、60(1分钟)、10(10秒)、5(5秒)、1(1秒), 
# 请按照自己的产品配置和DDNS解析速度需求妥善配置TTL值, 免费版设置低于600的TTL将会报错。
DNSpod_TTL="600"
# 设置DNSpod的ID/token,
#具体文档https://docs.dnspod.cn/account/dnspod-token/
# 设置DNSpod的ID
ID="xxxxxx"
# 设置DNSpod的token
TOKEN="xxxxxxxxxxxxxxxxxxxxx"
###################################################################################################
##CloudflareST配置
#选择测速是否开启true为开启，为false将不会测速
CloudflareST_speed=false
#测速地址  
CFST_URL=https://xxxxx.xxxxxxxxx.xxxxx
#测速线程数量；越多测速越快，性能弱的设备 (如路由器) 请勿太高；(默认 200 最多 1000 )
CFST_N=200
#延迟测速次数；单个 IP 延迟测速次数，为 1 时将过滤丢包的IP，TCP协议；(默认 4 次 )
CFST_T=2
#下载测速数量；延迟测速并排序后，从最低延迟起下载测速的数量；(默认 10 个)
CFST_DN=2
#平均延迟上限；只输出低于指定平均延迟的 IP，可与其他上限/下限搭配；(默认9999 ms 这里推荐配置250 ms)
CFST_TL=250
#平均延迟下限；只输出高于指定平均延迟的 IP，可与其他上限/下限搭配、过滤假墙 IP；(默认 0 ms 这里推荐配置40)
CFST_TLL=20
#下载速度下限；只输出高于指定下载速度的 IP，凑够指定数量 [-dn] 才会停止测速；(默认 0.00 MB/s 这里推荐5.00MB/s)
CFST_SL=5
#初次输出文件，筛选初次测速IP
CFST_CSV=result.csv
#IP对比输出文件，与原IP进行对比后输出IP文件名
CFST_CSV2=DCF.csv
#测速端口
CF_POST=443
#####################################################################################################
##TG推送配置
#选择TG消息推送是否开启true为开启推送，为false将不会推送
tg=false
##TG推送设置
#（填写即为开启推送，未填写则为不开启）
#提示，如果openwrt中，请先执行./plug.sh命令安装相应模块，不然会推送失败
#TG机器人token 例如：123456789:ABCDEFG...
telegramBotToken=xxxxxxxxxxx:xxxxxxxxxxxxxxxxxxxxx
#用户ID或频道、群ID 例如：123456789
telegramBotUserId=xxxxxxxxxxx
##TGlink设置，默认：api.telegram.org
telegramlink=xxx.xxxxxxxx.xxxxxxx
#####################################################################################################
##杂项配置
#本地IP检测，如有公网IP，需动态解析请打开此开关，与优选IP不能同时使用
#使用此请关闭ipget和CloudflareST_speed，开启为true，关闭为false
localIP=false
#如果不开ipget，就指定需要更新到DNS平台的ip，如ipAddr520=1.1.1.1
ipAddr520=""
#休眠时间，1200也就是20分钟检测一次IP地址是否可用，当localIP开启时将指定时间检测本地IP是否变化
sltime=1200
#####################################################################################################
##IP地址文件配置
#关于是否下载CloudflareST测速工具，ip文件地址，默认必开
ipget=false
#基本IPv4ip获取地址
IP_txt="https://raw.gitmirror.com/XIU2/CloudflareSpeedTest/master/ip.txt"
#基本IPv6地址
IPv6_txt="https://raw.gitmirror.com/XIU2/CloudflareSpeedTest/master/ipv6.txt"
#优选IPv4ip获取地址如:https://xxxxxxxxxxxxxxxxxx/main/best-ip.txt
IPbest_txt=""
#优选IPv4ip网页获取地址如:https://xxxxxxxxxx/ipv4.php，如果出错请留空
IPbest_txt2=""
EOF
echo "请修改文件后,重新启动" >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
tail -f /dev/null
else
    echo "config文件已存在" >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
fi
source /opt/config
if [ "$localIP" = "true" ]; then
ipAddr=`curl -s http://ip.3322.net`
fi
if [ "$IP_ADDR" = "ipv4" ] ; then
    record_type="A"
else
    record_type="AAAA"
fi
run(){
if [ "$ipget" = "false" ] ; then
		echo "按要求未进行ip测速下载准备服务";
else
arch=$(uname -m)
case $arch in
    i386) filename="CloudflareST_x86" ;;
    aarch64) filename="CloudflareST_arm7" ;;
    arm64) filename="CloudflareST_arm64" ;;
    x86_64) filename="CloudflareST_amd64" ;;
    *)
        echo "没有该系统架构运行包"
        exit 1
        ;;
esac
if [ ! -f "$filename" ]; then
    wget -q "https://gitee.com/wdfing/cfddns/raw/master/$filename"
else
    echo "$filename 已存在，无需下载"
fi
chmod a+x "$filename"
if [ "$IP_ADDR" = "ipv4" ] ; then
wget -q $IP_txt -O - > ip.txt
wget -q $IPbest_txt -O - > IPlus.txt
sed -i '/^#/d' IPlus.txt
echo >> IPlus.txt
wget -q $IPbest_txt2 -O - | sed 's/<br>/\n/g' >> IPlus.txt
sed -i '/^#/d' ip.txt
else
wget -q $IPv6_txt
fi
fi
}
if [ "$numip" > "$CFST_DN" ] ; then
    CFST_DN=$((numip + 3))
fi
cf_ip_speed(){
if [ "$CloudflareST_speed" = "false" ] ; then
	echo "按要求未进行CFIP测速";
else
if [ "$cf" = "true" ] ; then
    CFIPget=$hostname;
    listDnsipget="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=${record_type}&name=${CFIPget}";
    res234=$(curl -s -X GET "$listDnsipget" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json");
    CFIP2=$(echo "$res234" | jq -r ".result[0].content");
    echo >> IPlus.txt
    echo -e "$CFIP2\n" >> IPlus.txt
    echo "CFDNSIP获取成功：$CFIP2"
fi
if [ "$ali" = "true" ] ; then
urlencode() {
    local string="$1"
    echo -n "$string" | jq -s -R -r @uri
}
send_request() {
    local action="$1"
    local params="$2"
    local args="AccessKeyId=$AliDDNS_AK&Action=$action&Format=json&$params&Version=2015-01-09"
    local hash=$(echo -n "GET&%2F&$(urlencode "$args")" | openssl dgst -sha1 -hmac "$AliDDNS_SK&" -binary | openssl base64)
    curl -s "https://alidns.cn-hangzhou.aliyuncs.com/?$args&Signature=$(urlencode "$hash")"
}
get_ip() {
    grep '"Value"' | jq -r '.DomainRecords.Record[].Value'
}
query_recordid() {
    send_request "DescribeSubDomainRecords&DomainName=$AliDDNS_DomainName" "RR=$AliDDNS_SubDomainName&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&SubDomain=$AliDDNS_SubDomainName.$AliDDNS_DomainName&Timestamp=$timestamp&Type=$record_type"
}
    timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
    AliIP2=`query_recordid A | get_ip`
    echo >> IPlus.txt
    echo -e "$AliIP2\n" >> IPlus.txt
    echo "AliDNSIP获取成功：$AliIP2"
fi
if [ "$DNSpod" = "true" ] ; then
domainipget=$(curl -s https://dnsapi.cn/Domain.List -d "login_token=$ID,$TOKEN" | jq -r '.domains[] | select(.punycode == "'$domain'")'  | jq .id)
recordipget=$(curl -s https://dnsapi.cn/Record.List -d "login_token=$ID,$TOKEN&domain_id=$domainipget"  | jq -r '.records[] | select(.name == "'$sub_domain'")' | jq -r '. | select(.type == "A")' | jq .id)
recordidget=$(echo $recordipget | sed 's/\"//g')
DNSpodIP2=`curl -s https://dnsapi.cn/Record.Info -d "login_token=$ID,$TOKEN&format=json&domain_id=${domainipget}&record_id=${recordidget}&remark="|awk -F '"value"' '{print $2}'|awk -F "\"" '{print $2}'`
echo >> IPlus.txt
echo -e "$DNSpodIP2\n" >> IPlus.txt
echo "DNSpodDNSIP获取成功：$DNSpodIP2"
fi
num=${#hostname[*]};
if [ "$CFST_DN" -le $num ] ; then
	CFST_DN=$num;
fi
CFST_P=$CFST_DN;
if [ "$IP_ADDR" = "ipv6" ] ; then
    if [ ! -f "ipv6.txt" ]; then
        echo "当前工作模式为ipv6，请配置ipv6.txt下载链接";
        exit 2;

        else
            echo "当前工作模式为ipv6";
    fi
    else
        echo "当前工作模式为ipv4";
fi
if [[ "$CFST_URL" == http* ]] ; then
	CFST_URL_R="-url $CFST_URL";
else
	CFST_URL_R="";
fi
if [ "$IP_ADDR" = "ipv6" ] ; then
    ./$filename $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -tll $CFST_TLL -sl $CFST_SL -tp $CF_POST -p $CFST_P -o $CFST_CSV2 -f ipv6.txt
    else
    ./$filename $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -tll $CFST_TLL -sl $CFST_SL -tp $CF_POST -p $CFST_P 
fi
echo "测速完毕";
if [ "$numip" = "1" ] ; then
if [ "$IP_ADDR" = "ipv4" ] ; then
echo "二次对比优选";
IP1=$(sed -n "$((x + 2)),1p" result.csv | awk -F, '{print $1}');
echo >> IPlus.txt
echo -e "$IP1\n" >> IPlus.txt
./$filename $CFST_URL_R -f IPlus.txt -sl $CFST_SL -tp $CF_POST -o $CFST_CSV2
fi
ipAddr=$(sed -n "$((x + 2)),1p" $CFST_CSV2 | awk -F, '{print $1}');
fi
fi
}
cf_ip_ddns(){
if [ "$cf" = "false" ] ; then
	echo "按要求未进行CF-IP推送";
else
echo "开始更新CF域名......";
CDNhostname=$hostname;
if [ "$numip" = 1 ] ; then
listDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=${record_type}&name=${CDNhostname}";
createDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records";
res=$(curl -s -X GET "$listDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json");
recordId=$(echo "$res" | jq -r ".result[0].id");
recordIp=$(echo "$res" | jq -r ".result[0].content");
res=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json");
resSuccess=$(echo "$res" | jq -r ".success");
if [[ $resSuccess != "true" ]]; then
    pushmessage="登陆错误,检查cloudflare账号信息填写是否正确！"
    Tg_push_IP;
    exit 1;
fi
if [[ $recordIp = "$ipAddr" ]]; then
echo -e "----->CFIP未更新<------\n获取IP与云端相同\n域名：$CDNhostname\n原IP：$recordIp" >> informlog;
echo "未更新"
else
if [[ $recordId = "null" ]]; then
    res=$(curl -s -X POST "$createDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json" --data "{\"type\":\"$record_type\",\"name\":\"$CDNhostname\",\"content\":\"$ipAddr\",\"proxied\":$proxy}");
    resSuccess=$(echo "$res" | jq -r ".success");
else
    updateDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${recordId}";
    res=$(curl -s -X PUT "$updateDnsApi"  -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json" --data "{\"type\":\"$record_type\",\"name\":\"$CDNhostname\",\"content\":\"$ipAddr\",\"proxied\":$proxy}");
    resSuccess=$(echo "$res" | jq -r ".success");
fi
listDnsApi1="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=${record_type}&name=${CDNhostname}";
createDnsApi1="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records";
res1=$(curl -s -X GET "$listDnsApi1" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json");
recordId1=$(echo "$res1" | jq -r ".result[0].id");
recordIp1=$(echo "$res1" | jq -r ".result[0].content");
if [[ $recordIp1 = "$ipAddr" ]]; then
    echo -e "----->CF更新成功<------\n域名：$CDNhostname\n原IP：$recordIp\n新IP：$ipAddr" >> informlog;
    echo "更新成功"
else
    echo -e "----->CF更新失败<------\n域名：$CDNhostname" >> informlog;
    echo "更新失败,请检查网络，账户以及账户秘钥，配置是否正确！！！"
fi
fi
else
listDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=${record_type}&name=${CDNhostname}"
res=$(curl -s -X GET "$listDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json")
resSuccess=$(echo "$res" | jq -r ".success")
if [[ $resSuccess != "true" ]]; then
    pushmessage="登录错误，请检查 Cloudflare 账号信息填写是否正确！"
    Tg_push_IP
    exit 1
fi
existingRecordsCount=$(echo "$res" | jq -r '.result | length')
record_ids=$(echo "$res" | jq -r '.result[].id')
if [[ $existingRecordsCount -eq $numip ]]; then
    for ((i = 0; i <= $numip; i++)); do
        numh=2+i
        ipAddrm=$(sed -n "$((x + $numh)),1p" $CFST_CSV | awk -F, '{print $1}')
        current_record_id=$(echo "$record_ids" | sed -n "$((i + 1))p")
        updateDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${current_record_id}"
        res=$(curl -s -X PUT "$updateDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json" --data "{\"type\":\"$record_type\",\"name\":\"$CDNhostname\",\"content\":\"$ipAddrm\",\"proxied\":$proxy}")
        resSuccess=$(echo "$res" | jq -r ".success")
        resback=$(echo "$res" | jq -r ".errors[].message")
    if [[ $resSuccess == "true" ]]; then
        if [[ $i == 0 ]]; then
            echo -e "----->CF更新成功<------\n域名：$CDNhostname\nIP：$ipAddrm" >> informlog
        else
            echo -e "IP：$ipAddrm" >> informlog
        fi
    else
        if [[ $resback == "Record already exists." ]]; then
            echo -e "IP：$ipAddrm" >> informlog
        else
            if [[ $i == 0 ]]; then
                # echo "更新API地址：$updateDnsApi"
                # echo "更新API响应：$res"
                # echo "更新API成功标识：$resSuccess"
                echo -e "----->CF更新失败<------\n域名：$CDNhostname" >> informlog
                echo "操作失败，请检查网络、账户以及账户秘钥，配置是否正确！！！"
            fi
        fi
        
    fi
    done
    i = 0
else
    for ((i = 0; i < $existingRecordsCount; i++)); do
    delete_id=$(echo "$record_ids" | sed -n "$((i + 1))p")
    deleteDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${delete_id}"
    deleteres=$(curl -s -X DELETE "$deleteDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json")
    done
    for ((i = 0; i <= $numip; i++)); do
        numh=2+i
        ipAddrm=$(sed -n "$((x + $numh)),1p" $CFST_CSV | awk -F, '{print $1}')
        createDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records"
        res=$(curl -s -X POST "$createDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json" --data "{\"type\":\"$record_type\",\"name\":\"$CDNhostname\",\"content\":\"$ipAddrm\",\"proxied\":$proxy}")
        resSuccess=$(echo "$res" | jq -r ".success")
        resback=$(echo "$res" | jq -r ".errors[].message")
    if [[ $resSuccess == "true" ]]; then
        if [[ $i == 0 ]]; then
            echo -e "----->CF更新成功<------\n域名：$CDNhostname\nIP：$ipAddrm" >> informlog
        else
            echo -e "IP：$ipAddrm" >> informlog
        fi
    else
        if [[ $resback == "Record already exists." ]]; then
            echo -e "IP：$ipAddrm" >> informlog
        else
            if [[ $i == 0 ]]; then
            # echo "更新API地址：$createDnsApi"
            # echo "更新API响应：$res"
            # echo "更新API成功标识：$resSuccess"
            echo -e "----->CF更新失败<------\n域名：$CDNhostname" >> informlog
            echo "操作失败，请检查网络、账户以及账户秘钥，配置是否正确！！！"
            fi
        fi
    fi
    done
    i = 0
fi
fi
fi
}
ali_ip_ddns(){
if [ "$ali" = "false" ] ; then
    echo "按要求未进行ali推送"
else
    echo "开始更新ali域名......"
    sleep 3
    eqold6=0
    eqold4=0
    ALiDom="$AliDDNS_SubDomainName.$AliDDNS_DomainName"
    AliDDNS_LocalIP4=$ipAddr
    AliDDNS_LocalIP6=$ipAddr
urlencode() {
    local string="$1"
    echo -n "$string" | jq -s -R -r @uri
}
send_request() {
    local action="$1"
    local params="$2"
    local args="AccessKeyId=$AliDDNS_AK&Action=$action&Format=json&$params&Version=2015-01-09"
    local hash=$(echo -n "GET&%2F&$(urlencode "$args")" | openssl dgst -sha1 -hmac "$AliDDNS_SK&" -binary | openssl base64)
    curl -s "https://alidns.cn-hangzhou.aliyuncs.com/?$args&Signature=$(urlencode "$hash")"
}
get_recordid() {
    grep -Eo '"RecordId":"[0-9]+"' | cut -d':' -f2 | tr -d '"'
}
get_ip() {
    grep '"Value"' | jq -r '.DomainRecords.Record[].Value'
}
query_recordid() {
    send_request "DescribeSubDomainRecords&DomainName=$AliDDNS_DomainName" "RR=$AliDDNS_SubDomainName&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&SubDomain=$ALiDom&Timestamp=$timestamp&Type=$record_type"
}
update_record() {
    send_request "UpdateDomainRecord&DomainName=$AliDDNS_DomainName" "RR=$AliDDNS_SubDomainName&RecordId=$3&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$AliDDNS_TTL&Timestamp=$timestamp&Type=$record_type&Value=$(urlencode "$2")"
}
add_record() {
    send_request "AddDomainRecord&DomainName=$AliDDNS_DomainName" "RR=$AliDDNS_SubDomainName&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$AliDDNS_TTL&Timestamp=$timestamp&Type=$record_type&Value=$(urlencode "$2")"
}
if [ "$record_type" = "A" ]
then
timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
AliDDNS_DomainIP4=`query_recordid A | get_ip`
if [ "$AliDDNS_LocalIP4" = "$AliDDNS_DomainIP4" ]
then
echo -e "----->Ali未更新<------\n获取IP与云端相同\n域名：$ALiDom\n原IP：$AliDDNS_DomainIP4" >> informlog;
echo "未更新"
eqold4=0
else
eqold4=1
fi
else
timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
AliDDNS_DomainIP6=`query_recordid AAAA | get_ip`
echo "Ali解析IP：$AliDDNS_DomainIP6"
if [ "$AliDDNS_LocalIP6" = "$AliDDNS_DomainIP6" ]
then
echo -e "----->Ali未更新<------\n获取IP与云端相同\n域名：$ALiDom\n原IP：$AliDDNS_DomainIP6" >> informlog;
echo "未更新"
eqold6=0
else
eqold6=1
fi
fi
if [ $eqold4 -eq 1 ];then
timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
   if [ "$AliDDNS_RecordID4" = "" ]
   then
       AliDDNS_RecordID4=`query_recordid A | get_recordid`
   fi
   if [ "$AliDDNS_RecordID4" = "" ]
   then
       AliDDNS_RecordID4=`add_record A $AliDDNS_LocalIP4 | get_recordid`
   else
       newA=`update_record A $AliDDNS_LocalIP4 $AliDDNS_RecordID4`
   fi
   
    timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
    Ali_newip=`query_recordid A | get_ip`
   if [ "$Ali_newip" != "$AliDDNS_LocalIP4" ]; then
       echo -e "----->Ali更新失败<------\n未获取到RecordID\n域名：$ALiDom" >> informlog;
       echo "更新失败,请检查网络，账户以及账户秘钥，配置是否正确！！！"
   else
       echo -e "----->Ali更新成功<------\n域名：$ALiDom\n原IP：$AliDDNS_DomainIP4\n新IP：$AliDDNS_LocalIP4" >> informlog;
       echo "更新成功"
   fi
fi
if [ $eqold6 -eq 1 ];then
timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
   if [ "$AliDDNS_RecordID6" = "" ]
   then
       AliDDNS_RecordID6=`query_recordid AAAA | get_recordid`
   fi
   
   if [ "$AliDDNS_RecordID6" = "" ]
   then
       AliDDNS_RecordID6=`add_record AAAA $AliDDNS_LocalIP6 | get_recordid`
   else
       newAAAA=`update_record AAAA $AliDDNS_LocalIP6 $AliDDNS_RecordID6`
        echo "Updated RecordID6 : $AliDDNS_RecordID6"
   fi
    timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
    Ali_newipv6=`query_recordid AAAA | get_ip`
   if [ "$Ali_newipv6" != "$AliDDNS_LocalIP6" ]; then
      echo -e "----->Ali更新失败<------\n未获取到RecordID\n域名：$ALiDom" >> informlog;
      echo "更新失败,请检查网络，账户以及账户秘钥，配置是否正确！！！"
   else
       echo -e "----->Ali更新成功<------\n域名：$ALiDom\n原IP：$AliDDNS_DomainIP6\n新IP：$AliDDNS_LocalIP6" >> informlog;
       echo "更新成功"
   fi
fi
fi
}
dnspod_ip_ddns(){
if [ "$DNSpod" = "false" ] ; then
    echo "按要求未进行dnspod推送"
else
echo "开始更新DNSpod域名......"
sleep 3;
if [ "$sub_domain" = "@" ];then
	HOST=$domain
else
    HOST=$sub_domain.$domain
fi
ip_addr_local=$ipAddr
domain_id=$(curl -s https://dnsapi.cn/Domain.List -d "login_token=$ID,$TOKEN" | jq -r '.domains[] | select(.punycode == "'$domain'")'  | jq .id)
record_id_tmp=$(curl -s https://dnsapi.cn/Record.List -d "login_token=$ID,$TOKEN&domain_id=$domain_id"  | jq -r '.records[] | select(.name == "'$sub_domain'")' | jq -r '. | select(.type == "A")' | jq .id)
record_id=$(echo $record_id_tmp | sed 's/\"//g')
ip_addr_dns=`curl -s https://dnsapi.cn/Record.Info -d "login_token=$ID,$TOKEN&format=json&domain_id=${domain_id}&record_id=${record_id}&remark="|awk -F '"value"' '{print $2}'|awk -F "\"" '{print $2}'`
if [ "$ip_addr_local" = "$ip_addr_dns" ]
then
echo -e "----->DNSpodIP未更新<------\n获取IP与云端相同\n域名：$HOST\n原IP：$ip_addr_dns" >> informlog;
echo "未更新"
else
ret_code=`curl -s https://dnsapi.cn/Record.Modify -d "login_token=$ID,$TOKEN&format=json&domain_id=${domain_id}&record_id=${record_id}&record_type=${record_type}&record_line=默认&ttl=${DNSpod_TTL}&sub_domain=${sub_domain}&value=${ip_addr_local}&mx=0"|awk -F '"code"' '{print $2}'|awk -F "\"" '{print $2}'`
if [ "$ret_code" = "1" ]
    then
        echo -e "----->DNSpod更新成功<------\n域名：$HOST\n原IP：$ip_addr_dns\n新IP：$ip_addr_local" >> informlog;
        echo "更新成功"
    else
        echo -e "----->DNSpod更新失败<------\n域名：$HOST" >> informlog;
        echo "更新失败,请检查网络，账户以及账户秘钥，配置是否正确！！！"
    fi
fi
fi
}
Tg_push_IP(){
if [ "$tg" = "false" ] ; then
	echo "按要求未进行tg推送";
else
pushmessage=$(cat informlog) > /dev/null;
echo "即将开始推送"
sleep 3;
[ "$telegramlink" = "" ] && telegramlink=api.telegram.org
echo $pushmessage
message_text=$pushmessage
URL="https://${telegramlink}/bot${telegramBotToken}/sendMessage"
if [[ -z ${telegramBotToken} ]]; then
   echo "未配置 TG 推送"
else
   retry_count=0
   while true; do
      res=$(timeout 20s curl -s -X POST $URL -d chat_id=${telegramBotUserId} -d text="${message_text}")
      if [ $? == 124 ]; then
         echo 'TG API 请求超时，请检查网络是否重启完成并是否能够访问 TG'          
         exit 1
      fi
      resSuccess521=$(echo "$res" | jq -r ".ok")
      if [[ $resSuccess521 = "true" ]]; then
         echo "TG 推送成功"
         break
      else
         ((retry_count++))
         if [ $retry_count -ge 5 ]; then
            echo "TG 推送失败，已重试 $retry_count 次，请检查 TG 机器人 token 和 ID"
            exit 1
         else
            echo "TG 推送失败，正在进行第 $retry_count 次重试..."
            sleep 2
         fi
      fi
   done
fi
fi
}

if [ -z "$ipAddr520" ]; then
{
    run
    cf_ip_speed
    cf_ip_ddns
    ali_ip_ddns
    dnspod_ip_ddns
    Tg_push_IP
} >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
else
ipAddr=$ipAddr520
{
    cf_ip_ddns
    ali_ip_ddns
    dnspod_ip_ddns
    Tg_push_IP
} >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
exit 0;
fi
if [ "$numip" = "1" ] ; then
while true; do
    source /opt/config
    if [ "$localIP" = "true" ] ; then
        ipAddr1=$(curl -s http://ip.3322.net)
        if [ "$ipAddr" = "$ipAddr1" ] ; then
            echo -e "$(date): 本地IP与公网IP相同..." >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
        else
            if [ -z "$ipAddr" ]; then
                echo -e "$(date): 本地IP为空，请检查网络配置..." >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
            else
                echo -e "$(date): 本地IP与公网IP不同，将执行IP更新..." >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
                {
		    rm -rf ip.txt ipv6.txt informlog
                    cf_ip_ddns
                    ali_ip_ddns
                    dnspod_ip_ddns
                    Tg_push_IP
                } >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
            fi
        fi
    else
        DCF_file="/root/DCF.csv"
        if [ ! -e "$DCF_file" ]; then
	    echo -e "未检测到测速后的文件，检查配置是否正确，将休眠10分钟，请手动暂停容器！！！" >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
	    echo -e "配置文件填写完成后，请手动重启！！！" >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
	    sleep 600
        else
            IPnew=$(sed -n "$((x + 2)),1p" "$DCF_file" | awk -F, '{print $1}')
            if nc -zv -w 2 "$IPnew" "$CF_POST" &> /dev/null; then
    		echo -e "$(date): IP $IPnew 可正常使用...." >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
	    else
    		echo -e "$(date): IP $IPnew 不可用，将执行IP更新..." >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
		    {
		        rm -rf ip.txt ipv6.txt informlog
		        run
		        cf_ip_speed
		        cf_ip_ddns
		        ali_ip_ddns
		        dnspod_ip_ddns
		        Tg_push_IP
		    } >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
	    fi
        fi
    fi
    echo -e "休眠：$sltime秒" >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
    sleep "$sltime"
done
else
    while true; do
    	echo -e "休眠：$sltime秒" >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
        sleep "$sltime"
        result_file="result.csv"
        if [ ! -e "$result_file" ]; then
            echo -e "未检测到 $result_file 文件，检查配置是否正确，将退出！！！" >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
            exit 0
        else
        {
		    rm -rf ip.txt ipv6.txt informlog
                    run
                    cf_ip_speed
                    cf_ip_ddns
                    ali_ip_ddns
                    dnspod_ip_ddns
                    Tg_push_IP
        } >> /opt/ddns_log/$(date +"%Y-%m-%d").txt
        fi
    done
fi
tail -f /dev/null
