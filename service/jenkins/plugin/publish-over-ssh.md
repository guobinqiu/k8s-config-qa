# Configure `Publish over SSH` plugins

1. Generate a PEM formatted RSA key pair

	```bash
	kubectl exec -it jenkins-7f8b6fdc77-76m7k /bin/bash
	cd $JENKINS_HOME
	ssh-keygen -m PEM -t rsa -b 4096
	```
	
2. Fill path of `id_rsa` to your Jenkins input box at `Manage Jenkins > Configure System > Publish over SSH > Path to key`

3. Copy content of `id_rsa.pub` to your VM `~/.ssh/authorized_keys` file
