require "sms_ctrl/version"
require "sms_ctrl/case"

module SmsCtrl
  @debug_code = '123456'
  @cases = {}

  class << self
    attr_accessor :debug, :cache

    # 非线程安全，只应该用在单线程环境中配置，例如rails加载
    def register name, options
      new_case = SmsCtrl::Case.new(name, options)
      @cases[name] = new_case

      @default_case = new_case if @cases.size == 1
    end

    def clear
      @cases = {}
    end

    def get name
      @cases[name]
    end

    alias [] get

    def set_default c
      @default_case = c
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
