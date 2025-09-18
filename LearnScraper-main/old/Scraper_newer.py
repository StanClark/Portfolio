
import tkinter.messagebox
# import emoji.unicode_codes
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



courseCodes = None
username = None
password = None
mode = None
driver = None
courseCodes = "" # string with new course name separated with \n?

# GUI: this should really not be a global var
textInput = None 
progText = None
progress = None

def load_login():
    import json
    with open('login_details.json', 'r') as file:
        login = json.load(file)
        username = login.get("username", None)
        password = login.get("password", None)
    return username, password

# if login is to be entered via gui
def startVals():
    loginLearn(username,password)


def getAttendance(courseCode):
    progText.set("getting attendence pages")
    #main = WebDriverWait(driver, 5, 0.1).until(EC.presence_of_element_located((By.CLASS_NAME, "course-outline-row")))
    sidebar = WebDriverWait(driver, 5, 0.1).until(EC.presence_of_element_located((By.TAG_NAME, "aside")))
    collabText = WebDriverWait(sidebar, 5, 0.1).until(EC.presence_of_element_located((By.XPATH, "//*[contains(text(),'Class Collaborate')]")))
    collabBar = getNthParent(collabText,3)


    expandButton = WebDriverWait(collabBar, 5, 0.1).until(EC.presence_of_element_located((By.CLASS_NAME, "overflow-menu-button")))
    time.sleep(4) # should be exchanged for better method solution not yet found
    try:
        expandButton.click()
    except:     #exception for if a pop up appears
        driver.find_element(By.XPATH, "//*[@data-analytics-id='course.announcements.modal.close.button']").click() # not yet tested
        expandButton.click()

    
    driver.find_element(By.XPATH, "//*[contains(text(),'View room report')]").click()

    #WebDriverWait(driver, 10, 0.1).until(EC.element_to_be_clickable((By.CLASS_NAME, "overflow-menu-button"))).click()
    collabFrame = WebDriverWait(collabBar, 5, 0.1).until(EC.presence_of_element_located((By.XPATH, "//*[@name='collab-iframe']")))
    driver.switch_to.frame(collabFrame)


    dropdown = WebDriverWait(driver, 15, 0.1).until(EC.element_to_be_clickable((By.CLASS_NAME, "dropdown")))

    time.sleep(1)
    dropdown.click()
    #driver.find_element(By.CLASS_NAME, "dropdown").click()

    driver.find_element(By.XPATH, "//*[contains(text(),'All Previous Sessions')]").click()
    
    pages = 0
    try:
        pageFooter = driver.find_element(By.CLASS_NAME,"pagination")
        pages = len(pageFooter.find_elements(By.TAG_NAME,"li")) - 2
        print(pages)
    except:
        pass

    
    if pages > 0:  
        for i in range(pages):
                downloadPage(courseCode)
                pageFooter = driver.find_element(By.CLASS_NAME,"pagination")
                time.sleep(1)
                pageFooter.find_elements(By.TAG_NAME,"li")[-1].click() # clicks next page button
    else:
        downloadPage(courseCode)


#🍂 used when collecting attendance. To open the report page
#   and change the range of viewable sessions to encompass all.
def goToReportPage(sType):

    temp = WebDriverWait(sType,5,0.1).until(EC.element_to_be_clickable((By.CLASS_NAME,"session-options")))
    time.sleep(2)
    temp.click()

    sType.find_element(By.CLASS_NAME, "session-reports").click()
    driver.find_element(By.XPATH,"//*[contains(text(),'Recent Reports')]").click()
    driver.find_element(By.XPATH,"//*[contains(text(),'Reports in a Range')]").click()
    inputs = driver.find_elements(By.TAG_NAME,"input")

    inputId = "UNASSIGNED"
    for i in inputs:
        id = i.get_attribute("id")
        if "startDate" in id:
            inputId = id


    script_1 = f"document.getElementById('{inputId}').value = '01/01/1900';"
    driver.execute_script(script_1)
    change_event_script_1 = f"""
    var event = new Event('change', {{ bubbles: true }});
    document.getElementById('{inputId}').dispatchEvent(event);
    """
    driver.execute_script(change_event_script_1)



