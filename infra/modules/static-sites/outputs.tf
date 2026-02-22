output "static_ip" {
  value = google_compute_global_address.ip.address
}

output "deployer_sa_email" {
  value = google_service_account.deployer.email
}

output "bucket_names" {
  value = { for k, v in google_storage_bucket.site : k => v.name }
}

output "certificate_states" {
  value = { for k, v in google_certificate_manager_certificate.site : k => v.managed[0].state }
}
