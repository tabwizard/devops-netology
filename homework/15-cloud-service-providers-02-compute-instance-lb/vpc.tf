resource "yandex_vpc_network" "wizard-netology-vpc" {
  name = "wizard-netology-vpc"
}

resource "yandex_vpc_subnet" "public-a" {
  name           = "public-a"
  zone           = var.zones[0]
  network_id     = yandex_vpc_network.wizard-netology-vpc.id
  v4_cidr_blocks = ["${var.public_cidr[0]}"]
}

resource "yandex_vpc_subnet" "public-b" {
  name           = "public-b"
  zone           = var.zones[1]
  network_id     = yandex_vpc_network.wizard-netology-vpc.id
  v4_cidr_blocks = ["${var.public_cidr[1]}"]
}