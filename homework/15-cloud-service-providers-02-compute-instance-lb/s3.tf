resource "yandex_storage_bucket" "wizards-tf-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-tf-wizard-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-tf-wizard-key.secret_key
  bucket     = "wizards-tf-bucket"
}

resource "yandex_storage_object" "netology-picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-tf-wizard-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-tf-wizard-key.secret_key
  bucket     = yandex_storage_bucket.wizards-tf-bucket.id
  key        = "images.png"
  source     = "~/Netology/images.png"
  acl        = "public-read"
}