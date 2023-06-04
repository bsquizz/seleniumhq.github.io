# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Edge' do
  let(:driver) { start_session }

  describe 'Options' do
    it 'basic options' do
      options = Selenium::WebDriver::Options.edge
      @driver = Selenium::WebDriver.for :edge, options: options
    end

    it 'add arguments' do
      options = Selenium::WebDriver::Options.edge(args: ['--headless=new'])
      @driver = Selenium::WebDriver.for :edge, options: options
      @driver.get('https://www.google.com')
    end
  end

  describe 'Service' do
    let(:file_name) { File.expand_path('msedgedriver.log') }

    after { FileUtils.rm_f(file_name) }

    it 'basic service' do
      service = Selenium::WebDriver::Service.edge
      @driver = Selenium::WebDriver.for :edge, service: service
    end

    it 'logs to file' do
      service = Selenium::WebDriver::Service.edge
      service.log = file_name

      @driver = Selenium::WebDriver.for :edge, service: service

      expect(File.readlines(file_name).first).to include('Starting Microsoft Edge WebDriver')
    end

    it 'logs to stdout' do
      service = Selenium::WebDriver::Service.edge
      service.log = $stdout

      expect {
        @driver = Selenium::WebDriver.for :edge, service: service
      }.to output(/Starting Microsoft Edge WebDriver/).to_stdout_from_any_process
    end

    it 'logs to stderr' do
      service = Selenium::WebDriver::Service.edge
      service.log = $stderr

      expect {
        @driver = Selenium::WebDriver.for :edge, service: service
      }.to output(/Starting Microsoft Edge WebDriver/).to_stderr_from_any_process
    end

    it 'sets log level' do
      service = Selenium::WebDriver::Service.edge
      service.log = file_name
      service.args << '--log-level=DEBUG'

      @driver = Selenium::WebDriver.for :edge, service: service

      expect(File.readlines(file_name).grep(/\[DEBUG\]:/).any?).to eq true
    end

    it 'sets log features' do
      service = Selenium::WebDriver::Service.edge

      service.args = ["--log-path=#{file_name}",
                      '--append-log',
                      '--readable-timestamp',
                      '--verbose']

      @driver = Selenium::WebDriver.for :edge, service: service

      expect(File.readlines(file_name).grep(/\[\d\d-\d\d-\d\d\d\d/).any?).to eq true
    end

    it 'disables build checks' do
      service = Selenium::WebDriver::Service.edge
      service.log = $stdout
      service.args << '--disable-build-check'
      service.args << '--log-level=DEBUG'

      warning = /\[WARNING\]: You are using an unsupported command-line switch: --disable-build-check/
      expect {
        @driver = Selenium::WebDriver.for :edge, service: service
      }.to output(warning).to_stdout_from_any_process
    end
  end
end
