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
                  
xrTypes["tab"]={ ["Name"]      = "Table", 
                    ["Counter"]   = 1, 
                    ["Inline"]    = "%!%[fig:%g+%s.+%]%(.+%)", 
                    ["RefInline"] = "%!%[.+%]%[fig:[%w%_*%-*]+%]", 
                    ["RefEnd"]    = "%[fig:[%w%_*%-*]+%]%:%s+(.-)([^\\/]-%.?([^%.\\/]*))%s+[\"*\'*.\"*\'*]*%s*[width=[\"*\'*.\"*\'*]]?",
                    ["Target"]    = "%[tab:[%w%_*%-*]+%]" 
                  }                                  
              
                  
--xrTypes["tab"]={["Name"]="Table",  ["Counter"]=1}

-- Build List of all Figures Increamenting as you go.
for xrType in pairs(xrTypes) do
  for sLine in io.lines(sInputfile) do 
    for tempID in string.gmatch(sLine, xrTypes.fig.Target) do
      findID = tempID:sub(2, -2)
      if xrTargetKeys[findID] == nil then -- Don't Store Duplicates  
        xrTargetKeys[findID] = xrTypes.fig.Counter
        xrTypes.fig.Counter = xrTypes.fig.Counter+1
      end  
    end
  end
end


file = io.open(("xr"..sInputfile), "w") -- List is build Now Open new file for writing to same output.



for sLine in io.lines(sInputfile) do 
  if(string.match(sLine, "fig:[%w%_*%-*]+")) then 
    substituteString=xrTypes.fig.Name.." "..xrTargetKeys[string.match(sLine, "fig:[%w%_*%-*]+")]
    if(string.match(sLine, "^%!%[[^fig:]")) then sLine = string.gsub(sLine, "^%!%[", "!["..substituteString..": ", 1) end
    sLine = string.gsub(sLine, "fig:[%w%_*%-*]+", substituteString)
    sLine = string.gsub(sLine, "\"", "\""..substituteString..": ", 1)
  end
  
  
  --[[if(string.match(sLine, xrTypes.fig.Inline)) then -- Let's do the inline figures
    replaceID=sLine:sub(string.find(sLine, xrTypes.fig.Inline))
    substituteString = xrTypes.fig.Name.." "..xrTargetKeys[replaceID:sub(3,-3)]
    sLine = string.gsub(sLine, xrTypes.fig.Inline, "!["..substituteString..": ")
    sLine = string.gsub(sLine, "\"", "\""..substituteString..": ", 1) 
  elseif(string.match(sLine, xrTypes.fig.Inline)) then
  
  
  end
  ]]
  file:write(sLine, "\n")
end

file:close()  -- Close it

--[[for sTemp in string.gmatch(sLine, xrTypes.fig.Inline) do
    s = sTemp:sub(2, 5)
    if xrTargetKeys[s] then -- Got to Be Listed  
      if s:sub(1,3) == "fig" then
        substituteString="Figure "..xrTargetKeys[s]
      elseif s:sub(1,3) == "tab" then
        substituteString="Table "..xrTargetKeys[s]
      end
      sLine = string.gsub(sLine, "%["..s.."%]", substituteString)
    end  
  end]]