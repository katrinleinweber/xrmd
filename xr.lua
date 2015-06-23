--[[ Grab Command Line Arguements ]]

for index,argument in pairs(arg) do
  if argument=="-o" then
      sInputfile = arg[index+1] -- Input File
  elseif argument=="-p" then
      sPrefix = arg[index+1] -- counter prefix File
  elseif argument=="-v" then
    bVerbose=true
  end  
end

if bVerbose then print("Input file: "..sInputfile) end
if bVerbose then print("Counter Prefix: "..sPrefix) end
if sPrefix == nil then sPrefix = ""; if bVerbose then print("Prefix not specified.") end else sPrefix= sPrefix.."." end

if sInputfile and io.open(sInputfile, "r") then 

for key, value in string.gmatch(arg[1], "(%w+)%.(%w+)") do
  sType         = value
  if bVerbose then print("File Type: "..sType) end
end

--[[

Based on the predicate that the fig:xyz method from LaTeX

ch:	chapter
sec:	section
subsec:	subsection
fig:	figure
tab:	table
eq:	equation
lst:	code listing
itm:	enumerated list item
alg:	algorithm
app:	appendix subsection

]]

xrTargetKeys = {}
xrTypes = {}

xrTypes["fig"]={["Name"] = "Figure", ["Counter"] = 1}                    
xrTypes["gen"]={["Name"] = "General", ["Counter"] = 1}
xrTypes["tab"]={["Name"] = "Table", ["Counter"] = 1}
                
                  
--xrTypes["tab"]={["Name"]="Table",  ["Counter"]=1}

-- Build List of all Figures Increamenting as you go.
for xrType in pairs(xrTypes) do
  for sLine in io.lines(sInputfile) do 
    for findID in string.gmatch(sLine, "%[%a%a%a:[%w%_*%-*]+%]") do
      findID = findID:sub(2, -2)
      if xrTypes[findID:sub(1,3)] == nil then
        if xrTargetKeys[findID] == nil then -- Don't Store Duplicates
          xrTargetKeys[findID] = {["Index"] = xrTypes['gen'].Counter, ["Name"] = xrTypes['gen'].Name}
          xrTypes['gen'].Counter = xrTypes['gen'].Counter+1
         print("Found Cross-Reference: "..findID)
        end
      elseif xrTargetKeys[findID] == nil then -- Don't Store Duplicates
         xrTargetKeys[findID] = {["Index"] = xrTypes[findID:sub(1,3)].Counter, ["Name"] = xrTypes[findID:sub(1,3)].Name}
         xrTypes[findID:sub(1,3)].Counter = xrTypes[findID:sub(1,3)].Counter+1
         print("Found Cross-Reference: "..findID)
      end
    end
  end
end


file = io.open(("xr"..sInputfile), "w") -- List is build Now Open new file for writing to same output.
if bVerbose then print("\nOpening xr"..sInputfile.." for changes") end


for sLine in io.lines(sInputfile) do 
  sHold=sLine
  for xrTargetKey in pairs(xrTargetKeys) do
    if(string.match(sLine,"%!%[.+%]%["..xrTargetKey.."%]")) then -- It's a reference style image in MMD and MD
      sLine = string.gsub(sLine, "%!%[", "!["..xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index..": ", 1)
      sLine = string.gsub(sLine, "%]%["..xrTargetKey, "]["..xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index)
    elseif(string.match(sLine,"%!%["..xrTargetKey..".*%]%(")) then -- It's an inline style image in MMD and MD
      sLine = string.gsub(sLine, "%!%["..xrTargetKey.."[%p*%s*%c*]+", "!["..xrTargetKey.." ", 1)   
      sLine = string.gsub(sLine, "%!%["..xrTargetKey, "!["..xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index..":", 1)
      sLine = string.gsub(sLine, "\"", "\""..xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index..": ", 1)   
    elseif(string.match(sLine,"%["..xrTargetKey..".*%]%(")) then -- It's an inline link in MD
      sLine = string.gsub(sLine, "%["..xrTargetKey.."[%p*%s*%c*]+", ":")   
      sLine = string.gsub(sLine, "%["..xrTargetKey, "["..xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index..": ")
    elseif(string.match(sLine,"%["..xrTargetKey.."%]:%s+")) then -- It's a Reference End Point style in MMD and MD
      sLine = string.gsub(sLine, "%["..xrTargetKey.."%]:", "["..xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index.."]:", 1)
      sLine = string.gsub(sLine, "\"", "\""..xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index..": ", 1)      
      sLine = string.gsub(sLine, "%(", "("..xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index..": ", 1)      
    elseif(string.match(sLine,"%[.+%]%["..xrTargetKey.."%]")) then -- It's a reference style link in MMD and MD
      sLine = string.gsub(sLine, "^%[", "["..xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index..": ") -- MMD Table Caption
      sLine = string.gsub(sLine, "[^%]]%[", " ["..xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index..": ") -- General reference style link
      sLine = string.gsub(sLine, "%]%["..xrTargetKey.."%]", "]["..xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index.."]")
    else  
      sLine = string.gsub(sLine, "%["..xrTargetKey.."%]", xrTargetKeys[xrTargetKey].Name.." "..sPrefix..xrTargetKeys[xrTargetKey].Index) -- Caption
    end
  end
  if (sHold ~= sLine) and (bVerbose) then print("Change Made: "..sHold.."\n\tchanged to => "..sLine) end
  file:write(sLine, "\n")
end

file:close()  -- Close it
  print("Cross-Referencing to \'xr"..sInputfile.."\' DONE")

else
  print("Input file not specified or not present.")
end
