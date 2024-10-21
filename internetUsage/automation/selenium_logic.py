from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import time
import subprocess
import re
import os
import requests # type: ignore
import zipfile
import platform

CHROME_DRIVER_PATH = '/path/to/chromedriver'  # Update this to the location of your chromedriver

def get_chrome_version():
    """Retrieve the installed Google Chrome version from the server, compatible with multiple OS."""
    try:
        os_name = platform.system()
        
        if os_name == "Linux":
            # For Linux
            version_output = subprocess.check_output(["google-chrome", "--version"]).decode("utf-8")
        elif os_name == "Windows":
            # For Windows
            version_output = subprocess.check_output(
                r'wmic datafile where name="C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe" get Version /value', 
                shell=True
            ).decode("utf-8")
        elif os_name == "Darwin":  # macOS
            # For macOS
            version_output = subprocess.check_output(
                ["/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", "--version"]
            ).decode("utf-8")
        else:
            return None
        
        version_match = re.search(r'(\d+)\.\d+\.\d+\.\d+', version_output)
        if version_match:
            return version_match.group(1)  # Return major version number
        
    except Exception as e:
        print(f"Error retrieving Chrome version: {e}")

    return None

def fetch_chromedriver_version(request):
    # Fetch the latest ChromeDriver version from the URL
    url = "https://chromedriver.storage.googleapis.com/LATEST_RELEASE"
    response = requests.get(url)

    # Check if the request was successful
    if response.status_code == 200:
        version = response.text.strip()
        return version  # Return as JSON response
    else:
        return "129"


def download_chromedriver(version):
    """Download ChromeDriver for the specified version and place the executable at a specific path."""
    """https://storage.googleapis.com/chrome-for-testing-public/129.0.6668.100/win64/chromedriver-win64.zip"""
    base_url = "https://storage.googleapis.com/chrome-for-testing-public"
    version = version + ".0.6668.100"
    
    # Determine the OS and select the appropriate chromedriver
    os_name = platform.system()
    if os_name == "Windows":
        driver_url = f"{base_url}/{version}/win64/chromedriver-win64.zip"
        zip_destination = "C:/project/chromedriver.zip"  # Store the ZIP in C:/
        extract_destination = "C:/path/to/chromedriver-win64/"  # Folder where the executable will go
        chromedriver_path = os.path.join(extract_destination, "chromedriver.exe")
    elif os_name == "Darwin":  # macOS
        driver_url = f"{base_url}/{version}/mac-x64/chromedriver-mac-x64.zip"
        zip_destination = "/path/to/chromedriver.zip"
        extract_destination = "/path/to/chromedriver-mac-x64/"
        chromedriver_path = os.path.join(extract_destination, "chromedriver.exe")
    else:  # Assume Linux
        driver_url = f"{base_url}/{version}/linux64/chromedriver-linux64.zip"
        zip_destination = "/path/to/chromedriver.zip"
        extract_destination = "/path/to/chromedriver-linux64/"
        chromedriver_path = os.path.join(extract_destination, "chromedriver.exe")

    # Download the ChromeDriver ZIP
    response = requests.get(driver_url)
    
    if response.status_code == 200:
        # Save the ZIP file to the desired location
        with open(zip_destination, "wb") as file:
            file.write(response.content)
        
        # Extract the ZIP file contents to the destination folder
        with zipfile.ZipFile(zip_destination, "r") as zip_ref:
            zip_ref.extractall(extract_destination)
        
        # Delete the ZIP file after extraction
        os.remove(zip_destination)
        
        # Make sure the executable file has proper permissions (for Linux/macOS)
        if os_name != "Windows":
            os.chmod(chromedriver_path, 0o755)  # Make it executable on Linux/macOS
        
        return chromedriver_path  # Return the path to the ChromeDriver executable
    else:
        raise Exception(f"Failed to download ChromeDriver version {version}: {response.status_code}")

def setup_chromedriver():
    """Set up ChromeDriver for use with Selenium."""
    version = get_chrome_version()
    if not version:
        raise Exception("Unable to get Chrome version.")
    
    # Check if ChromeDriver is already downloaded and set up in the desired path
    chromedriver_path = "C:/path/to/chromedriver-win64/chromedriver.exe"  # Desired path for the executable
    if not os.path.exists(chromedriver_path):
        print("Downloading ChromeDriver...")
        chromedriver_path = download_chromedriver(version)

    if not os.path.exists(chromedriver_path):
        raise Exception(f"ChromeDriver not found at {chromedriver_path}")
    
    return chromedriver_path


def get_driver():
    """Initialize the Chrome WebDriver."""
    chrome_driver_path = setup_chromedriver()
    service = Service(chrome_driver_path)
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")  # Run in headless mode
    options.add_argument("--disable-gpu")  # Disable GPU usage (for systems where GPU is enabled)
    options.add_argument("--no-sandbox")  # Sandbox might cause issues in headless mode
    options.add_argument("--disable-dev-shm-usage")  # Overcome limited resource problems in containers
    options.add_argument("--disable-infobars")  # Prevent infobars from appearing
    options.add_argument("--disable-extensions")  # Disable browser extensions for cleaner session
    options.add_argument("--disable-software-rasterizer")  # Prevent software rendering
    options.add_argument("--mute-audio")  # Mute any audio from the page (if applicable)
    options.add_argument("--log-level=3")  # Set Chrome's log level to reduce output
    options.add_argument("--window-size=1920x1080") 

    # Enable automation exclusion and prevent the browser from being detected as Selenium
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_argument("disable-blink-features=AutomationControlled")
    
    driver = webdriver.Chrome(service=service, options=options)
    return driver

def login_and_get_usage(username, password):
    table_data = []

    driver = get_driver()
    driver.get("http://10.220.20.12/index.php/home/login")

    driver.find_element("id", "username").send_keys(username)
    driver.find_element("id", "password").send_keys(password + Keys.RETURN)
    
    time.sleep(2)  # Wait for the page to load

    usageElement = driver.find_element("xpath", '//*[@id="updates"]/div[1]/table/tbody/tr[6]/td[2]')

    usage = usageElement.text.split(" ")[0]  # Extract usage from element
    table_data.append(usage)

    driver.get('http://10.220.20.12/index.php/home/usageTable')
    
    historyElement = driver.find_elements(By.XPATH, '//*[@id="dyntable"]/tbody/tr')

    if historyElement:
        for row in historyElement:
            cols = row.find_elements(By.TAG_NAME, 'td')
            row_data = [col.text for col in cols]
            table_data.append(row_data)

    driver.quit()
    return table_data
