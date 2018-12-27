//Output example of referencing a list
//Use splat "*" to specify all users in the list
//Wrap the output variable with brackets
output "all_arns" {
  value = ["${aws_iam_user.example.*.arn}"]
}


output "alice_arn" {
  value = "${aws_iam_user.example.0.arn}"
}