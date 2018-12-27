terraform  {
  backend "s3" {
    bucket = "terraform-neilrichards-up-and-run"
    key = "global/iam/terraform.tfstate"
    region = "eu-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = "eu-west-2"
}

//Remember new IAM users have no permissions
//Define read-only access to EC2 for new users
data "aws_iam_policy_document" "ec2_read_only" {
  "statement" {
    effect = "Allow"
    actions = ["ec2:Describe"]
    resources = ["*"]
  }
}

//Create new IAM user
//Use count.index to get the index of each iteration of the loop
//Loop through the list declared in live/global/iam/vars.tf
//Use interpolation fucntions to get element and length
resource "aws_iam_user" "example" {
  count = "${length(var.user_names)}"
  name = "${element(var.user_names, count.index )}"
}

//Define policy
//Attach policy to the aws_iam_user_policy_attachement resource
resource "aws_iam_policy" "ec2_read_only" {
  name = "ec2-read-only"
  policy = "${data.aws_iam_policy_document.ec2_read_only.json}"
}

resource "aws_iam_user_policy_attachment" "ec2_access" {
  count = "${length(var.user_names)}"
  user = "${element(aws_iam_user.example.*.name, count.index )}"
  policy_arn = "${aws_iam_policy.ec2_read_only.arn}"
}

//Define IAM cloud policy read-only
resource "aws_iam_policy" "cloudwatch_read_only" {
  name = "cloudwatch-read-only"
  policy = "${data.aws_iam_policy_document.cloudwatch_read_only.json}"
}

//Define data for read-only
data "aws_iam_policy_document" "cloudwatch_read_only" {
  "statement" {
    effect = "Allow"
    actions = ["cloudwatch:Describe*", "cloudwatch:Get*", "cloudwatch:List*"]
    resources = ["*"]
  }
}

//Define IAM cloud policy full access
resource "aws_iam_policy" "cloudwatch_full_access" {
  name = "cloudwatch-full-access"
  policy = "${data.aws_iam_policy_document.cloudwatch_full_access.json}"
}

//Define data for full-access
data "aws_iam_policy_document" "cloudwatch_full_access" {
  "statement" {
    effect = "Allow"
    actions = ["cloudwatch:*"]
    resources = ["*"]
  }
}


/*Demonstrate if/else capabilities taking advantage of the fact that Terraform
allows simple math in interpolations
*/

resource "aws_iam_user_policy_attachment" "alice_cloudwatch_full_access" {
  count = "${var.give_alice_cloudwatch_full_access}"
  policy_arn = "${aws_iam_policy.cloudwatch_full_access.arn}"
  user = "${aws_iam_user.example.0.name}"
}

resource "aws_iam_user_policy_attachment" "alice_cloudwatch_read_only" {
  count = "${1 - var.give_alice_cloudwatch_full_access}"
  policy_arn = "${aws_iam_policy.cloudwatch_read_only.arn}"
  user = "${aws_iam_user.example.0.arn}"
}






