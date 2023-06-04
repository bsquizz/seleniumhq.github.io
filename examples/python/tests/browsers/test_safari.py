import sys

import pytest
from selenium import webdriver
from selenium.webdriver.safari.options import Options as SafariOptions
from selenium.webdriver.safari.service import Service as SafariService


@pytest.mark.skipif(sys.platform != "darwin", reason="requires Mac")
def test_basic_options():
    options = SafariOptions()
    options.use_technology_preview = True
    service = SafariService(executable_path = '/Applications/Safari Technology Preview.app/Contents/MacOS/safaridriver')
    driver = webdriver.Safari(options=options, service=service)

    driver.quit()