#🍂 takes all downloads from attendance and makes them into one csv
def combineAttendance():
    empty = True
    allLogs = None
    allNames = os.listdir( os.path.join(sys.path[0], "ScraperDownloads"))
    
    
    index = 1
    for name in allNames:
        progText.set(f"Combining downloads ({index}/{len(allNames)})")
        curDf = pd.read_csv(  os.path.join(sys.path[0], "ScraperDownloads",name))

        nameSplit = name.split("_")

        sessionType = "_".join(nameSplit[1:])
        course = nameSplit[0]
        typeCol = [sessionType] * len(curDf)
        courseCol = [course] * len(curDf)

        curDf['course'] = courseCol
        curDf['sessionType'] = typeCol
        
        if empty:
            allLogs = curDf
            empty = False
        else:
            allLogs = pd.concat([allLogs, curDf])
        
        index += 1

    allLogs.to_csv("allLogsAttendance.csv")

def numberInDownloads():
    return len(os.listdir( os.path.join(sys.path[0], "ScraperDownloads")))

#🍂 used in collecting attendance to make name more meaningful
def renameRecentDownload(newName, initialDownloads):
    newName = newName.replace(":","").replace("?","").replace("/","-")
    while numberInDownloads == initialDownloads:
        time.sleep(0.2)

    time.sleep(1) # sometimes the system partial downloads appear and the system tries to rename them
    filename = max(
                    [ os.path.join(sys.path[0], "ScraperDownloads", file_in_folder) 
                    for file_in_folder in os.listdir(  os.path.join(sys.path[0], "ScraperDownloads")   )]
                ,key=os.path.getmtime) # previously ctime may function differently on mac

    progText.set(f"downloading {' '.join(newName.split('_')[1:-1])}") # technically already downloaded, but still good way of showing progress
    
    if "_" in filename:
        print("fail")
        for file in os.listdir( os.path.join(sys.path[0], "ScraperDownloads")  ):
            timeEdited = os.path.getmtime( os.path.join(sys.path[0], "ScraperDownloads", file)  ) % 1000
            print(f"{file}: {timeEdited}")
        pass
    
    if "'" in filename:
        print(f"issue with {filename}")
        return

    while newName in os.listdir(os.path.join(sys.path[0], "ScraperDownloads")):
        lastNum = int(newName.split("_")[-1].split(".")[0])
        
        newName = newName[:-5] + str(lastNum+1) + ".csv"
        print(newName)

        pass

    # 

    os.rename(rf"{filename}", os.path.join("ScraperDownloads", newName) ) # failed at  HEIN110432023-4SV1FLEX Week 1 Discussion 12042024 1430-1600 12-04-2024.csv
    pass

#🍂 used when collecting attendance to download the attendance for a session
#   renames the download file to something meaningful
def downloadPage(courseCode):
    sessionTypes = driver.find_element(By.CLASS_NAME, "item-list").find_elements(By.XPATH, '//*[@bb-session-list-item="session"]')


    i = 0
    for sType in sessionTypes:
        lines_of_sName = sType.text.replace(' ','_').splitlines()
        sName = lines_of_sName[0] if len(lines_of_sName) > 0 else sType.text
        print("downloadPage sName",sName)
        goToReportPage(sType)

        WebDriverWait(driver, 5, 0.1).until(EC.presence_of_element_located((By.CLASS_NAME, "attendance-column")))
        reports = driver.find_elements(By.CLASS_NAME,"attendance-column")
        
        # the loop ensure no files with duplicate names are attempted to be made
        for i in range(len(reports)):
            reports[i].find_element(By.TAG_NAME, "button").click()
            pre = numberInDownloads()
            
            downloadButton = WebDriverWait(driver, 5, 0.1).until(EC.presence_of_element_located((By.XPATH, "/html/body/div[1]/div/div[2]/div[2]/div/div/div/div/div/div/div/aside/ul/li[2]/div/div/button/span")))
            time.sleep(1)
            downloadButton.click()


            renameRecentDownload(f"{courseCode}_{sName}_{i}.csv",pre)

            driver.find_element(By.CLASS_NAME,"bb-close").click()
            goToReportPage(sType)
            WebDriverWait(driver, 5, 0.1).until(EC.presence_of_element_located((By.CLASS_NAME, "attendance-column")))
            reports = driver.find_elements(By.CLASS_NAME,"attendance-column")
            pass

        driver.find_element(By.CLASS_NAME,"bb-close").click()
        i += 1

