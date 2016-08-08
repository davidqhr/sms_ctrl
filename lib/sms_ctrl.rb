require "sms_ctrl/version"
require "sms_ctrl/case"

module SmsCtrl
  @debug_code = '123456'
  @cases = {}

  class << self
    attr_accessor :debug, :cache, :default_options, :default_errors

    # 非线程安全，只应该用在单线程环境中配置，例如rails加载
    def register name, options
      name = name.to_s

      new_case = SmsCtrl::Case.new(name, options)
      @cases[name] = new_case

      @default_case = new_case if @cases.size == 1
    end

    def default_options
      @default_options ||= {
        retry_limit: 55,
        expires_in: 30 * 60,
        mobile_regexp: /^1[3|4|5|7|8]\d{9}$/,
        sender: -> (mobile, code, params) { warn "No message sender set for case #{@name}" },
      }
    end

    def default_errors
      @default_errors ||= {
        illegal_mobile: '请输入正确的手机号码',
        retry_limit: '操作太频繁，请稍后再试'
      }
    end

    def clear
      @cases = {}
    end

    def get name
      @cases[name.to_s]
    end

    alias [] get

    def set_default c
      @default_case = @cases[c.to_s]
    end

    def default
      @default_case
    end

    def send_sms *args
      if @default_case
        @default_case.send_sms(*args)
      else
        raise 'no default case'
      end
    end

    def check_code *args
      if @default_case
        @default_case.check_code(*args)
      else
        raise 'no default case'
      end
    end
  end
end
