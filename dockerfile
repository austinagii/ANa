FROM docker:27.0.0-rc.1-cli

RUN apk update && apk upgrade

RUN apk add bash 

WORKDIR /ANa 

RUN ln -s /ANa/cli/ana.sh /usr/local/bin/ana

CMD ["bash"]
