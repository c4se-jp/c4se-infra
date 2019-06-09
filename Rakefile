# frozen_string_literal: true
require 'base64'
require 'digest'
require 'fileutils'
require 'json'
require 'net/http'
require 'shellwords'
require 'tempfile'
require 'uri'

aws_lambdas = {
  'get_random' => 'crud_random',
  'heartbeat_ok' => 'heartbeat_ok',
  'put_random' => 'crud_random'
}

def peco(items)
  item = Tempfile.open 'peco' do |f|
    f.write items.join "\n"
    f.flush
    `peco --select-1 < #{f.path}`.chomp
  end
  item.empty? ? nil : item
end

task :default

namespace :build do
  desc 'Build an Lambda zip file.'
  task :aws_lambda do
    (target = peco aws_lambdas.values.uniq) || next
    Dir.chdir "#{__dir__}/aws_lambda/#{target}" do
      FileUtils.rm_f "../#{target}.zip"
      sh "zip -r ../#{target}.zip *"
    end
  end

  desc 'Dry run Terraform.'
  task :terraform do
    Dir.chdir "#{__dir__}/terraform" do
      Bundler.with_clean_env do
        sh 'terraform get'
        sh 'terraform plan -out=terraform.tfplan'
      end
    end
  end
end

namespace :deploy do
  desc 'Deploy API Gateway.'
  task :aws_apigateway do
    apis = {
      'research' => %w(staging prod)
    }
    (api = peco apis.keys) || next
    (stage = peco apis[api]) || next
    api_id = JSON.parse(`aws apigateway get-rest-apis --output json`)['items'].detect { |rest_api| rest_api['name'] == api }['id']
    sh "aws apigateway create-deployment --rest-api-id #{api_id} --stage-name #{stage}"
  end

  desc 'Publish Lambda for production.'
  task :aws_lambda do
    (target = peco aws_lambdas.keys) || next
    target_file = "aws_lambda/#{aws_lambdas[target]}.zip"
    raise unless File.exist? target_file
    cmd = Shellwords.join [
      'aws', 'lambda', 'publish-version',
      '--output', 'json',
      '--function-name', target,
      '--code-sha-256', Digest::SHA256.file(target_file).base64digest,
      '--description', `git log --oneline -1 #{target_file}`.chomp
    ]
    res = `#{cmd}`
    puts res
    puts "Version: #{JSON.parse(res)['Version']}"
  end

  desc 'Run Terraform.'
  task :terraform do
    Dir.chdir "#{__dir__}/terraform" do
      begin
        Bundler.with_clean_env { sh 'terraform apply terraform.tfplan' }
      ensure
        FileUtils.rm_f 'terraform.tfplan'
      end
    end
  end
end

desc 'Run all test tasks.'
task test: ['test:lint']

namespace :test do
  desc 'Lint.'
  task :lint do
    sh 'bundle exec rubocop'
    Dir.chdir("#{__dir__}/serverless") { sh 'flake8' }
    Dir.chdir "#{__dir__}/terraform" do
      sh 'terraform validate'
      Dir['modules/*/'].each { |dir| sh "terraform validate #{dir}" }
    end
  end
end

desc 'Update all.'
task update: ['update:gem', 'update:gitignore', 'update:npm']

namespace :update do
  desc 'Update rubygems.'
  task(:gem) { sh 'bundle update' }

  desc 'Update .gitignore'
  task :gitignore do
    gitignore = File.read '.gitignore', encoding: Encoding::UTF_8
    url = %r{\n# Created by (https://www\.gitignore\.io/api/.+)$}.match(gitignore)&.send(:[], 1)&.chomp
    next unless url
    res = Net::HTTP.get URI(url)
    gitignore = gitignore.sub %r{\n# Created by https://www\.gitignore\.io/api/.+}m, res
    File.write '.gitignore', gitignore, encoding: Encoding::UTF_8
  end

  desc 'Update npm.'
  task :npm do
    sh 'node_modules/npm-check-updates/bin/ncu -u'
    sh 'npm update'
  end
end
