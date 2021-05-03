---
title: Serverless blue-green deployments and canary releases with traffic shifting
date:   2017-12-04
description: Introduction into A/B testing with AWS Lambda
tags: ["Serverless", "AWS Lambda", "Node.JS", "Cloud"]
---

Serverless computing is a hot topic. Especially AWS Lambda is gaining traction. It is being used as the foundation of Amazon's Alexa product-line and the basis of entire web sites like [A Cloud Guru](https://acloud.guru/). We can rapidly build and release new business value to our customers like never before.

That said, we still want to deploy working solutions even at high velocity. Our production releases should be of the highest quality and should not endanger any users or depending systems.

Typically we apply techniques like [Canary Releases](https://martinfowler.com/bliki/CanaryRelease.html) and [Blue Green Deployments](https://martinfowler.com/bliki/BlueGreenDeployment.html) to reduce the risk of going into production and to be able to easily rollback any broken solutions.

In this short post, I want to introduce you to AWS Lambda _traffic shifting_. This rather new feature allows us to do Canary Releases and Blue-Green Deployments in a Serverless world. I will show you, how to use this to roll out new features in a controlled fashion and how to roll back to a safe point if things go wrong.

If you need a quick refresher on AWS Lambda, please look at a previous [post](https://dev.to/koenighotze/serverless-hype-train-with-aws-lambda-21p).

## Blue-Green Deployments and Canary Releases

Before we dive into AWS Lambda traffic shifting, we need to refresh our understanding of _Blue Green Deployments_ and _Canary Releases_.

When we deploy our solutions to production or update an existing solution, we want to keep downtime at a minimum. In today's world being down for 4 hours of maintenance is simply no viable option anymore.

Blue-Green Deployments can help us here. Consider the following illustration.

![Blue Green Deployments reduce downtime to a minimum](https://thepracticaldev.s3.amazonaws.com/i/o8nrrh97gekqtxy9sg59.png)

A customer accesses our system's current version, the _Blue Release_ via a load balancer. Upon the release of the new version (the green box), we can wait for the new version to stabilize, e.g. database migrations to take place and so on.
At the time the _Green Release_ is ready to be used, we can switch the load balancer to the new version without any visible implications to the customer. Besides, if the _Green Release_ somehow fails, we can easily switch back to the _Blue Release_. A haven if things go wrong.

Canary Releases are similar to Blue-Green Deployments. They try to reduce the risk of deploying new versions by slowly rolling out the update to a reduced set of users. You could start by directing 10% of incoming traffic to the new _Green Release_ and stepwise increase that percentage until you reach 100%. At that point, you can decommission the _Blue Release_.

## Versions and Lambda functions

Before we can continue our discussion of Blue-Green Deployments and Canaries, we need to look at the exact way, AWS Lambda handles our functions.

Whenever you upload your code to AWS Lambda, AWS stores your code in a S3 bucket. Let's check this using a simple Hello-World Lambda:

```javascript
exports.handler = (event, context, callback) => {
  callback(null, 'Hello World!')
}
```

We create the Lambda function using the command line. First, create the Zip-file containing the code.

```bash
zip index.zip index.js
```

Then create the function called `TrafficShiftDemo`. Note that I refer to a role-arn using `$ROLE_ARN`, see my previous [post](https://dev.to/koenighotze/serverless-hype-train-with-aws-lambda-21p) if you need help with this...and I have truncated all arns to keep things readable.

```bash
$ aws lambda create-function \
   --function-name TrafficShiftDemo \
   --runtime nodejs6.10 \
   --role $ROLE_ARN  \
   --handler index.handler \
   --zip-file fileb://index.zip

{

    "FunctionName": "TrafficShiftDemo",
    "FunctionArn": "arn:aws:...:TrafficShiftDemo",
    "Version": "$LATEST",
    ...
}
```

The point I want to stress is the `"Version": "$LATEST"` field. As the name suggests, `$LATEST` points to the very latest version.

Contrast this to _publishing_ a Lambda function. First, delete the function again.

```bash
aws lambda delete-function --function-name TrafficShiftDemo
```

Then re-create and publish the function using the command-line argument `--publish`.

```bash
$ aws lambda create-function \
   --function-name TrafficShiftDemo \
   --runtime nodejs6.10 \
   --role $ROLE_ARN  \
   --handler index.handler \
   --zip-file fileb://index.zip \
   --publish

{
    "FunctionName": "TrafficShiftDemo",
    "FunctionArn": "arn:aws:...:TrafficShiftDemo",
    "Version": "1",
    ...
}
```

Instead of `$LATEST`, the function features a version of `1`. A published function is essentially an immutable snapshot of the function code and its configuration, such as environment variables.

Consider this illustration.

![Versioning](https://thepracticaldev.s3.amazonaws.com/i/ot0y6088vu2v0aeyv9f0.png)

We publish a Lambda function trice. Version 1, version 2 and version 3 are identifiable by their respective version numbers. The `$LATEST` version always points to the most recent version uploaded to AWS Lambda.

Let's modify the function code as follows:

```javascript
exports.handler = (event, context, callback) => {
  callback(null, 'Bonjour le monde!')
}
```

And now we publish this new code, by updating the Lambda function (don't forget to Zip the code):

```bash
$ aws lambda update-function-code \
   --function-name TrafficShiftDemo \
   --zip-file fileb://index.zip \
   --publish

{
    "FunctionName": "TrafficShiftDemo",
    "FunctionArn": "arn:aws:...:TrafficShiftDemo:2",
    "Version": "2",
    ...
}
```

Now AWS Lambda informs us, that version `2` has been created.

If we examine the function, AWS Lambda lists all versions. I use [JQ](https://github.com/stedolan/jq) to extract the function arn.

```bash
$  aws lambda list-versions-by-function \
    --function-name TrafficShiftDemo \
    |jq '.Versions[] | .FunctionArn'

"arn:aws:...:TrafficShiftDemo:$LATEST"
"arn:aws:...:TrafficShiftDemo:1"
"arn:aws:...:TrafficShiftDemo:2"
```

You can see the so-called _fully qualified name_ of the function. And we can use that name to invoke the different versions.

```bash
$ aws lambda invoke \
   --function-name arn:aws:...:TrafficShiftDemo:1 out.txt

{
    "ExecutedVersion": "1",
    "StatusCode": 200
}

$ aws lambda invoke \
   --function-name arn:aws:...:TrafficShiftDemo:2 out.txt

{
    "ExecutedVersion": "2",
    "StatusCode": 200
}
```

Cloudwatch reports which version was used, too:

```bash
 START RequestId: 2771b...801f Version: 1
 END RequestId: 2771b...801f
 REPORT RequestId: 2771b...801f  Duration: 33.87 ms  Billed Duration: 100 ms   Memory Size: 128 MB Max Memory Used: 19 MB

 START RequestId: 2dd66...043d Version: 2
 END RequestId: 2dd66...043d
 REPORT RequestId: 2dd66...043d  Duration: 37.58 ms  Billed Duration: 100 ms   Memory Size: 128 MB Max Memory Used: 19 MB
```

As I said above, a published function is an immutable snapshot. That also implies that version numbers are not reused. If, for example, you remove version 2 of the function and publish the function again, then you end up with version 3. Version 2 will never be reused.

```bash
$ aws lambda delete-function \
   --function-name arn:aws:...:TrafficShiftDemo:2

$ aws lambda update-function-code \
   --function-name TrafficShiftDemo \
   --zip-file fileb://index.zip \
   --publish

{
    "FunctionName": "TrafficShiftDemo",
    "FunctionArn": "arn:aws:...:TrafficShiftDemo:3",
    "Version": "3",
    ...
}
```

## Stable client with Lambda Aliases

An _alias_ allows us to refer to a specific version of an AWS Lambda function by name. Think of it as a simple logical link, similar to what you would do on a standard *nix-like file system.

Let's create an alias called `HELLO` for version 1 of our Hello-World Lambda.

```bash
$ aws lambda create-alias \
   --name HELLO \
   --function-name TrafficShiftDemo \
   --function-version 1

{
    "AliasArn": "arn:aws:...:TrafficShiftDemo:HELLO",
    "FunctionVersion": "1",
    "Name": "HELLO",
    "Description": ""
}
```

If we invoke the alias, we get our `Hello World` response, as expected:

```bash
$ aws lambda invoke --function-name arn:aws:...:TrafficShiftDemo:HELLO out.txt

{
    "ExecutedVersion": "1",
    "StatusCode": 200
}

$ cat out.txt

"Hello World!"
```

AWS Lambda tells us, that we invoked version 1: `"ExecutedVersion": "1"`, just as we wanted.

Now point the alias to the updated french function code:

```bash
$ aws lambda update-alias \
   --name HELLO \
   --function-name TrafficShiftDemo \
   --function-version 2

{
    "AliasArn": "arn:aws:...:TrafficShiftDemo:HELLO",
    "FunctionVersion": "2",
    "Name": "HELLO",
    "Description": ""
}
```

If we invoke the alias again, we get the french response:

```bash
$ aws lambda invoke \
   --function-name arn:aws:...:TrafficShiftDemo:HELLO out.txt

{
    "ExecutedVersion": "2",
    "StatusCode": 200
}

$ cat out.txt
"Bonjour le monde!"
```

With this we can have a stable client, that only ever calls our alias and we can safely replace the version behind the curtains without ever touching the client.

Consider the example of an Alexa skill that refers to an AWS Lambda alias, without actually knowing which exact version was used. The Alexa skill refers only to the `PROD` Lambda alias. This in turn aliases version 1 of the actual Lambda function.

![Alexa uses the PROD alias](https://thepracticaldev.s3.amazonaws.com/i/c6a070gzb14h9m3s4xc0.png)

After an upgrade to a new version 2 and testing that it works as expected, we update the alias to point to version 2. The Alexa skill need not be updated in any way.

![Version 2 can be released without impacting the skill](https://thepracticaldev.s3.amazonaws.com/i/ouaaoj3wicrhzkwd3ix1.png)

This is all very nice, but how can we ensure, that people like our new Lambda function and that it behaves as expected? This brings us to Canary Releases with traffic shifting.

## Traffic shifting with AWS Lambda

Traffic shifting is the idea to release an update step-wise in parallel to the current version.

Let's assume we have a Lambda function `1` in production. Now we want to release version `2` but we want to roll out the new version in a safe way.

Traffic shifting to the rescue.

We deploy both versions, `1` and `2`. Initially, all traffic goes to version `1`. But as time progresses we move traffic increasingly to version `2` until at one point 100% of the traffic goes to version `2`. At that time version `1` can be decommissioned.

AWS Lambda aliases now support this feature out of the box. We just have to use the new command-line argument `--routing-config`. Before continuing, check the version of your AWS CLI tool, as this is a rather new addition to AWS Lambda. It should read as follows:

```bash
$ aws --version
aws-cli/1.14.2
```

First of all, delete the `HELLO` alias that was created above:

```bash
$ aws lambda delete-alias \
   --function-name arn:aws:...:TrafficShiftDemo \
   --name HELLO
```

Now create a new alias, that redirects 70% of incoming traffic to version 1 and the remaining 30% to version 2.

```bash
$ aws lambda create-alias \
   --name HELLO \
   --function-name TrafficShiftDemo \
   --function-version 2 \
   --routing-config AdditionalVersionWeights={'1'=0.7}
```

The `--routing-config AdditionalVersionWeights={'1'=0.7}` tells AWS Lambda to redirect 70% of the traffic to version 1, instead of using version 2. You can verify this behavior by invoking the function multiple times checking the `"ExecutedVersion"` in the response.

```bash
$ aws lambda invoke --function-name arn:aws:...:TrafficShiftDemo:HELLO out.txt

{
    "ExecutedVersion": "2",
    "StatusCode": 200
}

$ aws lambda invoke --function-name arn:aws:...:TrafficShiftDemo:HELLO out.txt

{
    "ExecutedVersion": "1",
    "StatusCode": 200
}

$ aws lambda invoke --function-name arn:aws:...:TrafficShiftDemo:HELLO out.txt

{
    "ExecutedVersion": "1",
    "StatusCode": 200
}
```

We can finally release new Lambda functions and check their behavior and impact in a truly agile way.

## Summary

Traffic shifting is an important part of Blue-Green Deployments and Canary releases. With this new feature, we can release new business functions and see how people are using it and how the market reacts to it. Think of simple things like testing if people like seeing more details about a movie on a streaming service instead of just the title and the running time.

If you want to dig deeper into this topic, I urge you to look at [AWS Codedeploy](http://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html) which automates rolling-updates and rollbacks even further. With Codedeploy you can configure your Lambda to scale up to the new version with a rate of 10% every 5 min, for example.

In a follow-up, I will cover an integrated example, that brings Lambda, traffic shifting, Codedeploy, and the Serverless Application Model together into a truly serverless continuous delivery pipeline.
