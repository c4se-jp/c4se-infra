require 'json'

task :default

def select_aws_lambda_target
  targets = Dir.chdir 'aws-lambda' do
    Dir['*'].select { |f| File.directory? f }
  end
  `echo #{targets.join "\n"} | peco`.chomp
end

namespace :build do
  desc 'Build an AWS Lambda zip file.'
  task :aws_lambda do
    target = select_aws_lambda_target
    next if target.empty?
    sh <<EOF
cd aws-lambda/#{target} \
&& rm -f ../#{target}.zip \
&& zip -r ../#{target}.zip *
EOF
  end
end

namespace :terraform do
  desc 'Dry run Terraform.'
  task :plan do
    Bundler.with_clean_env { sh 'terraform plan' }
  end

  desc 'Run Terraform.'
  task :apply do
    Bundler.with_clean_env { sh 'terraform apply' }
  end
end

desc 'Deploy API Gateway to prod.'
task :deploy_apigateway do
  apis = %w(heartbeat_api)
  api = `echo #{apis.join "\n"} | peco`.chomp
  next if api.empty?
  api_id = JSON.parse(`aws apigateway get-rest-apis --output json`)['items'].detect { |rest_api| rest_api['name'] == api }['id']
  sh "aws apigateway create-deployment --rest-api-id #{api_id} --stage-name prod"
end
