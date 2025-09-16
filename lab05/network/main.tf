resource "google_compute_network" "lab_vpc" {
  name                    = "lab-vpc"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "lab_subnet" {
  name          = "lab-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east1"
  network       = google_compute_network.lab_vpc.id
}
resource "google_compute_firewall" "default" {
  name          = "fw-allow-health-check"
  direction     = "INGRESS"
  network       = google_compute_network.lab_vpc.id
  priority      = 1000
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
}
resource "google_compute_global_address" "lab_lb_ip" {
  name       = "lb-ipv4-1"
  ip_version = "IPV4"
}
resource "google_compute_router" "lab_router" {
  name    = "lab-router"
  network = google_compute_network.lab_vpc.name
  region  = "us-east1"
}
resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.lab_router.name
  region                             = google_compute_router.lab_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}