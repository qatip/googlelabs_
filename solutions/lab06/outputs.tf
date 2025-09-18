output "bucket_console_url" {
  value       = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.media.name}?project=${var.project_id}"
  description = "Quick link to the bucket in the console"
}
