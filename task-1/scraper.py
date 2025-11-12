import csv
from dotenv import load_dotenv
import logging
import os
import random
import time
from contextlib import contextmanager
from seleniumwire import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.support.relative_locator import locate_with
from selenium.common.exceptions import NoSuchElementException, TimeoutException

load_dotenv()

PROXY_HOST = os.getenv("PROXY_HOST")
PROXY_PORT = os.getenv("PROXY_PORT")
PROXY_USER = os.getenv("PROXY_USER")
PROXY_PASS = os.getenv("PROXY_PASS")
LINKEDIN_USER = os.getenv("LINKEDIN_USER")
LINKEDIN_PASS = os.getenv("LINKEDIN_PASS")

OUTPUT_CSV = "linkedin.csv"
INPUT_FILE = "profiles.txt"

proxy = f"{PROXY_HOST}:{PROXY_PORT}"
if PROXY_USER:
    proxy = f"{PROXY_USER}:{PROXY_PASS}@{PROXY_HOST}:{PROXY_PORT}"

seleniumwire_options = {
    "proxy": {
        "http": f"http://{proxy}",
        "https": f"https://{proxy}",
        "no_proxy": "localhost,127.0.0.1",
    }
}

def sleep_random(min_sec=2, max_sec=5):
    """Sleep for a random interval between requests."""
    t = random.uniform(min_sec, max_sec)
    time.sleep(t)


@contextmanager
def init_driver():
    """Initialize and clean up the Chrome driver safely."""

    options = Options()
    # profile = FirefoxProfile("/home/srikant/.mozilla/firefox/hauzzh6z.default-release-1759939514478")
    # options.profile = profile
    # options.accept_insecure_certs = True

    driver = webdriver.Firefox(seleniumwire_options=seleniumwire_options, options=options)
    try:
        yield driver
    finally:
        driver.quit()
        logging.info("Browser closed.")


def login_linkedin(driver):
    """Log into LinkedIn using credentials from environment variables."""

    logging.info("Logging into LinkedIn...")
    driver.get("https://www.linkedin.com/login")
    sleep_random()

    driver.find_element(By.ID, "username").send_keys(LINKEDIN_USER)
    sleep_random()
    driver.find_element(By.ID, "password").send_keys(LINKEDIN_PASS)
    sleep_random()

    driver.find_element(By.CSS_SELECTOR, "[aria-label='Sign in']").click()
    sleep_random()
    logging.info("Successfully logged in.")


def extract_profile(driver, profile_url):
    """Extract basic profile information from a LinkedIn profile."""
    logging.info(f"Scraping profile: {profile_url}")
    driver.get(profile_url)
    sleep_random()

    try:
        name = driver.find_element(By.TAG_NAME, "h1").text.strip()
    except NoSuchElementException:
        name = ""

    try:
        bio = driver.find_element(locate_with(By.CLASS_NAME, "text-body-medium").below(
            driver.find_element(By.TAG_NAME, "h1")
        )).text.strip()
    except NoSuchElementException:
        bio = ""

    try:
        about_section = driver.find_element(By.ID, "about")
        about_div = about_section.find_element(By.XPATH, "./following-sibling::div[contains(@class, 'display-flex')]")
        about_text = about_div.find_element(By.CSS_SELECTOR, '[aria-hidden="true"]').text.strip()
    except NoSuchElementException:
        about_text = ""

    details = {"url": profile_url, "name": name, "bio": bio, "about": about_text}

    # Fetch experience, education, skills sections
    for section in ["experience", "education", "skills"]:
        section_url = f"{profile_url}/details/{section}"
        driver.get(section_url)
        sleep_random()

        try:
            items = driver.find_element(By.CLASS_NAME, "pvs-list__container") \
                .find_element(By.TAG_NAME, "ul") \
                .find_elements(By.TAG_NAME, "li")
            details[section] = " | ".join(i.text.strip() for i in items if i.text.strip())
        except NoSuchElementException:
            details[section] = ""
        except Exception as e:
            logging.warning(f"Failed to scrape {section} for {profile_url}: {e}")
            details[section] = ""

    return details


def write_to_csv(filename, data, fieldnames):
    """Write scraped data to CSV."""
    file_exists = os.path.isfile(filename)
    with open(filename, "a", newline="", encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        if not file_exists:
            writer.writeheader()
        writer.writerow(data)


# ---------------------------
# Main Execution
# ---------------------------

def main():
    with init_driver() as driver:
        try:
            sleep_random()
            login_linkedin(driver)

            with open(INPUT_FILE, "r", encoding="utf-8") as f:
                profiles = [line.strip() for line in f if line.strip()]

            fieldnames = ["url", "name", "bio", "about", "experience", "education", "skills"]

            for profile_url in profiles:
                try:
                    data = extract_profile(driver, profile_url)
                    write_to_csv(OUTPUT_CSV, data, fieldnames)
                    logging.info(f"✅ Saved: {data['name']} ({profile_url})")
                except TimeoutException:
                    logging.warning(f"Timeout while scraping: {profile_url}")
                except Exception as e:
                    logging.error(f"Error scraping {profile_url}: {e}")

        except Exception as e:
            logging.exception(f"Critical error: {e}")


if __name__ == "__main__":
    main()
