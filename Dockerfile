FROM node:lts-alpine

RUN apk --update --no-cache add curl bash file

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
