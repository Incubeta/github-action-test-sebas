FROM ubuntu:latest
LABEL authors="sebastiaan"

ENTRYPOINT ["top", "-b"]