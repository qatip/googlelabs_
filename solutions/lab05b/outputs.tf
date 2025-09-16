output "lb-ip" {
  description = "ip of lab load balancer"
  value =   module.vpc.lb-ip
}
