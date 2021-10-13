FROM ubuntu:21.10 as build
# I am a comment and I have to be in my own line

ENV MESSAGE="Hello Docker!"

# copy the local script to the container
COPY example.bash /usr/local/bin/
 
# Note we would not need the RUN command here! 
# We can use chmod directly in the COPY command
# COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
RUN chmod +x /usr/local/bin/example.bash

CMD ["/bin/bash", "/usr/local/bin/example.bash"]

# Build and run:
# docker build -t learning/myimage:1.0 .
# docker run --rm learning/myimage:1.0