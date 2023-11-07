terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "1.5.7"


  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "askarpoff-bucket"
    region   = "ru-central1-b"
    key      = "diplomstate/diplom.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true

  }
}

provider "yandex" {
  service_account_key_file = file("~/service_account_key_file.json")
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = "ru-central1-b"
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}




