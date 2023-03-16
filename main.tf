terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
}

resource "yandex_mdb_greenplum_cluster" "greenplum_cluster" {
  name               = "greenplum"
  description        = "Greenplum + dbtVault"
  environment        = "PRESTABLE"
  network_id         = yandex_vpc_network.default_network.id
  zone               = yandex_vpc_subnet.default_subnet.zone
  subnet_id          = yandex_vpc_subnet.default_subnet.id
  assign_public_ip   = true
  version            = "6.22"
  master_host_count  = 1
  segment_host_count = 2
  segment_in_host    = 1

  user_name     = "greenplum"
  user_password = var.greenplum_password

  security_group_ids = [yandex_vpc_security_group.test-sg-x.id]

  master_subcluster {
    resources {
      resource_preset_id = "s3-c2-m8"
      disk_size          = 20
      disk_type_id       = "network-ssd"
    }
  }
  segment_subcluster {
    resources {
      resource_preset_id = "s3-c2-m8"
      disk_size          = 30
      disk_type_id       = "network-ssd"
    }
  }

  access {
    web_sql = true
  }

  greenplum_config = {
    max_connections         = 395
    gp_workfile_compression = "false"
  }

}

resource "yandex_vpc_network" "default_network" {}

resource "yandex_vpc_subnet" "default_subnet" {
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.default_network.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_vpc_security_group" "test-sg-x" {
  network_id = yandex_vpc_network.default_network.id
  ingress {
    protocol       = "ANY"
    description    = "Allow incoming traffic from members of the same security group"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    description    = "Allow outgoing traffic to members of the same security group"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
