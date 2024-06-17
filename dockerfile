FROM docker:27.0.0-rc.1-cli

# Install build dependencies and general utilities
RUN apk update && apk upgrade && \
    apk add --no-cache bash curl git jq 

# # Create a non-root user and set permissions
# RUN adduser -D developer

# Set working directory
WORKDIR /ANa 

# Add the ana command to the path
RUN ln -s /ANa/cli/ana.sh /usr/local/bin/ana

# # Switch to the developer user
# USER developer

# Set a custom prompt for the developer user
RUN echo "PS1='\[\e[32m\]\u@ana:\w\[\e[0m\]$ '" >> /root/.bashrc

CMD ["bash"]
