require 'spec_helper'

describe ShoutAt do

  before do
    @logger = Logger.new(STDOUT)
    allow(Logger).to receive(:new).and_return @logger
  end

  describe '#init' do

    let(:init_hash_log) { {'group1' => {'rspec_level' => {'channel' => 'log'}}} }
    let(:init_hash_dummy) { {'group2' => {'rspec_level' => {'channel' => 'dummy'}}} }

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