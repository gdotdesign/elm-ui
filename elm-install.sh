n=0
until [ $n -ge 5 ]
do
  elm package install -y && break
  n=$[$n+1]
  sleep 15
done
