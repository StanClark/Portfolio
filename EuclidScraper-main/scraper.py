import selenium
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.keys import Keys
import getpass
import pandas as pd
import time
import datetime
import re
import os.path

def loginEuclid(username, password, driver):
    driver.get('https://www.ease.ed.ac.uk/cosign.cgi?cosign-eucsCosign-www.star.euclid.ed.ac.uk&https://www.star.euclid.ed.ac.uk/urd/sits.urd/run/siw_sso.token')
    

    driver.find_element(By.ID, 'login').send_keys(username)
    driver.find_element(By.ID, 'submit').click()

    driver.find_element(By.ID, 'password').send_keys(password)
    submit = driver.find_element(By.ID, 'submit')
    submit.click()

    letters = [0] * 3
    
    WebDriverWait(driver, 5, 0.1).until(EC.element_to_be_clickable((By.ID, "c1label")))
    l = driver.find_element(By.ID, "c1label").text
    letters[0] = l[len(l) -1]

    l = driver.find_element(By.ID, "c2label").text
    letters[1] = l[len(l) -1]

    l = driver.find_element(By.ID, "c3label").text
    letters[2] = l[len(l) -1]

    keyLetters = getpass.getpass(prompt=f'please enter letters {letters[0]}, {letters[1]} and {letters[2]} of your memorable word (no space or other characters):')
    
    driver.find_element(By.ID, "c1").send_keys(keyLetters[0])
    driver.find_element(By.ID, "c2").send_keys(keyLetters[1])
    driver.find_element(By.ID, "c3").send_keys(keyLetters[2])
    driver.find_element(By.ID, 'loginsubmit').click()

def goToNewWindow(driver):

    for window_handle in driver.window_handles:
        if not(window_handle in prevVisited):
            driver.switch_to.window(window_handle)
            break


def getFromTable(s, point):
    header = point.find_element(By.XPATH,"//th[ contains (text(), '"+s+"' ) ]")
    parent = header.find_element(By.XPATH, "./..")
    return parent.find_element(By.XPATH, "./td").text

def getFromSpans(s, point):
    header = point.find_element(By.XPATH,"//span[ contains (text(), '"+s+"' ) ]")
    parent = header.find_element(By.XPATH, "./..")
    return parent.find_elements(By.XPATH, "./span")[1].text

def getCourses(yTable):
    cells = yTable.find_element(By.TAG_NAME, "tbody").find_elements(By.TAG_NAME, "td")

    courses = ""

    for cell in cells:
        if (cell.get_attribute("class") != "text-center") & (len(cell.text) > 0):
            courses += "'" + cell.text + "'" + ","
    
    return courses[:-1]

start = time.time()

studentData = pd.DataFrame(columns=['UUN','Age','Region','Gender','Nationality', 'Programme', 'Year', 'Status', 'Route', 'Year 1 Courses','Year 2 Courses', 'Year 3 Courses'])

programmes = pd.read_excel(r'..\EuclidScraper\programmes.xlsx')

nationsFile = open('nations.txt', 'r') #the nations in this filed are compared to term time address to find the nation it is in. However some people using different spellings of countries so some are missed. adding to this list is encouraged
nations = nationsFile.read().casefold().splitlines()
nationsFile.close()

username = input('Enter username: ')
password = getpass.getpass(prompt='Enter password: ')

options = Options()
options.add_argument("--headless")
driver = webdriver.Firefox(options=options)

prevVisited = []
prevVisited.append(driver.current_window_handle)




loginEuclid(username, password, driver)
username = None
password = None #nice to not have your full password pop up in the debug sidebar

WebDriverWait(driver, 5, 0.1).until(EC.presence_of_element_located((By.ID, 'PRSSA1')))
driver.find_element(By.ID, 'PRSSA1').click()

#driver.find_element(By.CLASS_NAME, "sv-list-group-item sv-list-group-item-overflow").click()
driver.find_element(By.XPATH,"//*[ contains (text(), ' Search for student(s) | Student Hub ' ) ]").click()

goToNewWindow(driver)

WebDriverWait(driver, 5, 0.1).until(EC.presence_of_element_located((By.ID, "search-frame")))
driver.switch_to.frame(driver.find_element(By.ID, "search-frame"))


time.sleep(5) # doesnt work sometimes but wait until functions would not work
driver.find_element(By.XPATH,"//input[@value='fullPanel']").click()
driver.find_element(By.XPATH,"//input[@value='pin']").click()

i = 0

pickingUp = False
if os.path.isfile("./progress.txt"): #Picking up will only be true if the scraper was interupted. When its true the scraper will go back to the last saved student and start from scraping from there
    studentData = pd.read_csv(r'..\EuclidScraper\output.csv')

    pickingUp = True

    f = open('progress.txt',"r")
    progress = f.read().split(",") # progress[0] will be the course code where left of and progress[1] will be how many students in it got
    f.close()

    i = len(studentData)

