resource "google_compute_global_forwarding_rule" "http_forwarding" {
  name                  = "global-rule"
  target                = google_compute_target_http_proxy.http_proxy.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
  ip_address            = module.vpc.lb-ip-id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.http_url_map.id
}

resource "google_compute_url_map" "http_url_map" {
  name            = "url-map-target-proxy"
  default_service = google_compute_backend_service.backend_service.id
}

resource "google_compute_backend_service" "backend_service" {
  name                  = "backend"
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.lab_health_check.id]
  backend {
    group           = google_compute_instance_group_manager.lab_mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}


