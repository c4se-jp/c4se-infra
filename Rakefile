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
