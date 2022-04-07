terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.73.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = "/home/wizard/.yckey.json"
  cloud_id                 = "b1gqrp1i6qksiv3fsd7p"
  folder_id                = "b1gtnhq0jsadaquuvpi6"
  zone                     = "ru-central1-b"
}

resource "yandex_vpc_network" "wizard-netology-vpc" {
  name = "wizard-netology-vpc"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.wizard-netology-vpc.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.wizard-netology-vpc.id}"
  route_table_id = "${yandex_vpc_route_table.private-rt-to-nat.id}"
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_vpc_route_table" "private-rt-to-nat" {
  name       = "private-rt-to-nat"
  network_id = "${yandex_vpc_network.wizard-netology-vpc.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}

resource "yandex_compute_instance" "nat-instance" {
  name     = "nat-instance"
  hostname = "nat-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.public.id}"
    ip_address = "192.168.10.254"
    nat        = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }

}

resource "yandex_compute_instance" "public-centos7" {
  name     = "public-centos7"
  hostname = "public-centos7"
  
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
    subnet_id = "${yandex_vpc_subnet.public.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }

}

resource "yandex_compute_instance" "private-centos7" {
  name     = "private-centos7"
  hostname = "private-centos7"
  
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
    subnet_id = "${yandex_vpc_subnet.private.id}"
    nat       = false
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }

}