resource "google_compute_instance_template" "lab_instance_template" {
  name_prefix  = var.instance-prefix
  machine_type = var.machine-type

  // boot disk
  disk {
    boot         = true
    source_image = "projects/debian-cloud/global/images/family/debian-11"
    mode         = "READ_WRITE"
    type         = "PERSISTENT"
  }

  // networking
  network_interface {
    network    = module.vpc.vpc-id
    subnetwork = module.vpc.lab-subnet
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata = {
    startup-script = "#! /bin/bash\n     sudo apt-get update\n     sudo apt-get install apache2 -y\n     sudo a2ensite default-ssl\n     sudo a2enmod ssl\n     vm_hostname=\"$(curl -H \"Metadata-Flavor:Google\" \\\n   http://169.254.169.254/computeMetadata/v1/instance/name)\"\n   sudo echo \"Page served from: $vm_hostname\" | \\\n   tee /var/www/html/index.html\n   sudo systemctl restart apache2"
  }
  tags = ["allow-health-check"]
}
