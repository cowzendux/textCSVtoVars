* Encoding: UTF-8.
* textCSVtoVars
* Python function to take a set of comma-separated values in a text string and put
* each entry into a separate variable.
* by Jamie DeCoster

**** Usage: textCSVtoVars(inVar, outPrefix="@", valueDummyCodes = False)
**** "inVar" is the name of the text variable containing the comma-separated values that need
* to be extracted.
**** "outPrefix" is the beginning part of the name of the variables that will be created to hold
* the different values extracted from inVar.
**** "valueDummyCodes" is a boolean argument that indicates whether the function should 
* simply save the extracted values to a set of enumerated string values (when 
* valueDummyCodes = False) or if it should create dummy-coded variables based on the names 
* of the values (valueDummyCodes = True). Using valueDummyCodes=False will typically
* result in much fewer created variables than using valueDummyCodes=True.

* Example 1:
**** textCSVtoVars(invar = "jobList", 
outPrefix = "Job",
valueDummyCodes = False)
* For this example, we are assuming that jobList is a variable that contains comma-separated
* values indicating the different jobs that an individual has had in their career, where the 
* respondent provided text to describe each job that they had.
* For each respondent, the function will go through the text entry and find the different jobs that
* each respondent listed. The first listed job will be saved in the variable Job1, the second in
* Job2, etc. The function will create a number of variables equal to the largest number of
* jobs that someone listed.

* Example 2:
**** textCSVtoVars(invar = "raceList", 
outPrefix = "Race",
valueDummyCodes = True)
* For this example, we are assuming that raceList is a variable that contains comma-separated
* values indicating the codes for different races that a respondent identifies with. The races
* are indicated by numeric codes where 1 = Asian, 2 = African American, etc. 
* For each respondent, the runction will go through the text entry to find the different races
* that each respondent endorsed. It will then create a set of race dummy codes labeled 
* Race1, Race2, etc. If the person identifed as Asian (meaning that "1" was one of the 
* comma-separated values in raceList), then Race1 will have the value of 1. If the person did
* not identify as Asian, then Race1 will have the value of 0. Similarly, If the person identifed 
* as African American, (meaning that "2" was one of the comma-separated values in raceList), 
* then Race2 will have the value of 1. If the person did not identify as African American, then 
* Race2 will have the value of 0. The function will create a number of variables equal to the
* number of different race options that were available.

set printback=off.
begin program python.
import spss, spssaux, os

def descriptive(variable, stat):
# Valid values for stat are MEAN STDDEV MINIMUM MAXIMUM
# SEMEAN VARIANCE SKEWNESS SESKEW RANGE
# MODE KURTOSIS SEKURT MEDIAN SUM VALID MISSING
# VALID returns the number of cases with valid values, and MISSING returns
# the number of cases with missing values

     if (stat.upper() == "VALID"):
          cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /ORDER=ANALYSIS."
          freqError = 0
          handle,failcode=spssaux.CreateXMLOutput(
          	cmd,
          	omsid="Frequencies",
          	subtype="Statistics",
          	visible=False)
          result=spssaux.GetValuesFromXMLWorkspace(
          	handle,
          	tableSubtype="Statistics",
          	cellAttrib="text")
          if (len(result) > 0):
               return int(result[0])
          else:
               return(0)

     elif (stat.upper() == "MISSING"):
          cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /ORDER=ANALYSIS."
          handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Frequencies",
		subtype="Statistics",
		visible=False)
          result=spssaux.GetValuesFromXMLWorkspace(
		handle,
		tableSubtype="Statistics",
		cellAttrib="text")
          return int(result[1])
     else:
          cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /STATISTICS="+stat+"\n\
  /ORDER=ANALYSIS."
          handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Frequencies",
		subtype="Statistics",
     		visible=False)
          result=spssaux.GetValuesFromXMLWorkspace(
		handle,
		tableSubtype="Statistics",
		cellAttrib="text")
          if (float(result[0]) <> 0 and len(result) > 2):
               return float((result[2]))
               