#🍂 this is called by the start button
def searchCourses():
    global tk, tkinter, mode, progText, progress
    setMode = mode.get() # to stop the mode being changed mid scrape
    print("SetMode",setMode)
    startVals()

    courseCodes = getCourseInput()

    index = 0
    for courseCode in courseCodes:
        print(f"On course {courseCode} ({index+1}/{len(courseCodes)})")#
        progText.set(f"going to {courseCode} ({index+1}/{len(courseCodes)})")
        navToCourse(courseCode)

        # if setMode ==1:
        #     getdiscussion(courseCode)#get3Star1Wish(courseCode)
        
        if setMode == 2:
            getGrades()

        if setMode == 0:
            getAttendance(courseCode) 

        if setMode == 3:
            getClassRegister() 

        index += 1
        driver.get("https://www.learn.ed.ac.uk/ultra/course")

        progress.set((index/len(courseCodes))*100)
        print("progress text",index/len(courseCodes))
        print("multi", (index/len(courseCodes))*100)
    
    if setMode == 0:
        combineAttendance()

    tkinter.messagebox.showinfo("Complete",  "Scrape Finished") 
    progText.set("")
    progress.set(0)
    # empty downloadfile??

class Modes(Enum):
    Diaries = 1
    Grades = 2
    Attendance = 0
    ClassRegister = 3

def getNthParent(child,n):
    xpath = '.' + '/parent::*' * n
    return child.find_element(By.XPATH,xpath)

def is_emoji(char):
    return False
#char in emoji.EMOJI_DATA

def filterByText(entList, query):
    for ent in entList:
        if query in ent.text:
            return ent
    
    return None

#🍂 reads input box on UI
def getCourseInput():
    global textInput
    input = textInput.get("1.0", "end-1c")
    return input.split(",")

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


def getGrades():
    WebDriverWait(driver, 10, 0.1).until(EC.presence_of_element_located((By.XPATH, "//*[text() = 'Gradebook']"))).click() # clicks gradebook tab
    WebDriverWait(driver, 10, 0.1).until(EC.presence_of_element_located((By.XPATH, '//*[@aria-label="Markbook marks"]'))).click() # opens markbook
    WebDriverWait(driver, 10, 0.1).until(EC.presence_of_element_located((By.CLASS_NAME, 'open-downLoad-settings'))).click() #opens download settings


    selButton = WebDriverWait(driver, 10, 0.1).until(EC.presence_of_element_located((By.XPATH,"/html/body/div[1]/div[2]/bb-base-layout/div/main/div[5]/div/div/div/div/div/bb-grades-download-main-panel/div[1]/div[2]/div[1]/fieldset/div/div/div[1]/ul/li/label/span[2]")))
    selButton.click()

    # downloadPanel = driver.find_element(By.XPATH,"/html/body/div[1]/div[2]/bb-base-layout/div/main/div[5]/div/div/div/div/div/bb-grades-download-main-panel")

    # buttons = downloadPanel.find_element(By.CLASS_NAME, "ms-Button-flexContainer")
    download_button_xpath = "//button[@data-analytics-id='course.grades.grades-download.settings.downloadAction.primaryButton']"
    time.sleep(1)
    print("download_button", download_button_xpath)
    download_button = driver.find_element("xpath", download_button_xpath)
    print("download_button", download_button)
    action = ActionChains(driver) 
    action.move_to_element(download_button).pause(1).click().perform()
    print("download_button", download_button)
    time.sleep(1)
    print("download_button", "done")

#🍂 sets the download folder for the opened browser to be in scraper downloads
    # this is also where you would set the mode to driverless if you did not want to 
    # to have the browser appear

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

def loginLearn(username,password):
    global driver

    driver.get("https://www.learn.ed.ac.uk/ultra/course")

    driver.find_element(By.CLASS_NAME, "easelogin-bt").click()

    WebDriverWait(driver, 5, 0.1).until(EC.presence_of_element_located((By.ID, "login")))
    driver.find_element(By.ID, 'login').send_keys(username)
    driver.find_element(By.ID, 'submit').click()

    driver.find_element(By.ID, 'password').send_keys(password)
    driver.find_element(By.ID, 'submit').click()

