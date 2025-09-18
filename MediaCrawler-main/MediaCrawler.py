import selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException
import getpass
import CrawlerBasics
import pandas as pd


links = pd.read_excel(r"..\MediaCrawler\links.xlsx")

username = input('Enter username: ')
password = getpass.getpass(prompt='Enter password: ')

tagging = CrawlerBasics.yesNo("Would you like to add a tags to the videos(Y/N)? ")

if tagging: tags = input('input the tags you would like applied to the videos as a comma space seperated list: ')

IDing = CrawlerBasics.yesNo("Would you like to add the course code to videos from courseCodes.txt (Y/N)? ")

if not (tagging | IDing):
    print("No actions have been selected")
    exit()

driver = webdriver.Firefox()

CrawlerBasics.mediaHopperLogin(username, password, driver)
# Issue with browser not having time to register that we have logged in before it jumps to the next link



notAdded = []


for index, row in links.iterrows():
    link = row['MH Link']


    driver.get(link)

    ################### Checks Page is editable ##########
    try:
        driver.find_element(By.ID, 'entryActionsMenuBtn').click()

        editButton = driver.find_element(By.ID, 'tab-Edit') # NoSuchElement Exception?
    except NoSuchElementException:
        notAdded.append(link)
        continue

    WebDriverWait(driver, 5, 0.1).until(EC.element_to_be_clickable(editButton))

    editButton.click()

    if tagging: CrawlerBasics.tagMedia(driver, tags)

    if IDing: CrawlerBasics.addCodeToDescription(driver, row['Course ID'])

    

    driver.find_element(By.ID, 'Entry-submit').click()

    print(f"{round((index/len(links))*100, 1)}%")

print(f"{len(notAdded)} links could not be added because of a lack of permissions")
print(notAdded)

