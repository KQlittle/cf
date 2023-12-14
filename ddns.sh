#!/bin/bash

run(){
# 获取系统架构
arch=$(uname -m)
# 根据架构选择文件名
case $arch in
    x86_64) filename="CloudflareST_x86" ;;
    aarch64) filename="CloudflareST_arm7" ;;
    arm) filename="CloudflareST_arm64" ;;
    amd64) filename="CloudflareST_amd64" ;;
    *)
        echo "没有该系统架构运行包"
        exit 1
        ;;
esac
# 下载文件（如果文件不存在）
if [ ! -f "$filename" ]; then
    wget "https://gitee.com/wdfing/cfddns/raw/master/$filename"
else
    echo "$filename 已存在，无需下载"
fi
chmod a+x "$filename"
source /opt/config
rm -rf ip.xt
wget $IP_txt
wget $IPv6_txt
sed -i '/^#/d' ip.txt
}

cf_ip_ddns(){
ipv4Regex="((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])";
#默认关闭小云朵
proxy="false";
#验证cf账号信息是否正确
res=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json");
resSuccess=$(echo "$res" | jq -r ".success");
if [[ $resSuccess != "true" ]]; then
    pushmessage="登陆错误,检查cloudflare账号信息填写是否正确！"
    Tg_push_IP;
    exit 1;
fi
echo "Cloudflare账号验证成功";
#获取域名填写数量
num=${#hostname[*]};
#判断优选ip数量是否大于域名数，小于则让优选数与域名数相同
if [ "$CFST_DN" -le $num ] ; then
	CFST_DN=$num;
fi
CFST_P=$CFST_DN;
#判断工作模式
if [ "$IP_ADDR" = "ipv6" ] ; then
    if [ ! -f "ipv6.txt" ]; then
        echo "当前工作模式为ipv6，但该目录下没有【ipv6.txt】，请配置【ipv6.txt】。下载地址：https://github.com/XIU2/CloudflareSpeedTest/releases";
        exit 2;
        else
            echo "当前工作模式为ipv6";
    fi
    else
        echo "当前工作模式为ipv4";
fi

#读取配置文件中的客户端
if  [ "$clien" = "6" ] ; then
	CLIEN=bypass;
elif  [ "$clien" = "5" ] ; then
		CLIEN=openclash;
elif  [ "$clien" = "4" ] ; then
	CLIEN=clash;
elif  [ "$clien" = "3" ] ; then
		CLIEN=shadowsocksr;
elif  [ "$clien" = "2" ] ; then
			CLIEN=passwall2;
			else
			CLIEN=passwall;
fi

#判断是否停止科学上网服务
if [ "$pause" = "false" ] ; then
	echo "按要求未停止科学上网服务";
else
	/etc/init.d/$CLIEN stop;
	echo "已停止$CLIEN";
fi

#判断是否配置测速地址 
if [[ "$CFST_URL" == http* ]] ; then
	CFST_URL_R="-url $CFST_URL";
else
	CFST_URL_R="";
fi


if [ "$IP_ADDR" = "ipv6" ] ; then
    #开始优选IPv6
    ./$filename $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -tll $CFST_TLL -sl $CFST_SL -p $CFST_P -f ipv6.txt
    else
    #开始优选IPv4
    ./$filename $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -tll $CFST_TLL -sl $CFST_SL -p $CFST_P 
fi
echo "测速完毕";
if [ "$pause" = "false" ] ; then
		echo "按要求未重启科学上网服务";
		sleep 3s;
else
		/etc/init.d/$CLIEN restart;
		echo "已重启$CLIEN";
		echo "为保证cloudflareAPI连接正常 将在30秒后开始更新域名解析";
		sleep 3s;
fi
#开始循环
echo "正在更新域名，请稍后...";
x=0;
while [[ ${x} -lt $num ]]; do
    #优选域名
    CDNhostname=${hostname[$x]};
    #调取CFAPI
    listDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=${recordType}&name=${CDNhostname}";
    createDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records";

    res=$(curl -s -X GET "$listDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json");
    recordId=$(echo "$res" | jq -r ".result[0].id");
    recordIp=$(echo "$res" | jq -r ".result[0].content");

    #在次优选
    #将新旧IP写入文件
    echo "二次对比优选";
    IP1=$(sed -n "$((x + 2)),1p" result.csv | awk -F, '{print $1}');
    IP2=$recordIp
    echo -e "$IP1\n$IP2" > IPlus.txt
    echo >> IPlus.txt
    wget $IPbest_txt -O - >> IPlus.txt
    sed -i '/^#/d' IPlus.txt
    echo >> IPlus.txt
    wget $IPbest_txt2 -O - | sed 's/<br>/\n/g' >> IPlus.txt
    if [ "$IP_ADDR" = "ipv6" ] ; then
    #开始优选IPv6
    ./$filename $CFST_URL_R -f ipv6.txt -sl $CFST_SL -o $CFST_CSV2
    else
    #开始优选IPv4
    ./$filename $CFST_URL_R -f IPlus.txt -sl $CFST_SL -o $CFST_CSV2
    fi
    #获取优选后的ip地址
    ipAddr=$(sed -n "$((x + 2)),1p" $CFST_CSV2 | awk -F, '{print $1}');
    pusha="新IP：$ipAddr"
    #开始DDNS
    if [[ $ipAddr =~ $ipv4Regex ]]; then
        recordType="A";
    else
        recordType="AAAA";
    fi


    if [[ $recordIp = "$ipAddr" ]]; then
    echo -e "----->IP未更新<------\n--------------------\n获取IP与云端相同\n域名：$CDNhostname\n原IP：$recordIp" > informlog;
    resSuccess=false;
    else
    if [[ $recordId = "null" ]]; then
        res=$(curl -s -X POST "$createDnsApi" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json" --data "{\"type\":\"$recordType\",\"name\":\"$CDNhostname\",\"content\":\"$ipAddr\",\"proxied\":$proxy}");
        resSuccess=$(echo "$res" | jq -r ".success");
    else
        updateDnsApi="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${recordId}";
        res=$(curl -s -X PUT "$updateDnsApi"  -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json" --data "{\"type\":\"$recordType\",\"name\":\"$CDNhostname\",\"content\":\"$ipAddr\",\"proxied\":$proxy}");
        resSuccess=$(echo "$res" | jq -r ".success");
    fi

    # 调用CFAPI检查是否更新成功
    listDnsApi1="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=${recordType}&name=${CDNhostname}";
    createDnsApi1="https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records";

    res1=$(curl -s -X GET "$listDnsApi1" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json");
    recordId1=$(echo "$res1" | jq -r ".result[0].id");
    recordIp1=$(echo "$res1" | jq -r ".result[0].content");

    if [[ $recordIp1 = "$ipAddr" ]]; then
        echo -e "----->更新成功<------\n--------------------\n域名：$CDNhostname\n原IP：$recordIp\n$pusha" > informlog;
    else
        echo -e "----->更新失败<------\n域名：$CDNhostname" > informlog;
    fi
    fi
    x=$((x + 1));
    sleep 3s;
 #会生成一个名为informlog的临时文件作为推送的内容。
done
}

ali_ip_ddns(){
echo "开始更新阿里域名。。。。。。"
sleep 3;

while true; do

ipAddr5=$ipAddr
AliDDNS_LocalIP="$ipAddr5"
# 设置解析使用的DNS服务器 (推荐使用 223.5.5.5/223.6.6.6 , 毕竟都是阿里家的东西)
AliDDNS_DomainServerIP="223.5.5.5"

ALiDom="$AliDDNS_SubDomainName.$AliDDNS_DomainName"

# 防止用户忘记设置参数导致程序报错，部分参数如果检测到空值，自动使用默认值
[ "$AliDDNS_LocalIP" = "" ] && AliDDNS_LocalIP="$ipAddr5"
[ "$AliDDNS_DomainServerIP" = "" ] && $AliDDNS_DomainServerIP="223.5.5.5"
[ "$AliDDNS_TTL" = "" ] && AliDDNS_TTL="600"
# 获取DDNS域名当前解析记录IP
AliDDNS_DomainIP=`nslookup $AliDDNS_SubDomainName.$AliDDNS_DomainName $AliDDNS_DomainServerIP 2>&1`
# 判断上一条命令的执行是否成功
if [ "$?" -eq "0" ]
then
    # 如果执行成功，分离出结果中的IP地址
    AliDDNS_DomainIP=`echo "$AliDDNS_DomainIP" | grep 'Address:' | tail -n1 | awk '{print $NF}'`
    # 进行判断，如果本次获取的新IP和旧IP相同，则进行休眠一分钟后再继续判断
    if [ "$AliDDNS_LocalIP" = "$AliDDNS_DomainIP" ]
    then
        echo -e "----->阿里未更新<------\n域名：$ALiDom\n原IP：$AliDDNS_DomainIP" >> informlog;
    break
    fi 
fi


# 如果IP发生变动，开始进行修改
# 生成时间戳
timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`
# URL加密函数
urlencode() {
    # urlencode <string>
    out=""
    while read -n1 c
    do
        case $c in
            [a-zA-Z0-9._-]) out="$out$c" ;;
            *) out="$out`printf '%%%02X' "'$c"`" ;;
        esac
    done
    echo -n $out
}
# URL加密命令
enc() {
    echo -n "$1" | urlencode
}
# 发送请求函数
send_request() {
    local args="AccessKeyId=$AliDDNS_AK&Action=$1&Format=json&$2&Version=2015-01-09"
    local hash=$(echo -n "GET&%2F&$(enc "$args")" | openssl dgst -sha1 -hmac "$AliDDNS_SK&" -binary | openssl base64)
    curl -s "http://alidns.aliyuncs.com/?$args&Signature=$(enc "$hash")"
}
# 获取记录值 (RecordID)
get_recordid() {
    grep -Eo '"RecordId":"[0-9]+"' | cut -d':' -f2 | tr -d '"'
}
# 请求记录值 (RecordID)
query_recordid() {
    send_request "DescribeSubDomainRecords" "SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&SubDomain=$AliDDNS_SubDomainName.$AliDDNS_DomainName&Timestamp=$timestamp"
}
# 更新记录值 (RecordID)
update_record() {
    send_request "UpdateDomainRecord" "RR=$AliDDNS_SubDomainName&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$AliDDNS_TTL&Timestamp=$timestamp&Type=A&Value=$AliDDNS_LocalIP"
}
# 添加记录值 (RecordID)
add_record() {
    send_request "AddDomainRecord&DomainName=$AliDDNS_DomainName" "RR=$AliDDNS_SubDomainName&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$AliDDNS_TTL&Timestamp=$timestamp&Type=A&Value=$AliDDNS_LocalIP"
}

# 判断RecordIP是否为空
if [ "$AliDDNS_RecordID" = "" ]
then
    AliDDNS_RecordID=`query_recordid | get_recordid`
fi
if [ "$AliDDNS_RecordID" = "" ]
then
    AliDDNS_RecordID=`add_record | get_recordid`
    echo "[$(date "+%G/%m/%d %H:%M:%S")] Added RecordID : $AliDDNS_RecordID"
else
    update_record $AliDDNS_RecordID
    echo "[$(date "+%G/%m/%d %H:%M:%S")] Updated RecordID : $AliDDNS_RecordID"
fi

# 输出最终结果
if [ "$AliDDNS_RecordID" = "" ]; then
    # 输出失败结果 (因为没有获取到RecordID)
    echo "[$(date "+%G/%m/%d %H:%M:%S")] DDNS Update Failed !"
else
    # 输出成功结果
    echo -e "----->阿里域名<------\n域名：$ALiDom\n更新：$AliDDNS_LocalIP" >> informlog;
fi
break
done
}


Tg_push_IP(){
pushmessage=$(cat informlog);
echo "即将开始推送"
sleep 3;
[ "$telegramlink" = "" ] && telegramlink=api.telegram.org
echo $pushmessage
message_text=$pushmessage
#解析模式，可选HTML或Markdown
# MODE='HTML'
#api接口
URL="https://${telegramlink}/bot${telegramBotToken}/sendMessage"

if [[ -z ${telegramBotToken} ]]; then
   echo "未配置 TG 推送"
else
   retry_count=0
   while true; do
      # 发送消息
      res=$(timeout 20s curl -s -X POST $URL -d chat_id=${telegramBotUserId} -d text="${message_text}")
      if [ $? == 124 ]; then
         echo 'TG API 请求超时，请检查网络是否重启完成并是否能够访问 TG'          
         exit 1
      fi
      # 解析响应
      resSuccess=$(echo "$res" | jq -r ".ok")
      if [[ $resSuccess = "true" ]]; then
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
}
run
cf_ip_ddns
ali_ip_ddns
Tg_push_IP
exit 0;
