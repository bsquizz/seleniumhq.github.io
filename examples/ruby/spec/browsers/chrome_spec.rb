# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Chrome' do

  describe 'Options' do
    it 'basic options' do
      options = Selenium::WebDriver::Options.chrome
      @driver = Selenium::WebDriver.for :chrome, options: options
    end

    it 'add arguments' do
      options = Selenium::WebDriver::Options.chrome(args: ['--headless=new'])

      @driver = Selenium::WebDriver.for :chrome, options: options
      @driver.get('https://www.google.com')
    end

    it 'keeps browser open' do
      options = Selenium::WebDriver::Options.chrome(detach: true)

      @driver = Selenium::WebDriver.for :chrome, options: options
      @driver.get('https://www.google.com')
    end

    it 'excludes switches' do
      options = Selenium::WebDriver::Options.chrome(exclude_switches: ['enable-automation'])

      @driver = Selenium::WebDriver.for :chrome, options: options
      @driver.get('https://www.google.com')
    end

    it 'uses proxy', exclusive: { ci: false, reason: 'no proxy running on CI' } do
      proxy = Selenium::WebDriver::Proxy.new(http: 'http://127.0.0.1:8080',
                                             ssl: 'http://127.0.0.1:8080')
      options = Selenium::WebDriver::Options.chrome proxy: proxy
      service = Selenium::WebDriver::Service.chrome(args: ['--verbose'])
      @driver = Selenium::WebDriver.for :chrome, options: options, service: service
      @driver.get('https://google.com')
      expect(@driver.title).to eq 'Watir'
    end
  end

  describe 'Service' do
    let(:file_name) { File.expand_path('chromedriver.log') }

    after { FileUtils.rm_f(file_name) }

    it 'basic service' do
      service = Selenium::WebDriver::Service.chrome
      @driver = Selenium::WebDriver.for :chrome, service: service
    end

    it 'logs to file' do
      service = Selenium::WebDriver::Service.chrome
      service.log = file_name

      @driver = Selenium::WebDriver.for :chrome, service: service

      expect(File.readlines(file_name).first).to include('Starting ChromeDriver')
    end

    it 'logs to stdout' do
      service = Selenium::WebDriver::Service.chrome
      service.log = $stdout

      expect {
        @driver = Selenium::WebDriver.for :chrome, service: service
      }.to output(/Starting ChromeDriver/).to_stdout_from_any_process
    end

    it 'sets log level' do
      service = Selenium::WebDriver::Service.chrome
      service.log = file_name
      service.args << '--log-level=DEBUG'

      @driver = Selenium::WebDriver.for :chrome, service: service

      expect(File.readlines(file_name).grep(/\[DEBUG\]:/).any?).to eq true
    end

    it 'sets log features' do
      args = ["--log-path=#{file_name}", '--verbose']
      service = Selenium::WebDriver::Service.chrome(args: args)

      service.args << '--append-log'
      service.args << '--readable-timestamp'

      @driver = Selenium::WebDriver.for :chrome, service: service

      expect(File.readlines(file_name).grep(/\[\d\d-\d\d-\d\d\d\d/).any?).to eq true
    end

    it 'disables build checks' do
      service = Selenium::WebDriver::Service.chrome log: file_name, args: ['--verbose']

      service.args << '--disable-build-check'

      @driver = Selenium::WebDriver.for :chrome, service: service

      warning = /\[WARNING\]: You are using an unsupported command-line switch: --disable-build-check/
      expect(File.readlines(file_name).grep(warning).any?).to eq true
    end
  end
end
