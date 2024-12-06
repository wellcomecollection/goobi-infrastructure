# Machine user for editorial photography uploads

resource "aws_iam_user" "workflow-stage-upload-only" {
  name = "workflow-stage-upload-only"
}

resource "aws_iam_access_key" "workflow-stage-upload-only" {
  user = aws_iam_user.workflow-stage-upload-only.name
}

resource "aws_iam_user_policy" "workflow-stage-upload-only" {
  user   = aws_iam_user.workflow-stage-upload-only.name
  policy = data.aws_iam_policy_document.workflow-stage-upload-only.json
}

data "aws_iam_policy_document" "workflow-stage-upload-only" {
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

