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
      aws_s3_bucket.workflow-upload.arn,
      "${aws_s3_bucket.workflow-upload.arn}/*",
    ]
  }
}

