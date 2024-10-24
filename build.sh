docker rm --force com-bank-core-eureka
docker rm $(docker ps --filter status=exited -q)
docker build -t dsilvamarsh/com-bank-core-eureka .

#docker run -p 8080:8080 com-bank-core-eureka