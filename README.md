# SmsCtrl

发送短信，间隔限制，过期控制

## Installation

Add this line to your application's Gemfile:


	gem 'sms_ctrl'


And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sms_ctrl

## Usage

```ruby
# confing/initializes/sms_ctrl.rb

# 设置debug模式，所有验证码都是123456，不会走sender

SmsCtrl.debug = true

# 设置cache，需要支持 read(key), write(key, expires_in: 10)
# SmsCtrl.cache = Rails.cache

# 注册一个控制模块

SmsCtrl.register( "register_user", {
  # retry_limit: 55,
  # expires: 30 * 60,
  sender: ->(mobile, code, params) {
    # 发送逻辑
  }
})

SmsCtrl.register( "user_reset_password", {
  # retry_limit: 55,
  # expires: 30 * 60,
  sender: ->(mobile, code, params) {
    # 发送逻辑
  }
})

# 检查验证码是否匹配

SmsCtrl["register_user"].check_code "13000000000", '231232'
SmsCtrl["user_reset_password"].check_code "13000000000", '231232'

# SmsCtrl.set_default("register_user")
# SmsCtrl.check_code "13000000000", '231232'

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidqhr/sms_ctrl.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

