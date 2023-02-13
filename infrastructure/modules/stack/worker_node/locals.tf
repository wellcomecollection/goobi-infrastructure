locals {
  secrets = {
    IA_USERNAME = var.ia_username_key
    IA_PASSWORD = var.ia_password_key
    DB_USER     = var.db_user_key
    DB_PASSWORD = var.db_password_key
  }
}
