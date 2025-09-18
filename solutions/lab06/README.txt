# Lab06 – GCS with Terraform (Solution)
## Quickstart
1. Ensure you are authenticated (the lab states environment is pre-authenticated).
2. Change into this folder:
   cd googlelabs/lab06
3. Initialize Terraform:
   terraform init
4. Set variables (replace PROJECT_ID and optionally bucket name):
   terraform apply -auto-approve -var="project_id=PROJECT_ID"
   # or add -var="bucket_name=googlelabs-mcg-static-5678" for an explicit name
5. On success, Terraform will print:
   - bucket_name
   - bucket_console_url
   - signed_url_teide (valid 1 hour)

## Notes
- Public access is blocked via public_access_prevention = "enforced".
- Objects are private by default; temporary sharing uses a Signed URL.
- Lifecycle: move to NEARLINE after 30 days; delete after 90 days.
