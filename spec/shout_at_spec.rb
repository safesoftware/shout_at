require 'spec_helper'

describe ShoutAt do

  before do
    @logger = Logger.new(STDOUT)
    allow(Logger).to receive(:new).and_return @logger
  end

  let(:init_hash_log) { {'group1' => {'rspec_level' => {'channel' => 'log'}}} }
  let(:init_hash_dummy) { {'group2' => {'rspec_level' => {'channel' => 'dummy'}}} }
  
  after do
    ShoutAt.send(:remove_const, :Group1) if ShoutAt.const_defined?(:Group1)
    ShoutAt.send(:remove_const, :Group2) if ShoutAt.const_defined?(:Group2)
  end

  describe '#init' do

    it 'should create module and method based on input hash' do
      expect { ShoutAt::Group1.rspec_level('hello world') }.to raise_exception NameError
      ShoutAt.init(init_hash_log)
      expect(@logger).to receive(:info).with "Shouter::Group1::RspecLevel: hello world: hello world"
      ShoutAt::Group1.rspec_level('hello world')
    end

    it 'should raise a shoutat error if initialization fails' do
      expect{ ShoutAt.init(init_hash_dummy) }.to raise_error ShoutAt::ShoutAtError, "Undefined shouter channel dummy"
    end

  end
  
  describe '#rescue_handler' do
    
    it 'should log exceptions if no error handler is defined' do
      ShoutAt.init(init_hash_log)
      expect_any_instance_of(Logger).to receive(:error).twice
      expect_any_instance_of( ShoutAt::Shouter ).to receive(:shout).and_raise StandardError
      ShoutAt::Group1.rspec_level('hello world')
    end
  
    it 'should call the exception handler on exceptions' do
      ShoutAt.rescue_handler = Proc.new { |exception| Airbrake.notify(exception) }
      ShoutAt.init(init_hash_log)
      expect(Airbrake).to receive(:notify).with StandardError
      expect_any_instance_of( ShoutAt::Shouter ).to receive(:shout).and_raise StandardError
      ShoutAt::Group1.rspec_level('hello world')
    end
    
  end

  describe 'SlackShouter' do
    describe '#initialize' do
      it 'should validate the presence of the web hook' do
        expect{ ShoutAt::SlackShouter.new('group', 'level', {}) }.to raise_error ArgumentError, "Web hook must be set for slack shouters"
        expect{ ShoutAt::SlackShouter.new('group', 'level', {'web_hook' => ""}) }.to raise_error ArgumentError, "Web hook must be set for slack shouters"
        ShoutAt::SlackShouter.new('group', 'level', {'web_hook' => "https://dummy"})
      end
    end
  end

  describe 'PagerdutyShouter' do
    describe '#initialize' do
      it 'should validate the presence of the service key' do
        expect{ ShoutAt::PagerdutyShouter.new('group', 'level', {}) }.to raise_error ArgumentError, "Service key must be provided for pagerduty shouters"
        expect{ ShoutAt::PagerdutyShouter.new('group', 'level', {'service_key' => ""}) }.to raise_error ArgumentError, "Service key must be provided for pagerduty shouters"
        ShoutAt::PagerdutyShouter.new('group', 'level', {'service_key' => "1234"})
      end
    end
  end

  describe 'EmailShouter' do
    describe '#initialize' do

      before do
        mailer = double(shout: true)
        allow(Object).to receive(:const_get).and_return mailer
      end

      it 'should validate the presence of the recipient email address' do
        expect{ ShoutAt::EmailShouter.new('group', 'level', {}) }.to raise_error ArgumentError, "Recipient email address must be provided for email shouters"
        expect{ ShoutAt::EmailShouter.new('group', 'level', {'to' => ""}) }.to raise_error ArgumentError, "Recipient email address must be provided for email shouters"
        ShoutAt::EmailShouter.new('group', 'level', {'to' => "stop@harper.ca"})
      end
    end
  end

end