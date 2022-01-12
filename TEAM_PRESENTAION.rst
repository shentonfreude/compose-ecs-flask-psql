==================================================================
 Deploying locally with Compose, then to AWS Fargate in 5 minutes
==================================================================

This is a "lightning talk" to our team to show how easy it is to get a
multi-container application which runs locally with Docker Compose
deployed to AWS ECS Fargate.

We don't (yet!) explore features like autoscaling backend servers,
etc.

"Serverless First", but...
==========================

* Serverless applications let AWS manage all the "undifferentiated heavy lifting".
* API Gateway, Lambda, S3, DynamoDB make a deadly combination that scales quickly and effortless, and costs very little.
* But not all apps fit within Lambda's constraints:

  * Long-running app servers like Django/Wagtail






