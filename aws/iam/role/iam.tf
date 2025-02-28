locals {
  policies = [
    {
      effect = "Allow"
      actions = [ "lambda:InvokeFunction" ]
      resources = [ "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${local.get_acount_info_lambda_name}" ]
      principals = [ "apigateway.amazonaws.com" ]
      conditions = [  {
        test = "ArnLike"
        variable = "AWS:SourceArn"  # "aws:SourceArn" also works
        values = [ "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:*/*/*/*" ]
    }
      ]
    }
  ]
}

data "aws_iam_policy_document" "policies" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [
      "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${local.get_acount_info_lambda_name}"
    ]
  }
}

resource "aws_iam_policy" "api_gw_policy" {
  name   = "${local.api_gw_name}-policy"
  policy = data.aws_iam_policy_document.policies.json
}

resource "aws_iam_policy_attachment" "api_gw_policy_attachment" {
  name = "${local.api_gw_name}-policy-attachment"
  roles = [
    aws_iam_role.gateway_rest_api_role.name
  ]
  policy_arn = aws_iam_policy.api_gw_policy.arn
}
