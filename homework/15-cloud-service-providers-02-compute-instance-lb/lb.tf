resource "yandex_lb_network_load_balancer" "wizard-nlb" {
  name = "wizard-nlb"

  listener {
    name = "wizard-nlb"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.wizard-vm-group.load_balancer[0].target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = ""
      }
    }
  }
}