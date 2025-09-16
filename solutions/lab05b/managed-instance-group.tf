resource "google_compute_health_check" "lab_health_check" {
  name = "lab-http-check"
  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

resource "google_compute_instance_group_manager" "lab_mig" {
  name = "lab-mig"

  base_instance_name = "vm"
  zone               = var.lab-zone

  version {
    instance_template = google_compute_instance_template.lab_instance_template.self_link_unique
  }

  target_size = 2

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.lab_health_check.id
    initial_delay_sec = 120
  }
}

resource "google_compute_autoscaler" "lab_autoscaler" {
  name   = "lab-autoscaler"
  target = google_compute_instance_group_manager.lab_mig.instance_group
  zone   = var.lab-zone

  autoscaling_policy {
    min_replicas = 2
    max_replicas = 5

    load_balancing_utilization {
      target = 0.5
    }
  }
}

