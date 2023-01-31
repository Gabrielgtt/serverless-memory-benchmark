#!/bin/bash/

source ./vars.env

if [[ -z "${DISCORD_WEBHOOK_URL}" ]]; then
    echo "Env variable DISCORD_WEBHOOK_URL is empty! Make sure to set it (e.g., in .bashrc)."
    exit 0
fi

discord_url=$DISCORD_WEBHOOK_URL

STATUS="ok"

while getopts m:d:t:s: flag
do
        case "${flag}" in
                m) MESSAGE=${OPTARG};;
                d) DESCRIPTION=${OPTARG};;
                t) TITLE=${OPTARG};;
                s) STATUS=${OPTARG};;
        esac
done

COLOR=5763719

case $STATUS in
    ok) COLOR=5763719;;
    error) COLOR=15548997;;
    warning) COLOR=16705372;;
esac


generate_post_data() {
    cat <<EOF
    {
      "content": "$MESSAGE",
      "embeds": [{
        "title": "$TITLE",
        "description": "$DESCRIPTION",
        "color": "$COLOR"
      }]
    }
EOF
}

curl -H "Content-Type: application/json" -X POST -d "$(generate_post_data)" $discord_url
