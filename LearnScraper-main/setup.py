import subprocess
import sys

def install(name):
    subprocess.call([sys.executable, '-m', 'pip', 'install', name])

install('selenium')
install('wheel')
install('pandas')
install('numpy')


import selenium
import numpy as np
import pandas as pd