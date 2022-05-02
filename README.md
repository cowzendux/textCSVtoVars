# textCSVtoVars
SPSS Python Extension function to take a set of comma-separated values in a text string and put each entry into a separate variable. 

This program was initially created to easily handle the output from Qualtrics checkbox questions. It allows users to identify a variable containing multiple entries separated by commas. It can then either create variables for the first entry, second entry, etc., or it can itentify the possible values across all of the entries and create a set of dummy-coded variables indicating whether a responded endorsed each entry, in any position in the list.

This and other SPSS Python Extension functions can be found at http://www.stat-help.com/python.html

## Usage
**textCSVtoVars(inVar, outPrefix="@", valueDummyCodes = False)**
* "inVar" is the name of the text variable containing the comma-separated values that need to be extracted.
* "outPrefix" is the beginning part of the name of the variables that will be created to hold the different values extracted from inVar.
* "valueDummyCodes" is a boolean argument that indicates whether the function should simply save the extracted values to a set of enumerated string values (when valueDummyCodes = False) or if it should create dummy-coded variables based on the names of the values (valueDummyCodes = True). Using valueDummyCodes=False will typically result in much fewer created variables than using valueDummyCodes=True.

## Example 1 - Creating variables for first entry, second entry, etc.
**textCSVtoVars(invar = "jobList", 
outPrefix = "Job", 
valueDummyCodes = False)**
* For this example, we are assuming that jobList is a variable that contains comma-separated values indicating the different jobs that an individual has had in their career, where the respondent provided text to describe each job that they had.
* For each respondent, the function will go through the text entry and find the different jobs that each respondent listed. The first listed job will be saved in the variable Job1, the second in Job2, etc. 
* The function will create a number of variables equal to the largest number of jobs that someone listed.

## Example 2 - Creating dummy codes for each possible entry
**textCSVtoVars(invar = "raceList", 
outPrefix = "Race", 
valueDummyCodes = True)**
* For this example, we are assuming that raceList is a variable that contains comma-separated values indicating the codes for different races that a respondent identifies with. The races are indicated by numeric codes where 1 = Asian, 2 = African American, etc. 
* For each respondent, the runction will go through the text entry to find the different races that each respondent endorsed. It will then create a set of race dummy codes labeled Race1, Race2, etc. If the person identifed as Asian (meaning that "1" was one of the comma-separated values in raceList), then Race1 will have the value of 1. If the person did not identify as Asian, then Race1 will have the value of 0. Similarly, If the person identifed as African American, (meaning that "2" was one of the comma-separated values in raceList), then Race2 will have the value of 1. If the person did not identify as African American, then Race2 will have the value of 0. 
* The function will create a number of variables equal to the number of different race options that were available.
