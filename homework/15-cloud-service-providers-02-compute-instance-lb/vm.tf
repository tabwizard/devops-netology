resource "yandex_compute_instance_group" "wizard-vm-group" {
  name                = "wizard-vm-group"
  folder_id           = local.folder_id
  service_account_id  = yandex_iam_service_account.sa-tf-wizard.id
  deletion_protection = false
  depends_on          = [yandex_resourcemanager_folder_iam_member.sa-tf-editor]

  allocation_policy {
    zones = var.zones
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 3
    max_expansion   = 1
    max_deleting    = 1
  }


  instance_template {
    platform_id        = "standard-v1"
    service_account_id = yandex_iam_service_account.sa-tf-wizard.id

    resources {
      memory        = 1
      cores         = 2
      core_fraction = 5
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        size     = 4
      }
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      network_id = yandex_vpc_network.wizard-netology-vpc.id
      subnet_ids = [yandex_vpc_subnet.public-a.id, yandex_vpc_subnet.public-b.id]
      nat        = true
    }

    metadata = {
      user-data = file("./bootstrap.sh")
      ssh-keys  = "ubuntu:${file("~/.ssh/yc/yc.pub")}"
    }
    network_settings {
      type = "STANDARD"
    }
  }
  // Instances health checking
  health_check {
    interval = 60
    timeout  = 2
    tcp_options {
      port = 80
    }
  }

  load_balancer {
    target_group_name = "wizard-vm-group"
  }
}