def navToCourse(cCode):
    ## finds and inputs into search bar of learn courses page
    search =  WebDriverWait(driver, 10, 0.1).until(EC.presence_of_element_located((By.XPATH, '//*[@id="courses-overview-filter-search"]')))
    search.clear() ###
    search.send_keys(cCode) # stops the scraper selecting its own search. Was [:-1] not sure why
    print("selected_course", "about to get")

    time.sleep(2)
    full_xpath =  f"//*[contains(text(), '{cCode.upper()}')]/ancestor::article"
    print("selected_course", full_xpath)

    course_panel = driver.find_element("xpath", full_xpath)

    ##selects the first (and hopefully only) course available after search
    # course = WebDriverWait(driver, 10, 0.1).until(EC.presence_of_element_located((By.XPATH, "//*[contains(text(), '"+cCode+"')]/ancestor::article")))
    print("selected_course", course_panel)
    action = ActionChains(driver) 
    action.move_to_element(course_panel).pause(2).click().perform()
    print("selected_course", course_panel)


def getClassRegister():
    print("getClassRegister")
    return "banana"

######################      USER INTERFACE       ####################
def user_interface():

    global username, password, tk, tkinter, mode, textInput, progText, progress

    window = tk.Tk()

    mode = tk.IntVar(value=Modes.Grades.value)

    window.rowconfigure([0,1,2,3,4,5,6,7],weight=1, minsize=50)
    window.columnconfigure([0,1,2,3,4,5,6,7,8,9],weight=1, minsize=50)

    progressFrame = tk.Frame(window)
    progressFrame.rowconfigure([0,1],weight=1, minsize=50)
    progressFrame.columnconfigure([0,1,2],weight=1, minsize=50)
    progressFrame.grid(row=4, column=4,columnspan=4,sticky="nswe")
    #progressFrame.columnconfigure([0,1,2,3,4,5,6,7,8,9],weight=1, minsize=50)

    textInputLabel = tk.Label(text="names or ids of courses. Coma separated")
    textInput =  tk.Text(width=25,height=40)
    startButton = tk.Button(text="Start",command=lambda: threading.Thread(target=searchCourses).start())

    progress = tk.IntVar()
    progText = tk.StringVar()
    progressbar = ttk.Progressbar(progressFrame, variable=progress)
    progressText = tk.Label(progressFrame, textvariable=progText, fg="black")

    radioHolder = tk.Frame(window)
    radioHolder.grid(row=2, column=5,columnspan=2, sticky="wens")

    tk.Radiobutton(radioHolder, 
        text="Attendance",
        padx = 5, 
        variable=mode, 
        value=0).pack(side='left')

    tk.Radiobutton(radioHolder, 
                text="Stars and Wishes",
                padx = 5, 
                variable=mode, 
                value= 1).pack(side="left")

    tk.Radiobutton(radioHolder, 
        text="Grades",
        padx = 5, 
        variable=mode, 
        value=2).pack(side='left')
    
    tk.Radiobutton(radioHolder, 
        text="Class Register",
        padx = 5, 
        variable=mode, 
        value=3).pack(side='left')





    textInputLabel.grid(row=1, column=1,columnspan=2,rowspan=1,padx=5, pady=5, sticky="nswe")
    textInput.grid(row=2, column=1,columnspan=2,rowspan=5,padx=5, pady=5, sticky="nswe")
    startButton.grid(row=1, column=5,columnspan=2,padx=5, pady=5, sticky="wens")


    progressbar.grid(row=0, column=0,columnspan=3,padx=5, pady=5, sticky="we")
    progressText.grid(row=1, column=0,columnspan=3,padx=0, pady=0, sticky="we")


    tk.Tk().withdraw()

    username, password = load_login()

    if (not(username and password)):
        username = tkinter.simpledialog.askstring("Username", "Enter username:")
        password = tkinter.simpledialog.askstring("Password", "Enter password:", show='*')

    window.mainloop()



setup_driver()
user_interface()