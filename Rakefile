require 'base64'
require 'digest'
require 'fileutils'
require 'json'
require 'shellwords'
require 'tempfile'

def peco(items)
  item = Tempfile.open 'peco' do |f|
    f.write items.join "\n"
    f.flush
    `peco --select-1 < #{f.path}`.chomp
  end
  item.empty? ? nil : item
end

def peco_aws_lambda
  Dir.chdir __dir__ do
    peco Dir['aws-lambda/*/'].collect { |dir| dir[11..-2] }
  end
end

task :default

namespace :build do
  desc 'Build an Lambda zip file.'
  task :aws_lambda do
    (target = peco_aws_lambda) || next
    Dir.chdir "aws-lambda/#{target}" do
      FileUtils.rm_f "../#{target}.zip"
      sh "zip -r ../#{target}.zip *"
    end
  end

  desc 'Dry run Terraform.'
  task :terraform do
    Dir.chdir 'terraform' do
      Bundler.with_clean_env { sh 'terraform plan -out=terraform.tfplan' }
    end
  end
end

namespace :deploy do
  desc 'Deploy API Gateway.'
  task :aws_apigateway do
    apis = {
      'heartbeat_ok' => %w(staging prod)
    }
    (api = peco apis.keys) || next
    (stage = peco apis[api]) || next
    api_id = JSON.parse(`aws apigateway get-rest-apis --output json`)['items'].detect { |rest_api| rest_api['name'] == api }['id']
    sh "aws apigateway create-deployment --rest-api-id #{api_id} --stage-name #{stage}"
  end

  desc 'Publish Lambda for production.'
  task :aws_lambda do
    (target = peco_aws_lambda) || next
    raise unless File.exist? "aws-lambda/#{target}.zip"
    cmd = Shellwords.join [
      'aws', 'lambda', 'publish-version',
      '--output', 'json',
      '--function-name', target,
      '--code-sha-256', Digest::SHA256.file("aws-lambda/#{target}.zip").base64digest,
      '--description', `git log --oneline -1 aws-lambda/#{target}.zip`.chomp
    ]
    res = `#{cmd}`
    puts res
    puts "Version: #{JSON.parse(res)["Version"]}"
  end

  desc 'Run Terraform.'
  task :terraform do
    Dir.chdir 'terraform' do
      begin
        Bundler.with_clean_env { sh 'terraform apply terraform.tfplan' }
      ensure
        sh 'rm terraform.tfplan'
      end
    end
  end
end

namespace :test do
  desc 'Lint.'
  task :lint do
    sh 'bundle exec rubocop'
    sh 'flake8 aws-lambda'
  end
end
