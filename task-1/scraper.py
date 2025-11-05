from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.relative_locator import locate_with
import time


# 2. Initialize the Chrome WebDriver
driver = webdriver.Chrome()

try:
    # 3. Navigate to a website
    driver.get("https://www.linkedin.com/")
    print(f"Page title: {driver.title}")

    time.sleep(3)

    # 6. Perform another action, e.g., find an element on the new page
    # Example: Find a heading on the About page
    sign_in = driver.find_element(By.LINK_TEXT, "Sign in")
    sign_in.click()
    
    email = driver.find_element(By.ID, "username")
    email.send_keys("utest4926@gmail.com")

    password = driver.find_element(By.ID, "password")
    password.send_keys("~Qme@EpGJ3!#m!!")

    time.sleep(1)

    sign_in = driver.find_element(By.CSS_SELECTOR, "[aria-label='Sign in']")
    sign_in.click()

    time.sleep(3)
    driver.get("https://www.linkedin.com/in/akkshay")
    time.sleep(3)
    name = driver.find_element(By.TAG_NAME, "h1")
    bio = driver.find_element(locate_with(By.CLASS_NAME, "text-body-medium").below(name))

    about_title = driver.find_element(By.CLASS_NAME, "text-heading-large")
    about = driver.find_element(locate_with(By.TAG_NAME, "div").below(about_title))

    print(name.text)
    print(bio.text)
    print(about.text)


    url_elems = ["experience", "education", "skills"]

    for elem in url_elems:
        url = f"https://www.linkedin.com/in/akkshay/details/{elem}"
        driver.get(url)

        section = driver.find_element(By.TAG_NAME, "h1")
        info = driver.find_element(locate_with(By.TAG_NAME, "ul").below(section))

        items = info.find_elements(By.XPATH, "./li")

        print([i.text for i in items])


except Exception as e:
    print(f"An error occurred: {e}")

finally:
    # 7. Close the browser
    driver.quit()
    print("Browser closed.")

