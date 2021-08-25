
# Running locally

- ### Install ruby 2.7, node 14 or higher, postgress 11 or higher

- ### Install gems
    ```
    bundle install --standalone
    ```

- ### Create and fill database with seed data
    Setup db/config.yml with postgress configuration details
    ```
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    ```
- ### Running rake task to check broken link
    ```
        rake check_broken_links
    ```

- ### To play with code using IRB
    ```
        ./bin/console
    ```

# Deploying to aws lambda using serverless framework

- ### Install npm packages
    ```
    npm install
    ```

- ### Add DATABASE_URL to serverless.yml
   Note: In a real app, we will use any [these](https://www.serverless.com/blog/aws-secrets-management) approaches to manage database URL.

- ### Deploy
    ```
    sls deploy --stage production
    ```

# Running test
    ```
    ENV=development bundle exec rake db:migrate
    bundle exec rspec spec
    ```

# Assumptions

-  I have assumed that URL in the items table are valid http or https url with protocol in it i.e http://example.com or https://example.com. I haven't taken care of validating it
-  I assume database configuration and setups are not the objective of this exercise. I have gone with the easy way of just using a DATABASE_URL directly inside serverless.yml
-  Cases where item URL was unreachable or it timed out, I have just associated it with the record in check_statuses with nil as code and exception message as description.

# Question

- Thoughts on why you chose the language you did?
  - I used Ruby as I am most comfortable in it. If I would have chosen another language it would have taken more effort to implement it. In real app case decision would have been made keeping scaling and team size in mind.
- How you would run the script in production.
  There are two lambda functions
   1. broken_link_batcher: Triggered by Amazon CloudWatch Events every day. Its job is to divide Items into batches and put id's of each batch item as a separate AWS SQS message
   2. broken_link_batch_executor: This is triggered as soon as there is a message available in AWS SQS. It picks up Item id's and checks if URL for the item in the batch is broken or not. This is the main Lambda function that checks Item URL and updates last_checked_at and associates it with check_statuses. This can also be triggered directly via URL endpoint if we want to use our custom batching and queuing system.
  Note: In a real app we will have authentication for this URL endpoint maybe using jwt token
