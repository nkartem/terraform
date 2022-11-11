import paramiko

command = "ls -a"
reboot = "sudo reboot"

host = "54.186.117.117"
username = "root"
password = "123456789"


client = paramiko.client.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(host, username=username, password=password)
_stdin, _stdout,_stderr = client.exec_command(reboot)
print(_stdout.read().decode())
client.close()