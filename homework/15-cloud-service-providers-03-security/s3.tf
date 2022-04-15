resource "yandex_storage_bucket" "wizards-tf-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-tf-wizard-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-tf-wizard-key.secret_key
  bucket     = "wizards-tf-bucket"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.wizard-kms-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "yandex_storage_object" "netology-picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-tf-wizard-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-tf-wizard-key.secret_key
  bucket     = yandex_storage_bucket.wizards-tf-bucket.id
  key        = "images.png"
  source     = "~/Netology/images.png"
  acl        = "public-read"
}
