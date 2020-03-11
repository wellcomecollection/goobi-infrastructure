resource "aws_iam_role" "lambda_stage_iam_role" {
  name               = "lambda_stage_iam_role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_stage_role.json
}

# Machine user for editorial photography uploads

resource "aws_iam_user" "workflow-upload-only" {
  name = "workflow-upload-only"
}

resource "aws_iam_access_key" "workflow-upload-only" {
  user = aws_iam_user.workflow-upload-only.name
}

resource "aws_iam_user_policy" "workflow-upload-only" {
  user   = aws_iam_user.workflow-upload-only.name
  policy = data.aws_iam_policy_document.workflow-upload-only.json
}

data "aws_iam_policy_document" "workflow-upload-only" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:Put*",
    ]

    resources = [
      aws_s3_bucket.workflow-stage-upload.arn,
      "${aws_s3_bucket.workflow-stage-upload.arn}/*",
    ]
  }
}

