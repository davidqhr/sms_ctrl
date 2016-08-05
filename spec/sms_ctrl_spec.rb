require 'spec_helper'
require 'timecop'

class FakeCache
  def initialize
    clear
    @expires_in = {}
  end

  def clear
    @h = {}
  end

  def read key
    expire = @expires_in[key]
    if expire && expire < Time.now
      @h.delete(key)
      @expires_in.delete(key)
      nil
    else
      @h[key]
    end
  end

  def write key, value, options = {}
    @h[key] = value

    if options[:expires_in]
      @expires_in[key] = Time.now + options[:expires_in]
    end
  end
end

describe SmsCtrl do
  before(:each) do
    SmsCtrl.debug = false
    SmsCtrl.cache = FakeCache.new
    SmsCtrl.cache.clear

    SmsCtrl.clear
    SmsCtrl.register('default_case', {
      sender: -> (mobile, code, params) { 'ok' }
    })
  end

  it 'cache read & write' do
    SmsCtrl.cache.write 'key', 'value'
    expect(SmsCtrl.cache.read('key')).to eq('value')
  end

  it 'cache read & write' do
    SmsCtrl.cache.write 'key', 'value'
    expect(SmsCtrl.cache.read('key')).to eq('value')
  end

  it 'cache expires' do
    Timecop.freeze(2088, 1, 1, 0, 0, 0) do
      SmsCtrl.cache.write 'key', 'value', expires_in: 10
      expect(SmsCtrl.cache.read('key')).to eq('value')
    end

    # 5 sec later
    Timecop.freeze(2088, 1, 1, 0, 0, 5) do
      expect(SmsCtrl.cache.read('key')).to eq('value')
    end

    # 11 sec later
    Timecop.freeze(2088, 1, 1, 0, 0, 11) do
      expect(SmsCtrl.cache.read('key')).to eq(nil)
    end
  end

  it 'default' do
    SmsCtrl.clear
    sms_case = SmsCtrl.register('user_register', {
      sender: -> (mobile, code, params) { nil }
    })
    expect(SmsCtrl.default).to eq(sms_case)
  end

  it 'illegal_mobile_number' do
    result = SmsCtrl.send_sms('wrong_mobile_number', '321')

    expect(result[:success]).to eq(false)
    expect(result[:error_type]).to eq(:illegal_mobile)
  end

  it 'retry_limit' do
    result = SmsCtrl.send_sms('13000000000', '321')
    expect(result[:data]).to eq('ok')
    expect(SmsCtrl.check_code('13000000000', '321')).to eq(true)

    result = SmsCtrl.send_sms('13000000000', '321')
    expect(result[:success]).to eq(false)
    expect(result[:error_type]).to eq(:retry_limit)
    expect(SmsCtrl.check_code('13000000000', '321')).to eq(true)
  end

  it 'different case' do
    SmsCtrl.clear

    SmsCtrl.register('user_register', {
      expires_in: 20,
      sender: -> (mobile, code, params) { 'ok' }
    })

    SmsCtrl.register('user_reset_password', {
      expires_in: 10,
      sender: -> (mobile, code, params) { 'ok' }
    })

    user_register_result = nil
    user_reset_password_result = nil

    Timecop.freeze(2011, 1, 1, 0, 0, 0) do
      user_register_result = SmsCtrl['user_register'].send_sms('13000000000', '321')
      user_reset_password_result = SmsCtrl['user_reset_password'].send_sms('13000000000', '567')
    end

    # 5 sec later
    Timecop.freeze(2011, 1, 1, 0, 0, 5) do
      expect(SmsCtrl['user_register'].check_code('13000000000', '321')).to eq(true)
      expect(SmsCtrl['user_reset_password'].check_code('13000000000', '567')).to eq(true)
    end

    # 15 sec later
    Timecop.freeze(2011, 1, 1, 0, 0, 15) do
      expect(SmsCtrl['user_register'].check_code('13000000000', '321')).to eq(true)
      expect(SmsCtrl['user_reset_password'].check_code('13000000000', '567')).to eq(false)
    end

    # 25 sec later
    Timecop.freeze(2011, 1, 1, 0, 0, 25) do
      expect(SmsCtrl['user_register'].check_code('13000000000', '321')).to eq(false)
      expect(SmsCtrl['user_reset_password'].check_code('13000000000', '567')).to eq(false)
    end
  end
end
