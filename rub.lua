-- https://en.wikipedia.org/wiki/Rubrication
-- Grab Command Line Arguements 

sectionNumberStarts = 1
sectionsStart=1
sPrefix = ""
bVerbose=nil

for index,argument in pairs(arg) do
  if argument=="-s" then
      sInputfile = arg[index+1] -- Input File
  elseif argument=="-p" then
      sPrefix = arg[index+1] -- counter prefix File
  elseif argument=="-v" then
    bVerbose=true
  elseif argument=="-sn" then
    sectionNumberStarts=arg[index+1]
  elseif argument=="-st" then
    sectionsStart=arg[index+1]
  end  
end

if sPrefix == "" then
  if bVerbose then 
    print("Prefix not specified.") 
  end 
else 
  sPrefix= sPrefix.."."
end

if bVerbose then print("Input file: "..sInputfile) end
if bVerbose then print("Counter Prefix: "..sPrefix) end

if sInputfile and io.open(sInputfile, "r") then 

for key, value in string.gmatch(arg[1], "(%w+)%.(%w+)") do
  sType         = value
  if bVerbose then print("File Type: "..sType) end
end

--[[
prt:	part
cha:	chapter
sec:	section
sse:	subsection
fig:	figure
tab:	table
equ:	equation
lst:	code listing
itm:	enumerated list item
alg:	algorithm
app:	appendix subsection

lab:  label
par:  paragraph
]]

fullName= {}
fullName["prt"]={["name"]="Part ", ["count"]=1}
fullName["cha"]={["name"]="Chapter ", ["count"]=1}
fullName["sec"]={["name"]="&#167;", ["count"]=1}
fullName["sse"]={["name"]="Sub-Section ", ["count"]=1}
fullName["par"]={["name"]="&para;", ["count"]=1}
fullName["itm"]={["name"]="List Item ", ["count"]=1}
fullName["app"]={["name"]="Appendix", ["count"]=1}

rubLables = {}

headingCounter={}
 headingCounter={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0}
currentHeading=0




-- PASS 1: Annotate document structures and create a list of labels and their document location. 

file = io.open(("rub1"..sInputfile), "w") -- List is build Now Open new file for writing to same output.

for sLine in io.lines(sInputfile) do 
  if string.find(sLine, "^#+") then -- it's a heading
    starts, stops = string.find(sLine, "^#+")
    heading = stops-starts+1
    if heading >= currentHeading then 
      headingCounter[heading]=headingCounter[heading]+1
    else
      headingCounter[heading]=headingCounter[heading]+1
      for i=currentHeading, 6, 1 do
        headingCounter[i]=0
      end
    end
    currentHeading=heading
  
    reptext=""
  
    if heading == sectionsStart then -- it's a section
      sLine = string.gsub(sLine, "%s+", " "..headingCounter[heading]..". ", 1)
    elseif heading > sectionsStart then -- it's a sub-section
      for i=sectionsStart, 6, 1 do
        if headingCounter[i] == 0 then break
        reptext=reptext..headingCounter[i].."."
        end
      end
      sLine = string.gsub(sLine, "%s+", " "..reptext.." ",1)
    elseif heading == (sectionsStart - 1) then -- it's a chapter
        sLine = string.gsub(sLine, "%s+", fullName["cha"].name..headingCounter[heading]..": ",1)
    else -- it's a Part
        sLine = string.gsub(sLine, "%s+", fullName["prt"].name..headingCounter[heading]..": ",1)
    end
       --[[ 
        
        
        
        
        
        if sectionNumberStarts >= heading then
        if heading > currentHeading then -- we are moving down into a subsection
          sLine=
        
        
        elseif heading < currentHeading then -- we are moving up into a subsection or the top level section 
    
      end
    
      -- we know it's a top level section if the heading equals sectionsStart
    
    
      currentHeading = heading
    
    
    
      
      
      
    
    
    
        
    
    end]]
  elseif string.find(sLine, "^%a") then -- it's a standard paragraph
      if sPrefix == "" then
        sLine="<sup>"..fullName["par"].name..fullName["par"].count..".</sup> "..sLine.."<sup>("..fullName["par"].name..fullName["par"].count..")</sup> "-- annotate it
      else
        sLine="<sup>"..fullName["par"].name..sPrefix.."."..fullName["par"].count.."</sup>"..sLine -- annotate it
      end
      
      -- Find Labels in this Paragraph
      
      for findID in string.gmatch(sLine, "%]%(lab:[%w%_*%-*]+%)") do -- find all labels in a paragraph
        findID = findID:sub(7, -2) -- Grab only The label ID
        findID = string.gsub(findID, "-", "_") -- Get rid of '-' as this is a special pattern character
        rubLables[findID]={["par"] = fullName["par"].count, ["prt"] = 0, ["cha"] = 0, ["sec"] = 1, ["sse"] = 0, ["itm"] = 0, ["app"] = 0}
      end
      
    fullName["par"].count=fullName["par"].count+1 -- inc the counter
  end
  
  file:write(sLine, "\n")
end

file:close()  -- Close it

-- PASS 2: Recognise references to labels and update text with their locations.
--[[
passtwo = io.open(("rub2"..sInputfile), "w") -- List is build Now Open new file for writing to same output.

for sLine in io.lines("rub1"..sInputfile) do 
  -- Find label-refs in this line
  for findID in string.gmatch(sLine, "%]%(#[%w%_*%-*:*]+%)") do -- find all label-refs in a line
    findID = string.gsub(findID, "-", "_") -- Get rid of '-' as this is a special pattern character
    changeID=findID:sub(4, -2)
    if string.find(changeID, ":") then
        key, value = string.match(changeID, "(%w*):([%w%_*%-*:*]+)") -- split findID based on :
    else
        value=changeID
        key="par"
    end
    if (value~=nil) and (key~=nil) and (fullName[key]~=nil) and (rubLables[value]~=nil) then
       repString=fullName[key]..rubLables[value][key]
       sLine = string.gsub(sLine, "%]%(#"..changeID.."%)", " "..repString.."](#lab:"..value..")")
    end
  end
  passtwo:write(sLine, "\n")
end
passtwo:close()  -- Close it
]]
end