#!/bin/bash
SPECIFY_URL='http://localhost:8414'
USER='demouser'
PASS='demouser'
COOKIES=cookies.txt
QUERY=/api/specify/collectionobject/?catalognumber=144109

while [ $# -gt 0 ]; do
  case "$1" in
    --url*|-u*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      SPECIFY_URL="${1#*=}"
      ;;
    --user*|-n*)
      if [[ "$1" != *=* ]]; then shift; fi
      USER="${1#*=}"
      ;;
    --password*|-p*)
      if [[ "$1" != *=* ]]; then shift; fi
      PASS="${1#*=}"
      ;;
    --query*|-q*)
      if [[ "$1" != *=* ]]; then shift; fi
      QUERY="${1#*=}"
      ;;
    --help|-h)
      echo ""
      echo "Usage:"
      echo "-u --url\tBase url of the specify server ($SPECIFY_URL)"
      echo "-n --user\tYour specify username ($USER)"
      echo "-p --password\tYour password ($PASS)"
      echo "-q --query\tPath of the API-call ($QUERY)"
      echo ""
      echo "Remote example:"
      echo './query-specify.sh --url=https://specify-test-code.naturkundemuseum.berlin/ -n=YOUR_SPECIFY_USERNAME -p=YOUR_SPECIFY_PASSWORD -q="/api/specify/collectionobject/?catalognumber=dummy_1016"'
      echo ""
      exit 0
      ;;
    *)
      >&2 printf "Error: Invalid argument\n"
      exit 1
      ;;
  esac
  shift
done


# SOURCE: https://stackoverflow.com/questions/21306515/how-to-curl-an-authenticated-django-app/24376188#24376188

CURL_BIN="curl -c $COOKIES -b $COOKIES --referer $SPECIFY_URL/accounts/login/" > /dev/null

#echo -n "Django Auth: get csrftoken ..."
$CURL_BIN -s "$SPECIFY_URL/accounts/login/" > /dev/null
DJANGO_TOKEN="csrfmiddlewaretoken=$(grep csrftoken $COOKIES | sed 's/^.*csrftoken\s*//')"

#echo -n "perform login ..."
$CURL_BIN -s \
    -d "$DJANGO_TOKEN&username=$USER&password=$PASS" \
    -X POST \
    "$SPECIFY_URL/accounts/login/" > /dev/null

#echo -n "do something while logged in ..."
$CURL_BIN \
    -d "$DJANGO_TOKEN" \
    -X GET \
    "$SPECIFY_URL$QUERY"
    

#echo "logout"
rm $COOKIES
