
import selenium
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver import FirefoxOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.actions.wheel_input import ScrollOrigin
from time import sleep

import tkinter as tk
from tkinter import ttk

# import emoji

import getpass
import numpy as np
import pandas as pd
import time
import datetime
import re
import os.path
import sys

import os
import shutil

import tkinter.simpledialog
import threading

from enum import Enum

class Datasets(Enum):
    Diaries = 0
    Grades = 1
    Attendance = 2
    ClassRegister = 3

def get_login():
    import json
    global username, password

    with open('login_details.json', 'r') as file:
        login = json.load(file)
        username = login.get("username", None)
        password = login.get("password", None)

    if (not(username and password)):
        username = input("Enter Learn username:")
        password = input("Enter Learn password:")

    return username, password

def loginLearn():
    global driver
    username,password = get_login()

    driver.get("https://www.learn.ed.ac.uk/ultra/course")

    driver.find_element(By.CLASS_NAME, "easelogin-bt").click()

    WebDriverWait(driver, 5, 0.1).until(EC.presence_of_element_located((By.ID, "login")))
    driver.find_element(By.ID, 'login').send_keys(username)
    driver.find_element(By.ID, 'submit').click()

    driver.find_element(By.ID, 'password').send_keys(password)
    driver.find_element(By.ID, 'submit').click()

def setup_driver():
    global driver
    #🍂 this is used to stop the scraper for opening discussion pages it does not haver permissons for
#    the key represents the course the blocked discussion page is in and the value the name
    diaryBlacklist = {
        'HEIN110372023-4': ['Datathon Peer Support Groups (Optional)'],
        'HEIN110482023-4': ['Week 5 Discussions','Week 4']
    }

    starsAndWish = pd.DataFrame(columns=('Name','Course','Diary','star1','star2','star3','wish','raw','date'))
    try:
        driver = webdriver.Firefox(options=optionSetup())
    except:
        print("unable to open firefox please restart")
        tkinter.messagebox.showinfo("Error",  "Firefox failed to open please restart") 

    actions = ActionChains(driver)


def optionSetup():
    ddir = os.path.join(sys.path[0], "ScraperDownloads")

    
    options = webdriver.FirefoxOptions()
    options.enable_downloads = True
    options.set_preference("browser.download.useDownloadDir", True)
    options.set_preference("browser.download.folderList", 2)
    options.set_preference("browser.download.manager.showWhenStarting", False)
    options.set_preference("browser.download.dir",ddir)
    options.set_preference("browser.helperApps.neverAsk.saveToDisk", "application/msexcel")
    options.add_argument("--enabled-managed-downloads true")

    #options.add_argument('--headless')

    return options


def scrollToBottom(scrollable):
    print("scrollToBottom START")
    scroll_pause_time = 1  # Wait time between scrolls

    last_height = driver.execute_script("return arguments[0].scrollHeight", scrollable)

    while True:
        driver.execute_script("arguments[0].scrollTop = arguments[0].scrollHeight", scrollable)
        time.sleep(scroll_pause_time)
        
        new_height = driver.execute_script("return arguments[0].scrollHeight", scrollable)
        if new_height == last_height:
            break
        last_height = new_height

    print("scrollToBottom END")

def navToCourse(courseCode):
    ## finds and inputs into search bar of learn courses page
    print("selected_course 0", courseCode)

    search =  WebDriverWait(driver, 10, 0.1).until(EC.presence_of_element_located((By.XPATH, '//*[@id="courses-overview-filter-search"]')))
    search.clear() ###
    search.send_keys(courseCode) # stops the scraper selecting its own search. Was [:-1] not sure why
    print("selected_course", "about to get", courseCode)

    time.sleep(4)
    full_xpath =  f"//*[contains(text(), '{courseCode.upper()}')]/ancestor::article"
    print("selected_course", full_xpath)

    course_panel = driver.find_element("xpath", full_xpath)

    ##selects the first (and hopefully only) course available after search
    # course = WebDriverWait(driver, 10, 0.1).until(EC.presence_of_element_located((By.XPATH, "//*[contains(text(), '"+cCode+"')]/ancestor::article")))
    print("selected_course", course_panel)
    action = ActionChains(driver) 
    action.move_to_element(course_panel).pause(2).click().perform()
    print("selected_course", course_panel)

def save_list_to_file(list_of_dicts, filename):
    records_df = pd.DataFrame.from_records(list_of_dicts)
    records_df.to_csv(filename)

