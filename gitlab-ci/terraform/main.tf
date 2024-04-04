terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  # version                  = 0.35
  #service_account_key_file = var.service_account_key_file
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

data "yandex_compute_image" "ubuntu-image" {
  family = "ubuntu-1804-lts"
}

resource "yandex_compute_instance" "gitlab-ci-vm" {
  name  = "gitlab-ci-vm-${count.index}"
  count = var.count_of_instances

  resources {
    cores  = var.cpu
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      # image_id = data.yandex_compute_image.ubuntu-image.image_id
      size     = 10
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

locals {
  names = yandex_compute_instance.gitlab-ci-vm.*.name
  ips   = yandex_compute_instance.gitlab-ci-vm.*.network_interface.0.nat_ip_address
}

# Invetrory for ansible and run playbook
resource "local_file" "inventory" {
  content = templatefile("inventory.tpl",
    {
      #k8s_hosts = yandex_compute_instance.gitlab-ci-vm.*.network_interface.0.nat_ip_address
      names = local.names,
      addrs = local.ips,
    }
  )
  filename = "../ansible/inventory.ini"

  provisioner "local-exec" {
    command = "sleep 180"
  }

  provisioner "local-exec" {
    command     = "ansible-playbook playbook.yml"
    working_dir = "../ansible"
  }
}
