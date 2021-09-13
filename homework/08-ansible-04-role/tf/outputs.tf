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
