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

//Output example of referencing a list
//Use splat "*" to specify all users in the list
//Wrap the output variable with brackets
output "all_arns" {
  value = ["${aws_iam_user.example.*.arn}"]
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



