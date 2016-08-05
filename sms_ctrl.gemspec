# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sms_ctrl/version'

Gem::Specification.new do |spec|
  spec.name          = "sms_ctrl"
  spec.version       = SmsCtrl::VERSION
  spec.authors       = ["david"]
  spec.email         = ["davidqhr@gmail.com"]

  spec.summary       = %q{短信重试、请求次数控制、短信验证码缓存}
  spec.description   = %q{短信重试、请求次数控制、短信验证码缓存}
  spec.homepage      = "https://github.com/davidqhr/sms_ctrl"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "timecop"
end