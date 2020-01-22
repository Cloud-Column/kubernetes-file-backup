FROM debian:10.2-slim
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get clean
RUN pip3 install s3cmd
COPY entrypoint.sh ~/entrypoint.sh
CMD ~/entrypoint.sh