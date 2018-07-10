resource "aws_iam_role_policy" "platform_team_ecs_admin" {
  name   = "platform_team_ecs_admin"
  role   = "${aws_iam_role.platform_team_assume_role.name}"
  policy = "${data.aws_iam_policy_document.allow_ecs_admin.json}"
}

resource "aws_iam_role_policy" "platform_team_grafana_billing" {
  name   = "platform_team_grafana_billing_view"
  role   = "${aws_iam_role.platform_team_grafana_assume_role.name}"
  policy = "${data.aws_iam_policy_document.allow_billing_usage_view.json}"
}

resource "aws_iam_role_policy" "ecs_goobi_s3_config_read" {
  role   = "${module.goobi.goobi_task_role}"
  policy = "${data.aws_iam_policy_document.s3_read_workflow-configuration.json}"
}

resource "aws_iam_role_policy" "ecs_goobi_s3_data_rw" {
  role   = "${module.goobi.goobi_task_role}"
  policy = "${data.aws_iam_policy_document.s3_rw_workflow-data.json}"
}