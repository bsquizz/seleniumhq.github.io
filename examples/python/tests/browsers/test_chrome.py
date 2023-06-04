import re
import subprocess

import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.chrome.service import Service as ChromeService


def test_basic_options():
    options = ChromeOptions()
    driver = webdriver.Chrome(options=options)

    driver.quit()


def test_keep_browser_open():
    chrome_options = ChromeOptions()
    chrome_options.add_experimental_option("detach", True)

    driver = webdriver.Chrome(options=chrome_options)
    driver.get('http://selenium.dev')

    driver.quit()


def test_headless():
    chrome_options = ChromeOptions()
    chrome_options.add_argument("--headless=new")

    driver = webdriver.Chrome(options=chrome_options)
    driver.get('http://selenium.dev')

    driver.quit()


def exclude_switches():
    chrome_options = ChromeOptions()
    chrome_options.add_experimental_option('excludeSwitches', ['enable-automation'])

    driver = webdriver.Chrome(options=chrome_options)
    driver.get('http://selenium.dev')

    driver.quit()


def test_basic_service():
    service = ChromeService()
    driver = webdriver.Chrome(service=service)

    driver.quit()


def test_log_to_file(log_path):
    service = ChromeService(log_path=log_path)

    driver = webdriver.Chrome(service=service)

    with open(log_path, 'r') as fp:
        assert "Starting ChromeDriver" in fp.readline()

    driver.quit()


@pytest.mark.skip(reason="this is not supported, yet")
def test_log_to_stdout(capfd):
    service = ChromeService(log_output=subprocess.STDOUT)

    driver = webdriver.Chrome(service=service)

    out, err = capfd.readouterr()
    assert "Starting ChromeDriver" in out

    driver.quit()


def test_log_level(log_path):
    service = ChromeService(log_path=log_path, service_args=['--log-level=DEBUG'])

    driver = webdriver.Chrome(service=service)

    with open(log_path, 'r') as f:
        assert '[DEBUG]' in f.read()

    driver.quit()


def test_log_features(log_path):
    args = ['--append-log', '--readable-timestamp', '--verbose']
    service = ChromeService(log_path=log_path, service_args=args)

    driver = webdriver.Chrome(service=service)

    with open(log_path, 'r') as f:
        assert re.match("\[\d\d-\d\d-\d\d\d\d", f.read())

    driver.quit()


def test_build_checks(log_path):
    args = ['--log-level=DEBUG', '--disable-build-check']
    service = ChromeService(log_path=log_path, service_args=args)

    driver = webdriver.Chrome(service=service)

    expected = "[WARNING]: You are using an unsupported command-line switch: --disable-build-check"
    with open(log_path, 'r') as f:
        assert expected in f.read()

    driver.quit()

