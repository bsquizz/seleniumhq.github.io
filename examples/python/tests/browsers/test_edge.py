import re
import subprocess

import pytest
from selenium import webdriver
from selenium.webdriver.edge.options import Options as EdgeOptions
from selenium.webdriver.edge.service import Service as EdgeService


def test_basic_options():
    options = EdgeOptions()
    driver = webdriver.Edge(options=options)

    driver.quit()


def test_headless():
    options = EdgeOptions()
    options.add_argument("--headless=new")

    driver = webdriver.Edge(options=options)
    driver.get('http://selenium.dev')

    driver.quit()


def test_basic_service():
    service = EdgeService()
    driver = webdriver.Edge(service=service)

    driver.quit()


def test_log_to_file(log_path):
    service = EdgeService(log_path=log_path)

    driver = webdriver.Edge(service=service)

    with open(log_path, 'r') as fp:
        assert "Starting Microsoft Edge WebDriver" in fp.readline()

    driver.quit()


@pytest.mark.skip(reason="this is not supported, yet")
def test_log_to_stdout(capfd):
    service = EdgeService(log_output=subprocess.STDOUT)

    driver = webdriver.Edge(service=service)

    out, err = capfd.readouterr()
    assert "Starting Microsoft Edge WebDriver" in out

    driver.quit()


def test_log_level(log_path):
    service = EdgeService(log_path=log_path, service_args=['--log-level=DEBUG'])

    driver = webdriver.Edge(service=service)

    with open(log_path, 'r') as f:
        assert '[DEBUG]' in f.read()

    driver.quit()


def test_log_features(log_path):
    args = ['--append-log', '--readable-timestamp', '--verbose']
    service = EdgeService(log_path=log_path, service_args=args)

    driver = webdriver.Edge(service=service)

    with open(log_path, 'r') as f:
        assert re.match("\[\d\d-\d\d-\d\d\d\d", f.read())

    driver.quit()


def test_build_checks(log_path):
    args = ['--log-level=DEBUG', '--disable-build-check']
    service = EdgeService(log_path=log_path, service_args=args)

    driver = webdriver.Edge(service=service)

    expected = "[WARNING]: You are using an unsupported command-line switch: --disable-build-check"
    with open(log_path, 'r') as f:
        assert expected in f.read()

    driver.quit()