for index, row in programmes.iterrows():               # session field in form has default value being the current session, this wouldnt be hard to change before beginning search
    curProgramme = row["Code"]

    if pickingUp:
        if curProgramme != progress[0]: continue

    WebDriverWait(driver, 20, 0.1).until(EC.element_to_be_clickable((By.ID, "ANSWER.TTQ.MENSYS.10.")))
    codeInput = driver.find_element(By.ID, "ANSWER.TTQ.MENSYS.10.")
    codeInput.clear()
    codeInput.send_keys(row["Code"])
    codeInput.send_keys(Keys.ENTER)      


    driver.switch_to.default_content()

    try:
        WebDriverWait(driver, 20, 0.1).until(lambda d : "-" in driver.title)
    except TimeoutException:
        closeButton = driver.find_elements(By.XPATH, "//button[text()='Close']")
        WebDriverWait(driver, 10, 0.1).until(EC.element_to_be_clickable(closeButton[1]))
        closeButton[1].click()
        driver.switch_to.frame(driver.find_element(By.ID, "search-frame"))

        continue


    results = driver.find_element(By.CLASS_NAME, "results").find_elements(By.XPATH, "./*")

    curStudent = 0
    for result in results:

        if pickingUp:
            if curStudent == int(progress[1]):
                pickingUp = False
                curStudent +=1
                continue
            else:
                curStudent +=1
                continue
        
        WebDriverWait(driver, 20, 0.1).until(EC.element_to_be_clickable(result))
        result.click()

        driver.switch_to.frame("stu-hub-frame")


        WebDriverWait(driver, 60, 0.1).until(EC.presence_of_element_located((By.CLASS_NAME, "table.table-bordered.table-condensed.uoe-data-table")))
        tables = driver.find_elements(By.CLASS_NAME, "table.table-bordered.table-condensed.uoe-data-table")

        uun = getFromTable("UUN", driver)
        age = re.search(r'\((.*?)\)',getFromTable("Date of Birth", driver)).group(1) # extracts number in brackets from dob
        gender = getFromTable("Gender", driver)
        nationality = getFromTable("Nationality", driver)
        year = getFromSpans("Year", driver)
        status = getFromSpans("Status", driver)
        programme = row["Name"]


        add = getFromTable("Address",tables[4])
        added = False
        region = None
        for line in add.splitlines():
            if line.casefold() in nations:
                region = line
                added = True
        
        #if not added:      #useful for checking missing term time addresses
        #    print(add)
        #    print("--------")
            

        buttonHolder = driver.find_element(By.CLASS_NAME, "nav.nav-pills.nav-stacked")
        buttons = buttonHolder.find_elements(By.XPATH, "//li[normalize-space()='Assessment']")

        for button in buttons:
            if button.is_displayed():

                for j in range(1,100):
                    try:
                        button.click() #sometimes throws "Element <li id="SRL.SCJ.STUHUB_T_ASM" class="child"> is not clickable at point (152,561) because another element <a class="btn"> obscures it" despite using wait wait until clickable
                        break
                    except: 
                        time.sleep(0.5)

                break
        
        yearTables = driver.find_elements(By.CLASS_NAME, "table.table-bordered.table-condensed.table-align-middle.table-uoe-assessment")

        y1Courses = None
        y2Courses = None
        y3Courses = None

        for yTable in yearTables:
            ylabel = yTable.find_element(By.CLASS_NAME, "year-label").text

            match ylabel:
                case "Year 1":
                    y1Courses = getCourses(yTable)
                case "Year 2":
                    y2Courses = getCourses(yTable) 
                case "Year 3":
                    y3Courses = getCourses(yTable)
        
        
        studentData.loc[i, "UUN"] = uun
        studentData.loc[i, "Age"] = age
        studentData.loc[i, "Gender"] = gender
        studentData.loc[i, "Nationality"] = nationality
        studentData.loc[i, "Year"] = year
        studentData.loc[i, "Status"] = status
        studentData.loc[i, "Programme"] = curProgramme
        studentData.loc[i, "Region"] = region
        studentData.loc[i, 'Year 1 Courses'] = y1Courses
        studentData.loc[i, 'Year 2 Courses'] = y2Courses
        studentData.loc[i, 'Year 3 Courses'] = y3Courses


        f = open("progress.txt","w")
        f.write(f"{curProgramme},{curStudent},{str(datetime.timedelta(seconds=time.time() - start))}")
        f.close()
        studentData.to_csv("output.csv", index=False) # make it so name shows date of collection???


        driver.switch_to.default_content()
        i+=1
        curStudent += 1
        print(f"{row['Name']}({curStudent}/{len(results)}) Elapsed time {str(datetime.timedelta(seconds=time.time() - start))}")

    
    driver.switch_to.frame("stu-hub-frame")
    WebDriverWait(driver, 20, 0.1).until(EC.element_to_be_clickable((By.CLASS_NAME, "fa.fa-search.fa-fw")))
    time.sleep(1)
    driver.find_element(By.CLASS_NAME, "fa.fa-search.fa-fw").click()
    driver.switch_to.default_content()
    driver.switch_to.frame("search-frame")

os.remove("progress.txt")
exit()