def scrapeCourseDiscussionsDirectlyFromUrls( course_id, urls_of_discussion_boards):
    now = datetime.datetime.now().strftime("day-%Y-%m-%d-time-%H-%M-%S")
    print(now)
    scraped_discussion_posts = []
    for index, url_of_discussion_board in enumerate(urls_of_discussion_boards):
        print(f"STARTED course:{course_id} discussion:{url_of_discussion_board} ({index}/{len(urls_of_discussion_boards)})")
        scraped_discussions_new = getPostsFromBoardURLLink(url_of_discussion_board, course_id) 
        scraped_discussion_posts.extend(scraped_discussions_new)
        print(f"FINISHED course {course_id} ({index}/{len(urls_of_discussion_boards)}) - so far we have {len(scraped_discussion_posts)} ({len(scraped_discussions_new)} new) posts")
    save_list_to_file(scraped_discussion_posts, f"discussions_{course_id}_{now}.csv")


def scrapeCourseDiscussionUrls(courseCodes):
    for index, courseCode in enumerate(courseCodes):
        print(f"STARTED course {courseCode} ({index}/{len(courseCodes)})")
        navToCourse(courseCode)
        scraped_discussions = getUrlsOfDiscussionBoardPostsForCourse(courseCode) 

        print(f"FINISHED course {courseCode} ({index}/{len(courseCodes)})")



def scrapeCourseDataset(courseCodes, dataset = Datasets.Diaries):
    global tk, tkinter, mode, progress
    for index, courseCode in enumerate(courseCodes, start= 1):
        print(f"STARTED course {courseCode} ({index}/{len(courseCodes)})")
        navToCourse(courseCode)

        if dataset == Datasets.Diaries:
            scraped_discussions = getdiscussionBoardPostsForCourse(courseCode) #get3Star1Wish(courseCode)


        print(f"FINISHED course {courseCode} ({index}/{len(courseCodes)})")


def scrollUntilAllClass(scrlOrg, searchType, searchParam):
    scrollActionCount = 0
    entriesSoFar = 0
    entries = []
    while scrollActionCount < 30:
        print("scroll attempt",scrollActionCount)
        try:
            ActionChains(driver).scroll_from_origin(scrlOrg, 0, 500).perform()
        except Exception as ex:
            print("ERROR!!!!",ex)
                
        time.sleep(0.1)
        entries = driver.find_elements(searchType, searchParam)
        if entriesSoFar == len(entries):
            scrollActionCount += 1
        else:
            scrollActionCount = 0
        entriesSoFar = len(entries)
    print("entriesSoFar", entriesSoFar, entries)
    return entries

def waitClick(entity,threshold):
    print("wait click on", entity.text)
    count = 0
    while count < threshold:
        try:
            entity.click()
            return
        except:
            count += 1
            time.sleep(0.1)
    
    entity.click() # if the threshold is crossed one more click is attempted so the click error message shows.


def scroll_to_bottom_and_get_all(css_class_of_list_items, and_expand_css_class = True):
    time.sleep(2)  # wait before scroll
    items = driver.find_elements(By.CSS_SELECTOR, f".{css_class_of_list_items}")
    print("WILL SCROLL!",css_class_of_list_items, len(items))
    items_so_far = 0
    while len(items) > items_so_far:
        items_so_far = len(items)
        print("ITEMS!",len(items))
        scroll_to(items[-1])
        # driver.execute_script("arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});", items[-1])
        time.sleep(3)  # wait after scroll
        items = driver.find_elements(By.CSS_SELECTOR, f".{css_class_of_list_items}")
        print("DID SCROLL!",css_class_of_list_items, len(items), ">?", items_so_far)
    

    # if and_expand_css_class:

    #     explandable_items = driver.find_elements(By.CSS_SELECTOR, f".root")
    #     print("CAN EXPAND!", len(explandable_items))
    #     for explandable_item in reversed(explandable_items):
    #         scroll_to(explandable_item)
    #         time.sleep(1)
    #         action = ActionChains(driver) 
    #         action.move_to_element(explandable_item).pause(2).click().perform()


    # time.sleep(1)
    # items = driver.find_elements(By.CSS_SELECTOR, f".{css_class_of_list_items}")
    # print("DID EXPAND!", len(items))

    return items

def navigate_and_click(some_item):
        scroll_to(some_item)
        time.sleep(1)
        driver.execute_script("arguments[0].click();", some_item)

def scroll_to(some_item):
        time.sleep(1)
        driver.execute_script("arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});", some_item)

