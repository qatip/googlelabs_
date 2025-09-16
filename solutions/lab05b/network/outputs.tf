output "vpc-id" {
  description = "ID of the VPC"
  value       = google_compute_network.lab_vpc.id
}
output "lab-subnet" {
  description = "id of lab subnet"
  value       = google_compute_subnetwork.lab_subnet.id
}
output "lb-ip-id" {
  description = "ip id of lab load balancer"
  value       = google_compute_global_address.lab_lb_ip.id
}
output "lb-ip" {
  description = "ip of lab load balancer"
  value       = google_compute_global_address.lab_lb_ip.address
}