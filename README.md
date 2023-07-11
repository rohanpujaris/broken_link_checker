
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
