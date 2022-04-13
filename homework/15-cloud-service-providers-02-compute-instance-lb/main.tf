locals {
  cloud_id  = "b1gqrp1i6qksiv3fsd7p"
  folder_id = "b1gtnhq0jsadaquuvpi6"
}

provider "yandex" {
  service_account_key_file = "/home/wizard/.yckey.json"
  cloud_id                 = local.cloud_id
  folder_id                = local.folder_id
  zone                     = var.zones[1]
}

resource "yandex_iam_service_account" "sa-tf-wizard" {
  folder_id = local.folder_id
  name      = "sa-tf-wizard"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-tf-editor" {
  folder_id = local.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-tf-wizard.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-tf-wizard-key" {
  service_account_id = yandex_iam_service_account.sa-tf-wizard.id
}

