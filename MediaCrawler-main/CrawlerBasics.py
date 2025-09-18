import selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
import getpass


def yesNo(message):
    inp = ""
    while not ((inp == "Y") | (inp == "N")):
        inp = input(message).upper()
    
    if inp == "Y":
        return True
    else:
        return False

def mediaHopperLogin(username, password, driver):
    driver.get('https://media.ed.ac.uk')

    driver.find_element(By.ID, 'userMenuToggleBtn').click()



    loginButton = driver.find_elements(By.CLASS_NAME, 'login-btn')[1] #apparently 2 things with this class?

    WebDriverWait(driver, 5, 0.1).until(EC.element_to_be_clickable(loginButton))

    loginButton.click()

    driver.find_element(By.ID, 'login').send_keys(username)
    driver.find_element(By.ID, 'submit').click()


    driver.find_element(By.ID, 'password').send_keys(password)
    submit = driver.find_element(By.ID, 'submit')
    submit.click()

    WebDriverWait(driver, 5, 0.1).until(EC.title_is('Media Hopper Create'))

def tagMedia(driver, nTags):
    for nTag in nTags.split(", "):
        tagField = driver.find_element(By.ID, 'tags-list') # failed one time?
        WebDriverWait(driver, 5, 0.1).until(EC.element_to_be_clickable(tagField))
        tagField.click()
    
        tagInput = driver.find_element(By.ID, 's2id_autogen1') #risky maybe?
        tagInput.send_keys(nTag)
    

        WebDriverWait(driver, 5, 0.1).until(EC.presence_of_element_located((By.CLASS_NAME, 'select2-match')))

    #enter = driver.find_element(By.ID, 'select2-result-label-4') #not consistent sometimes should use select2-result-label-3 if mediahopper has not encountered the tag before. when this is the case label-4 is blank so maybe could check it

        opts = driver.find_elements(By.CLASS_NAME, "select2-match")

        added = False
        for opt in opts:
            if(opt.text == nTag):
                opt.click()
                added = True

        if not added:
            tagInput.send_keys(Keys.ESCAPE)

def setCourseIDforMedia(driver, ID):
    codeInput =  driver.find_element(By.ID, "customdata-CourseCode")

    if codeInput.get_attribute("value") == "": 
        codeInput.send_keys(ID) 

def addIDtoTitle(driver, id):
    titleInput = driver.find_element(By.ID, "Entry-name")
    
    titleOld =  titleInput.get_attribute("value")

    if not(id in titleOld):
        titleInput.clear()
        titleInput.send_keys(f"{id}: {titleOld}")

def addCodeToDescription(driver, id):
    iframe = driver.find_element(By.CLASS_NAME, "wysihtml5-sandbox")

    driver.switch_to.frame(iframe)

    WebDriverWait(driver, 5, 0.1).until(EC.presence_of_element_located((By.TAG_NAME,"body")))
    desc = driver.find_element(By.TAG_NAME,"body")

    #should read to see if code already there and if empty
    if EC.presence_of_element_located((By.TAG_NAME,"div")):
        contents = driver.find_elements(By.TAG_NAME,"body")

        for cont in contents:

            #print(len(cont.text))
            #print(len(id))
            #print((id in cont.text))

            if cont.text == "Enter Description...":
                ### Description is empty

                #print("description empty")
                desc.send_keys(id)
                driver.switch_to.default_content()
                return 
            
            if id in cont.text:

                driver.switch_to.default_content()
                return # description already contains course code
            
        
        desc.send_keys(Keys.RETURN)
        desc.send_keys(id)    # description not empty but does not contain course code
    
    driver.switch_to.default_content()