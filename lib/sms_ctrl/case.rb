module SmsCtrl
  class Case
    attr_accessor :retry_limit, :expires_in,
      :mobile_regexp, :sender, :errors

    def initialize name, options = {}
      @name = name
      options = SmsCtrl.default_options.merge(options)

      self.retry_limit   = options[:retry_limit]
      self.expires_in    = options[:expires_in]
      self.mobile_regexp = options[:mobile_regexp]
      self.sender        = options[:sender]

      if options[:errors]
        self.errors = SmsCtrl.default_errors.merge(options[:errors])
      else
        self.errors = SmsCtrl.default_errors
      end
    end

    def send_sms mobile, code, params = {}
      mobile = mobile.to_s

      unless mobile =~ mobile_regexp
        return {
          success: false,
          error: errors[:illegal_mobile],
          error_type: :illegal_mobile
        }
      end

      if retry_limit > 0 && SmsCtrl.cache.read(retry_limit_key(mobile))
        return {
          success: false,
          error: errors[:retry_limit],
          error_type: :retry_limit }
      end

      if SmsCtrl.debug
        code = '123456'
        data = 'debug send ok'
      else
        data = @sender.call(mobile, code, params)
      end

      result = {
        success: true,
        data: data
      }

      if retry_limit > 0
        SmsCtrl.cache.write(retry_limit_key(mobile), 'true', expires_in: retry_limit)
      end

      SmsCtrl.cache.write(code_cache_key(mobile), code, expires_in: expires_in)

      result
    end

    # check match
    def check_code mobile, code
      cache_code = SmsCtrl.cache.read(code_cache_key(mobile.to_s))
      return false if cache_code.nil?
      cache_code.to_s == code.to_s
    end

    private

    # keys
    def retry_limit_key mobile
      "sms_ctrl:#{@name}:retry_limit_key:#{mobile}"
    end

    def code_cache_key mobile
      "sms_ctrl:#{@name}:code_cache_key:#{mobile}"
    end
  end
end