resource "yandex_vpc_network" "diplom-net" {
  name = "diplom-net"
}

resource "yandex_vpc_subnet" "diplom-subnet-a" {
  v4_cidr_blocks = ["10.10.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom-net.id
}

resource "yandex_vpc_subnet" "diplom-subnet-b" {
  v4_cidr_blocks = ["10.10.11.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diplom-net.id
}

resource "yandex_vpc_subnet" "diplom-subnet-c" {
  v4_cidr_blocks = ["10.10.12.0/24"]
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.diplom-net.id
}