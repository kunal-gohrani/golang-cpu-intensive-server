sudo apt-get update -y
sudo apt-get install -y git make golang-go
git clone https://github.com/kunal-gohrani/golang-cpu-intensive-server /home/ubuntu/app
sudo chown -R ubuntu /home/ubuntu/app
cd /home/ubuntu/app/golang-server
make build
nohup ./dist/golang-webserver & 
sleep 5 # this is needed to give the background job above time to start