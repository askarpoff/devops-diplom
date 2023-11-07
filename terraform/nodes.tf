resource "yandex_kubernetes_node_group" "kubernetes-nodegroup-a" {
  cluster_id = yandex_kubernetes_cluster.regional_cluster_diplom.id
  name       = "kubernetes-nodegroup-a"
  instance_template {
    platform_id = "standard-v2"
    container_runtime {
      type = "containerd"
    }
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.diplom-subnet-a.id}"]
    }
    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 40
    }

    scheduling_policy {
      preemptible = true
    }
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }

  }
  scale_policy {
    auto_scale {
      min     = 1
      max     = 3
      initial = 1
    }
  }
  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }

}
resource "yandex_kubernetes_node_group" "kubernetes-nodegroup-b" {
  cluster_id = yandex_kubernetes_cluster.regional_cluster_diplom.id
  name       = "kubernetes-nodegroup-b"
  instance_template {
    platform_id = "standard-v2"
    container_runtime {
      type = "containerd"
    }
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.diplom-subnet-b.id}"]

    }
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      type = "network-hdd"
      size = 40
    }


    scheduling_policy {
      preemptible = true
    }
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
  }

  scale_policy {
    auto_scale {
      min     = 1
      max     = 3
      initial = 1
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-b"
    }
  }
}
resource "yandex_kubernetes_node_group" "kubernetes-nodegroup-c" {
  cluster_id = yandex_kubernetes_cluster.regional_cluster_diplom.id
  name       = "kubernetes-nodegroup-c"
  instance_template {
    platform_id = "standard-v2"
    container_runtime {
      type = "containerd"
    }
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.diplom-subnet-c.id}"]
    }
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      type = "network-hdd"
      size = 40
    }

    scheduling_policy {
      preemptible = true
    }
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }

  }
  scale_policy {
    auto_scale {
      min     = 1
      max     = 3
      initial = 1
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-c"
    }
  }
}