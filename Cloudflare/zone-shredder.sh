APIKEY=
ZONEID=

curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records" -H "Authorization: Bearer $APIKEY" -H "Content-Type: application/json" |python -m json.tool |grep -w id | awk '{print $2}' |sed 's/"//g' > /tmp/ids

sed -i 's/,//g' /tmp/ids

cat /tmp/ids

while read p; do
        curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$p" -H "Authorization: Bearer $APIKEY" -H "Content-Type: application/json"
        echo "$p has been deleted"
done < /tmp/ids

curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONEID" -H "Authorization: Bearer $APIKEY" -H "Content-Type: application/json"
