cp informix.service /etc/systemd/system/
cp sysconfig.informix /etc/sysconfig/informix
systemctl start informix
systemctl enable informix
