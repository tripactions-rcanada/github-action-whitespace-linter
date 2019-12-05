FROM node:lts-alpine

RUN apk --update --no-cache add curl=~7.66 jq=~1.6 bash file

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
