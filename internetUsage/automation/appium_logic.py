from appium import webdriver
from appium.webdriver.common.mobileby import MobileBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

def get_android_driver():
    """Initialize the Appium WebDriver for Android."""
    desired_caps = {
        'platformName': 'Android',
        'automationName': 'UiAutomator2',
        'deviceName': 'Android Device',
        'autoGrantPermissions': True,
        'noReset': True,
        'browserName': 'Chrome'  # We'll use Chrome since it's a web-based interface
    }

    # Connect to Appium server
    driver = webdriver.Remote('http://localhost:4723/wd/hub', desired_caps)
    return driver

def login_and_get_usage_android(username, password):
    """Android version of login and usage data retrieval."""
    try:
        driver = get_android_driver()
        wait = WebDriverWait(driver, 20)
        
        # Navigate to login page
        driver.get('http://10.220.20.12/index.php/home/login')
        time.sleep(2)  # Wait for page to load
        
        # Login form interaction
        username_field = wait.until(EC.presence_of_element_located(
            (MobileBy.CSS_SELECTOR, "#username")))
        username_field.send_keys(username)
        
        password_field = driver.find_element(MobileBy.CSS_SELECTOR, "#password")
        password_field.send_keys(password)
        
        # Submit form
        form = driver.find_element(MobileBy.CSS_SELECTOR, "form")
        form.submit()
        
        # Wait for home page and extract total usage
        wait.until(EC.url_contains("/home/index"))
        time.sleep(2)  # Wait for data to load
        
        usage_element = wait.until(EC.presence_of_element_located(
            (MobileBy.CSS_SELECTOR, "#updates > div:first-child > table > tbody > tr:nth-child(6) > td:nth-child(2)")))
        total_usage = usage_element.text.strip().split(' ')[0]
        
        # Navigate to usage table
        driver.get('http://10.220.20.12/index.php/home/usageTable')
        time.sleep(2)
        
        # Extract usage history
        rows = wait.until(EC.presence_of_all_elements_located(
            (MobileBy.CSS_SELECTOR, "#dyntable > tbody > tr")))
        
        usage_history = []
        for row in rows:
            cells = row.find_elements(MobileBy.CSS_SELECTOR, "td")
            if len(cells) >= 3:
                usage_history.append({
                    'start': cells[0].text.strip(),
                    'end': cells[1].text.strip(),
                    'duration': cells[2].text.strip()
                })
        
        return {
            'usage': [total_usage] + [entry['duration'] for entry in usage_history]
        }
        
    except Exception as e:
        print(f"Error during Android automation: {e}")
        return {'usage': ['0']}
        
    finally:
        if 'driver' in locals():
            driver.quit()

# Usage example:
# data = login_and_get_usage_android("your_username", "your_password")
