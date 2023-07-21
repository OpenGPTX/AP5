FROM amazoncorretto:11

# Update old and install new image packages
RUN yum update -y
RUN yum -y install shadow-utils

# Create container user
RUN groupadd -r containerUser && useradd -r -m -g containerUser containerUser
WORKDIR /home/containerUser

# Copy required files in the image
COPY fc-service-server-1.0.0.jar fc-service-server-1.0.0.jar
COPY start.sh start.sh

# Change current user
USER containerUser

EXPOSE 8081
ENTRYPOINT ["bash", "-c","./start.sh"]