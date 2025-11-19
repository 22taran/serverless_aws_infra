.PHONY: help init plan apply destroy package-lambda deploy-frontend

help:
	@echo "Serverless TODO - Makefile Commands"
	@echo ""
	@echo "Infrastructure:"
	@echo "  make init          - Initialize Terraform"
	@echo "  make plan          - Plan Terraform changes (dev)"
	@echo "  make apply         - Apply Terraform changes (dev)"
	@echo "  make destroy       - Destroy infrastructure (dev)"
	@echo ""
	@echo "Application:"
	@echo "  make package-lambda - Package Lambda functions"
	@echo "  make deploy-frontend - Deploy frontend to S3"
	@echo ""
	@echo "Full Deployment:"
	@echo "  make deploy        - Package Lambda, apply Terraform, deploy frontend"

init:
	cd infra/envs/dev && terraform init

plan:
	cd infra/envs/dev && terraform plan

apply:
	cd infra/envs/dev && terraform apply

destroy:
	cd infra/envs/dev && terraform destroy

package-lambda:
	./scripts/package-lambda.sh

deploy-frontend:
	@echo "Usage: make deploy-frontend S3_BUCKET=bucket-name [CLOUDFRONT_DISTRIBUTION_ID=dist-id]"
	@if [ -z "$(S3_BUCKET)" ]; then \
		echo "Error: S3_BUCKET is required"; \
		exit 1; \
	fi
	CLOUDFRONT_DISTRIBUTION_ID=$(CLOUDFRONT_DISTRIBUTION_ID) ./scripts/deploy-frontend.sh

deploy: package-lambda apply
	@echo "✅ Deployment complete!"
	@echo "Next: Run 'make deploy-frontend S3_BUCKET=<bucket-name>' to deploy frontend"

