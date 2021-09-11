terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}

provider "yandex" {
  token     = "AQAAAAAgZ5SAAATuwepD3czPO0Tcig5UC6l-26Q"
  cloud_id  = "b1gqrp1i6qksiv3fsd7p"
  folder_id = "b1gtnhq0jsadaquuvpi6"
  zone      = "ru-central1-b"
}

resource "yandex_compute_instance" "el-1-centos7" {
  name = "el-1-centos7"
  hostname = "el-1-centos7"
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83869rbingor0in0ui"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.wizsubnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
    ssh-keys  = "wizard:${file("~/.ssh/id_rsa.pub")}"
  }

}

resource "yandex_compute_instance" "el-2-ubuntu-2004-lts" {
  name = "el-2-ubuntu-2004-lts"
  hostname = "el-2-ubuntu-2004-lts"
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.wizsubnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
    ssh-keys  = "wizard:${file("~/.ssh/id_rsa.pub")}"
  }

}

resource "yandex_compute_instance" "kbn-1-centos7" {
  name = "kbn-1-centos7"
  hostname = "kbn-1-centos7"
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83869rbingor0in0ui"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.wizsubnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
    ssh-keys  = "wizard:${file("~/.ssh/id_rsa.pub")}"
  }

}

resource "yandex_compute_instance" "flb-1-ubuntu-2004-lts" {
  name = "flb-1-ubuntu-2004-lts"
  hostname = "flb-1-ubuntu-2004-lts"
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.wizsubnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
    ssh-keys  = "wizard:${file("~/.ssh/id_rsa.pub")}"
  }

}

resource "yandex_vpc_network" "wizard-network-1" {
  name = "wiznetwork1"
}

resource "yandex_vpc_subnet" "wizsubnet-1" {
  name           = "wizsubnet1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.wizard-network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_el-1-centos7" {
  value = yandex_compute_instance.el-1-centos7.network_interface.0.ip_address
}

output "internal_ip_address_el-2-ubuntu-2004-lts" {
  value = yandex_compute_instance.el-2-ubuntu-2004-lts.network_interface.0.ip_address
}

output "internal_ip_address_kbn-1-centos7" {
  value = yandex_compute_instance.kbn-1-centos7.network_interface.0.ip_address
}

output "internal_ip_address_flb-1-ubuntu-2004-lts" {
  value = yandex_compute_instance.flb-1-ubuntu-2004-lts.network_interface.0.ip_address
}

output "external_ip_address_el-1-centos7" {
  value = yandex_compute_instance.el-1-centos7.network_interface.0.nat_ip_address
}

output "external_ip_address_el-2-ubuntu-2004-lts" {
  value = yandex_compute_instance.el-2-ubuntu-2004-lts.network_interface.0.nat_ip_address
}

output "external_ip_address_kbn-1-centos7" {
  value = yandex_compute_instance.kbn-1-centos7.network_interface.0.nat_ip_address
}

output "external_ip_address_flb-1-ubuntu-2004-lts" {
  value = yandex_compute_instance.flb-1-ubuntu-2004-lts.network_interface.0.nat_ip_address
}