def textCSVtoVars (inVar, outPrefix = "@", valueDummyCodes=False):
    ##########
    # Separate entries into variables
    ##########
    # Final step if valueDummyCodes=False, temporary step if = True
    if (valueDummyCodes==True):
        varStem = "@_J_"
    else:
        varStem = outPrefix

    #### Create variables        
    # Determine number of needed variables by counting commas
    # Determine string size by length between commas
    submitstring = """numeric @_JD_commas @_JD_maxlength (f8).
compute @_JD_commas = 0.
compute @_JD_maxlength = 0.
compute #strlength = 0.
loop #t=1 to char.length({0}).
+    do if (char.substr({0}, #t, 1) = ',').
+        compute @_JD_commas = @_JD_commas+1.
+        if (#strlength > @_JD_maxlength) @_JD_maxlength = #strlength.
+        compute #strlength = 0.
+    else.
+        compute #strlength = #strlength+1.
+    end if.
end loop.
execute.""".format(inVar)
    spss.Submit(submitstring)
    numVars = int(descriptive("@_JD_commas", "MAXIMUM") +1)
    stringLength = int(descriptive("@_JD_maxlength", "MAXIMUM"))
    submitstring = """string {0}1 to {0}{1} (a{2}).
vector splitVars = {0}1 to {0}{1}.""".format(varStem, numVars, stringLength)
    spss.Submit(submitstring)
    
    #### Put values into variables
    submitstring = """compute #count = 0.
compute #start = 1.
loop #t=1 to char.length({0}).
+    do if (char.substr({0}, #t, 1) = ',').
+        compute #count = #count+1.
+        compute splitVars(#count) = char.substr({0}, #start, #t-#start).
+        compute #start = #t+1.
+    end if.
end loop.
compute #count = #count+1.
compute splitVars(#count) = char.substr({0}, #start, char.length(rtrim({0}))).
execute.""".format(inVar)
    spss.Submit(submitstring)
    
#########
# Create value dummy codes
#########
    if (valueDummyCodes == True):
#### Obtain a list of all possible values
        fullValuesList = []
        for t in range(numVars):
            variable = "@_J_"+str(t+1)
# Use the OMS to pull the values from the frequencies command
        
            submitstring = """SET Tnumbers=values.
OMS SELECT TABLES
/IF COMMANDs=['Frequencies'] SUBTYPES=['Frequencies']
/DESTINATION FORMAT=OXML XMLWORKSPACE='freq_table'.
FREQUENCIES VARIABLES=%s.
OMSEND.

SET Tnumbers=Labels.""" %(variable)
            spss.Submit(submitstring)
 
            handle='freq_table'
            context="/outputTree"
#get rows that are totals by looking for varName attribute
#use the group element to skip split file category text attributes
            xpath="//group/category[@varName]/@text"
            values=spss.EvaluateXPath(handle,context,xpath)
            fullValuesList += values
        fullValuesList = list(set(fullValuesList))
        fullValuesList.remove(' ')
        fullValuesList.sort()
        
#### Create a variable for each value
        for item in fullValuesList:
            submitstring = """numeric {0}{1} (f8).
compute {0}{1} = 0.""".format(outPrefix, item)
            spss.Submit(submitstring)

#### Assign values to dummy codes.
        for item in fullValuesList:
            for t in range(numVars):
                invar = "@_J_"+str(t+1)
                outvar = outPrefix + item
                submitstring = "if ({0} = '{1}') {2} = 1.".format(invar, item, outvar)
                spss.Submit(submitstring)
        spss.Submit("execute.")

####
# Cleanup
####
    submitstring = "delete variables @_JD_commas @_JD_maxlength"
    for t in range(numVars):
        submitstring += "\n@_J_"+str(t+1)
    submitstring += "."
    spss.Submit(submitstring)
end program python.
set printback = on.

******
* Version History
******
* 2022-05-01 Created
* 2022-05-01a Added value dummy codes
* 2022-05-02 Set printback = on at end
