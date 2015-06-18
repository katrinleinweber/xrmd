--[[ Grab Command Line Arguements ]]

sInputfile    = arg[1] -- Input File

for key, value in string.gmatch(arg[1], "(%w+)%.(%w+)") do
  sType         = value
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

and that cross-references in the text look like [fig:summat] while targets look like this:

Figures:
![fig:summat mytext](path-to-file finished with a parenthesis
![fig:summat mytext](path-to-file "Optional Title" finished with a parenthesis
![fig:summat mytext][fig:summat]
![fig:summat]: path-to-file
![fig:summat]: path-to-file "Optional Title"

First build the list of targets matching everything that looks like 






xrFigInlineKey 
xrFigRefStyleKey = 
xrFigRefndpointKey = 

xrLazyTargetKey =
]]
xrTargetKeys = {}

xrTypes = {}

--[[

xrTypes["fig"]={ ["Name"]      = "Figure", 
                    ["Counter"]   = 1, 
                    ["Inline"]    = "%!%[fig:[%w%_*%-*]+.+%]%((.-)([^\\/]-%.?([^%.\\/]*))[%s+\"*\'*.\"*\'*]*%)", 
                    ["RefInline"] = "%!%[.+%]%[fig:[%w%_*%-*]+%]", 
                    ["RefEnd"]    = "%[fig:[%w%_*%-*]+%]%:%s+(.-)([^\\/]-%.?([^%.\\/]*))%s+[\"*\'*.\"*\'*]*%s*[width=[\"*\'*.\"*\'*\]\]?",
                    ["Target"]    = "%[fig:[%w%_*%-*]+%]" 
                  }
                ]]
                
xrTypes["fig"]={ ["Name"]      = "Figure", 
                    ["Counter"]   = 1, 
                    ["Inline"]    = "%!%[fig:%g+%s.+%]%(.+%)", 
                    ["RefInline"] = "%!%[.+%]%[fig:[%w%_*%-*]+%]", 
                    ["RefEnd"]    = "%[fig:[%w%_*%-*]+%]%:%s+(.-)([^\\/]-%.?([^%.\\/]*))%s+[\"*\'*.\"*\'*]*%s*[width=[\"*\'*.\"*\'*]]?",
                    ["Target"]    = "%[fig:[%w%_*%-*]+%]" 
                  }  
                  
xrTypes["gen"]={ ["Name"]      = "General", 
                    ["Counter"]   = 1, 
                    ["Inline"]    = "%!%[fig:%g+%s.+%]%(.+%)", 
                    ["RefInline"] = "%!%[.+%]%[fig:[%w%_*%-*]+%]", 
                    ["RefEnd"]    = "%[fig:[%w%_*%-*]+%]%:%s+(.-)([^\\/]-%.?([^%.\\/]*))%s+[\"*\'*.\"*\'*]*%s*[width=[\"*\'*.\"*\'*]]?",
                    ["Target"]    = "%[gen:[%w%_*%-*]+%]" 
                  }                                  
              
                  
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
        end
      elseif xrTargetKeys[findID] == nil then -- Don't Store Duplicates
         xrTargetKeys[findID] = {["Index"] = xrTypes[findID:sub(1,3)].Counter, ["Name"] = xrTypes[findID:sub(1,3)].Name}
         xrTypes[findID:sub(1,3)].Counter = xrTypes[findID:sub(1,3)].Counter+1
      end
    end
  end
end


file = io.open(("xr"..sInputfile), "w") -- List is build Now Open new file for writing to same output.



for sLine in io.lines(sInputfile) do 
for xrTargetKey in pairs(xrTargetKeys) do
 if(string.match(sLine, xrTargetKey)) then
    
    -- substituteString=xrTypes[xrType].Name.." "..xrTargetKeys[string.match(sLine, xrType..":[%w%_*%-*]+")]
    
    --todo
    
    if(string.match(sLine, "^%!%[[^"..xrType..":]")) then sLine = string.gsub(sLine, "^%!%[", "!["..substituteString..": ", 1) end
    sLine = string.gsub(sLine, xrType..":[%w%_*%-*]+", substituteString)
    
    
    --done
    
    sLine = string.gsub(sLine, "\"", "\""..xrTargetKeys[xrTargetKey].Name.." "..xrTargetKeys[xrTargetKey].Index..": ", 1)
  end
  
 end 
  

  file:write(sLine, "\n")
end

file:close()  -- Close it

