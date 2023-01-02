config {
  force               = false
  disabled_by_default = false
}

plugin "aws" {
  enabled = true
  version = "0.21.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Enabled by default. Check more AWS rules: https://github.com/terraform-linters/tflint-ruleset-aws/blob/master/docs/rules/README.md
rule "aws_instance_invalid_type" { enabled = true }
rule "terraform_typed_variables" { enabled = false }
rule "terraform_required_version" { enabled = false }
rule "terraform_required_providers" { enabled = false }
