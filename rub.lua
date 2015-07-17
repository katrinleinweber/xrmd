-- https://en.wikipedia.org/wiki/Rubrication
-- Grab Command Line Arguements 

for index,argument in pairs(arg) do
  if argument=="-s" then
      sInputfile = arg[index+1] -- Input File
  elseif argument=="-p" then
      sPrefix = arg[index+1] -- counter prefix File
  elseif argument=="-v" then
    bVerbose=true
  end  
end

if sPrefix == nil then sPrefix = ""; if bVerbose then print("Prefix not specified.") end else sPrefix= sPrefix.."." end
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
fullName["prt"]="Part "
fullName["cha"]="Chapter "
fullName["sec"]="&#167;"
fullName["sse"]="Sub-Section "
fullName["itm"]="List Item "
fullName["app"]="Appendix "
fullName["par"]="&para;"

paraCount = 1;

rubLables = {}


-- PASS 1: Annotate document structures and create a list of labels and their document location. 

file = io.open(("rub1"..sInputfile), "w") -- List is build Now Open new file for writing to same output.

for sLine in io.lines(sInputfile) do 
  if string.find(sLine, "^%a") then -- it's a standard paragraph
      if sPrefix == "" then
        sLine="<sup>&para;"..paraCount..".</sup> "..sLine.."<sup>(&para;"..paraCount..")</sup> "-- annotate it
      else
        sLine="<sup>&para;"..sPrefix.."."..paraCount.."</sup>"..sLine -- annotate it
      end
      
      -- Find Labels in this Paragraph
      
      for findID in string.gmatch(sLine, "%]%(lab:[%w%_*%-*]+%)") do -- find all labels in a paragraph
        findID = findID:sub(7, -2) -- Grab only The label ID
        findID = string.gsub(findID, "-", "_") -- Get rid of '-' as this is a special pattern character
        rubLables[findID]={["par"] = paraCount, ["prt"] = 0, ["cha"] = 0, ["sec"] = 1, ["sse"] = 0, ["itm"] = 0, ["app"] = 0}
      end
      
    paraCount=paraCount+1 -- inc the counter
  end
  
  file:write(sLine, "\n")
end

file:close()  -- Close it

-- PASS 2: Recognise references to labels and update text with their locations.

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
end