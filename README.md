c4se
==
c4se's infrastructure code.

API Gatewayの更新手順
--
1. LambdaのコードとAPI Gatewayの設定を書き換へる
2. (Lambdaのコードを更新した場合は) `bundle exec rake build:aws_lambda`
3. `bundle exec rake build:terraform` の後に `bundle exec rake deploy:terraform`
4. (API Gatewayの設定を更新した場合は) `bundle exec rake deploy:aws_apigateway` でstagingの設定をデプロイする
5. (Lambdaのコードを更新した場合は)
   - `bundle exec deploy:aws_lambda` で、表示されたVersionをメモする
   - 上でメモしたVersionを `prod_function_version` に設定する
   - `bundle exec rake build:terraform` の後に `bundle exec rake deploy:terraform`
6. `bundle exec rake deploy:aws_apigateway` でproductionの設定をデプロイする