def getPostsFromBoardLinks(discussion_boards, courseCode):
    now = datetime.datetime.now()
    discussion_posts = []
    for discussion_board_one in discussion_boards:
        WebDriverWait(driver, 10, 0.1).until(EC.element_to_be_clickable(discussion_board_one))
        disName = discussion_board_one.find_element(By.TAG_NAME,"a")
        print( "disname", disName.text)

        navigate_and_click(disName)

        discussion_posts_html = scroll_to_bottom_and_get_all("comment-entry")

        for post_html in discussion_posts_html:
            post = readDiaryEntry(post_html, disName.text)
            post['board'] = disName.text
            discussion_posts.append(post)
        
        save_list_to_file(discussion_posts, f"discussions_{courseCode}_{now}_.csv")

        close_buttons = driver.find_elements(By.CSS_SELECTOR, "button.bb-close")
        navigate_and_click(close_buttons[-1])

    return discussion_posts

def getPostsFromBoardURLLink(discussion_boards_url, courseCode):
    discussion_posts = []
    print("2")
    # wait until the search is visible (learn loaded)
    WebDriverWait(driver, 10, 0.1).until(
            lambda driver_at_point: driver_at_point.find_element(By.XPATH, '//*[@id="courses-overview-filter-search"]')
            )
    sleep(4)
    driver.get(discussion_boards_url)
    sleep(4)
    WebDriverWait(driver, 10, 0.1).until(
        lambda driver_at_point: driver_at_point.find_element(By.CSS_SELECTOR, ".comment-entry, .is-empty-discussion") 
        )
    disName = driver.find_element(By.CSS_SELECTOR,".editable-title-container")
    print( "discussion name", disName.text)

    discussion_posts_html = scroll_to_bottom_and_get_all("comment-entry")

    for post_html in discussion_posts_html:
        post = readDiaryEntry(post_html, disName.text)
        post['board'] = disName.text
        discussion_posts.append(post)

    close_buttons = driver.find_elements(By.CSS_SELECTOR, "button.bb-close")
    navigate_and_click(close_buttons[-1])

    return discussion_posts

def getUrlsOfDiscussionBoardPostsForCourse(courseCode):
    # discussion = WebDriverWait(driver, 10, 0.1).until(EC.element_to_be_clickable((By.XPATH, "/html/body/div[1]/div[2]/bb-base-layout/div/main/div[3]/div/div[2]/div/div/div/div/div/div[2]/bb-course-navigation/div/div/nav/ul/li[4]/a")))
    discussions_link = WebDriverWait(driver, 10, 0.1).until(
        EC.element_to_be_clickable((By.LINK_TEXT, "Discussions"))
    )
    try: 
        discussions_link.click()
    except:     #exception for if a pop up appears, eg announcement
        driver.find_element(By.XPATH, "//*[@data-analytics-id='course.announcements.modal.close.button']").click() # not yet tested
        discussions_link.click()

    discussion_boards = scroll_to_bottom_and_get_all("content-list-item", "root")
    discussion_boards_urls = []
    # TODO
    # discussion_boards_urls = getUrlsOfBoards(discussion_boards, courseCode)
    # discussion_boards_urls = getPostsFromBoardLinks(discussion_boards, courseCode)

    print("DONE! got some posts:", len(discussion_boards_urls), "from boards", len(discussion_boards_urls))
    return discussion_boards_urls


def getdiscussionBoardPostsForCourse(courseCode):
    # discussion = WebDriverWait(driver, 10, 0.1).until(EC.element_to_be_clickable((By.XPATH, "/html/body/div[1]/div[2]/bb-base-layout/div/main/div[3]/div/div[2]/div/div/div/div/div/div[2]/bb-course-navigation/div/div/nav/ul/li[4]/a")))
    discussions_link = WebDriverWait(driver, 10, 0.1).until(
        EC.element_to_be_clickable((By.LINK_TEXT, "Discussions"))
    )
    try: 
        discussions_link.click()
    except:     #exception for if a pop up appears, eg announcement
        driver.find_element(By.XPATH, "//*[@data-analytics-id='course.announcements.modal.close.button']").click() # not yet tested
        discussions_link.click()

    discussion_boards = scroll_to_bottom_and_get_all("content-list-item", "root")
    discussion_posts = []
    discussion_posts = getPostsFromBoardLinks(discussion_boards, courseCode)

    print("DONE! got some posts:", len(discussion_posts), "from boards", len(discussion_boards))
    return discussion_posts


def readDiaryEntry(ent, currentDiary):
    # print(currentDiary)
    # print(ent.text)
    print("read diary:",currentDiary)
    links = ent.find_elements(By.TAG_NAME,"a")

    if len(links) == 0:
        name = ent.find_element(By.CLASS_NAME, "username").text
    else:
        name = links[0].text#ent.find_element(By.CLASS_NAME, "username").text
    # print("name", name)
    text = ent.find_element(By.CLASS_NAME, "bb-editor-container").text
    # print("text", text)

    date = ent.find_element(By.CLASS_NAME, "timestamp-container").text
    # print("date",date)
    # pass
    return {'name':name,
            'date':date,
            'board': currentDiary,
            'text':text }