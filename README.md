[![Build Status](https://travis-ci.org/mewa/terrascript.svg?branch=master)](https://travis-ci.org/mewa/terrascript) [![Gem Version](https://badge.fury.io/rb/terrascript.svg)](https://badge.fury.io/rb/terrascript)

# What is Terrascript

Terrascript is wrapper around Terraform which adds the ability to script repetitive tasks as inline ruby code.

Terrascript parses `.tfrb` files, executes ruby code and outputs `.tf` files.

# Usage

The overall structure is as shown below:
```ruby
@inline
# ruby code
return
# plain text
@end
```

`@inline` directive marks the beginning of inline ruby code.

Code is evaluated until a `return` statement is found.

Text between `return` and `@end` statements is passed as an argument to the code.
By default it's accessible inside the inline code under `block` variable, but you can override the name by specifying your own name in `@inline` directive.

For example `@inline arg` declaration will pass text in `arg` variable.

Anything the inline ruby code prints (`puts`) is written to the destination `.tf` file.

# Examples

```hcl
@inline
["one", "two"].each do |fn|
  puts block.gsub("<fn>", fn)
end
return
# <fn> alias
module "<fn>_alias" {
  source = "mewa/lambda-alias/aws"
  version = "1.0.0"

  alias = "${local.environment}"
  function_arn = "${aws_lambda_function.<fn>.arn}"
  function_name = "${aws_lambda_function.<fn>.function_name}"
  function_version = "${aws_lambda_function.<fn>.version}"
  invoke_arn = "${aws_lambda_function.<fn>.invoke_arn}"
}

# <fn> permission
resource "aws_lambda_permission" "<fn>_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.<fn>.function_name}"
  qualifier = "${module.<fn>_alias.alias}"

  source_arn = "${aws_api_gateway_deployment.stage.execution_arn}/*/*"
}
@end
```
Will be rendered as
```hcl
# one alias
module "one_alias" {
  source = "mewa/lambda-alias/aws"
  version = "1.0.0"

  alias = "${local.environment}"
  function_arn = "${aws_lambda_function.one.arn}"
  function_name = "${aws_lambda_function.one.function_name}"
  function_version = "${aws_lambda_function.one.version}"
  invoke_arn = "${aws_lambda_function.one.invoke_arn}"
}

# one permission
resource "aws_lambda_permission" "one_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.one.function_name}"
  qualifier = "${module.one_alias.alias}"

  source_arn = "${aws_api_gateway_deployment.stage.execution_arn}/*/*"
}
# two alias
module "two_alias" {
  source = "mewa/lambda-alias/aws"
  version = "1.0.0"

  alias = "${local.environment}"
  function_arn = "${aws_lambda_function.two.arn}"
  function_name = "${aws_lambda_function.two.function_name}"
  function_version = "${aws_lambda_function.two.version}"
  invoke_arn = "${aws_lambda_function.two.invoke_arn}"
}

# two permission
resource "aws_lambda_permission" "two_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.two.function_name}"
  qualifier = "${module.two_alias.alias}"

  source_arn = "${aws_api_gateway_deployment.stage.execution_arn}/*/*"
}
```

# Future improvements

This project was written for my internal needs and serves its purpose.

However if it gains traction I could look into implementing a cleaner solution
that abstracts the code for some common tasks and leaves open door for extension (plugins, probably).

The code presented here as an example could then look like this:

```hcl
@replace "<fn>" with ["one", "two"]
# <fn> alias
module "<fn>_alias" {
    some_attribute = "${some_resource.<fn>.something}"
}
@end
```
