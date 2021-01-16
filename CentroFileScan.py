#! python3
#This script scans an EDI file and uses regex to scan the file and output only the line parts necessary for you to look through.

import re
import sys
import time

#----------------------------------------------------------------------------------------------------------------------------------------
#FUNCTIONS SECTION

def fileScan():
    while True:
        try:
            fileName=input("Copy and paste the name of the Centro file you want to scan here: ")

            with open(str(fileName)+".edi", "r") as openFile: #ONLY WORKS FOR EDI FILES. CHANGE FILE EXTENSION FOR OTHER TYPES.
                
                scannedFileData=centroFile.read() #Reads the file and stores the data as a variable
                return scannedFileData
                openFile.close()

        except FileNotFoundError: #When you enter in the wrong numbers
            print("File not found. Please try again.")

def findLines(data):

    matchRegex=regexData.findall(data)


    for group in matchRegex:
        if group[0] == ("C"):
            print("-", group[0], group[1]) #Makes distinguishing C and D lines easier by adding a hyphen for C lines.
        else:
            print(group[0], group[1])
            
def closePrompt():
    
    closePrompt=input("Do you want to open another Centro-830 file? (y/n): ").lower()
    return closePrompt

#----------------------------------------------------------------------------------------------------------------------------------------
#START OF SCRIPT
            
regexData= re.compile(r"([C|D])\*[D]\*(\d{8})") #Regex for a C*D or D*D line groups. CD is group 0 and the numbers are group 1.

findLines(fileScan())
    
while True:
    
    closeConfirm=closePrompt()
    
    if closeConfirm == ("y" or "yes"):
        findLines(fileScan())
        continue 
    elif closeConfirm == ("n" or "no"):
        break
    else:
        print("ERROR: Unaccaptable value. Please try again.")

print("\nClosing Program")
time.sleep(2)
sys.exit()
