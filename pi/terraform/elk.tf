resource "null_resource" "elasticsearch_install" {
  # Loop through each server
  for_each = toset(["node-1", "node-2", "node-3", "node-4"])

  # Connect via SSH
  connection {
    type     = "ssh"
    user     = "username"
    private_key = file("~/.ssh/id_rsa")
    host     = self.each.value
  }

  # Install and configure Elasticsearch
  provisioner "remote-exec" {
    inline = [
      "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
      "sudo apt-get install apt-transport-https",
      "echo 'deb https://artifacts.elastic.co/packages/7.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list",
      "sudo apt-get update && sudo apt-get install elasticsearch",
      "sudo sed -i 's/#cluster.name: my-application/cluster.name: Beehive/' /etc/elasticsearch/elasticsearch.yml",
      "sudo sed -i 's/#node.name: node-1/node.name: ${self.each.value}/' /etc/elasticsearch/elasticsearch.yml",
      "sudo sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml",
      "sudo sed -i 's/#http.port: 9200/http.port: 9200/' /etc/elasticsearch/elasticsearch.yml",
      "sudo systemctl start elasticsearch",
      "sudo systemctl enable elasticsearch"
    ]
  }
}

resource "null_resource" "kibana_install" {
  # Assuming Kibana on 1
  connection {
    type     = "ssh"
    user     = "username"
    private_key = file("~/.ssh/id_rsa")
    host     = "1"
  }

  # Install and configure Kibana (Do we need to escape the brackets?)
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install kibana",
      "sudo sed -i 's/#server.host: \"localhost\"/server.host: \"0.0.0.0\"/' /etc/kibana/kibana.yml",
      "sudo sed -i 's/#elasticsearch.hosts: [\"http://localhost:9200\"]/elasticsearch.hosts: [\"http://localhost:9200\"]/' /etc/kibana/kibana.yml",
      "sudo systemctl start kibana",
      "sudo systemctl enable kibana"
    ]
  }
}
