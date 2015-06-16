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
xrTypes["fig"]={ ["Name"]      = "Figure", 
                    ["Counter"]   = 1, 
                    ["Inline"]    = "%!%[%a%a%a%:[%w%_*%-*]+.+%]%((.-)([^\\/]-%.?([^%.\\/]*))[%s+\"*\'*.\"*\'*]*%)", 
                    ["RefInline"] = "%!%[.+%]%[%a%a%a%:[%w%_*%-*]+%]", 
                    ["RefEnd"]    = "%[%a%a%a%:[%w%_*%-*]+%]%:%s+(.-)([^\\/]-%.?([^%.\\/]*))%s+[\"*\'*.\"*\'*]*%s*[width=[\"*\'*.\"*\'*]]?",
                    ["Target"]    = "%[fig:[%w%_*%-*]+%]" 
                  }
                  
--xrTypes["tab"]={["Name"]="Table",  ["Counter"]=1}

-- Build List of all Figures Increamenting as you go.
for xrType in pairs(xrTypes) do
  for sLine in io.lines(sInputfile) do 
    for TempID in string.gmatch(sLine, xrTypes.fig.Target) do
      ID = TempID:sub(2, -2)
      if xrTargetKeys[ID] == nil then -- Don't Store Duplicates  
        xrTargetKeys[ID] = xrTypes.fig.Counter
        xrTypes.fig.Counter = xrTypes.fig.Counter+1
      end  
    end
  end
end


file = io.open(("xr"..sInputfile), "w") -- List is build Now Open new file for writing to same output.

--[[
for sLine in io.lines(sInputfile) do 
  for sTemp in string.gmatch(sLine, xrmdRefKey) do
    s = sTemp:sub(2, -3)
    if xrTargetKeys[s] then -- Got to Be Listed  
      if s:sub(1,3) == "fig" then
        substituteString="Figure "..xrTargetKeys[s]
      elseif s:sub(1,3) == "tab" then
        substituteString="Table "..xrTargetKeys[s]
      end
      sLine = string.gsub(sLine, "%["..s.."%]", substituteString)
    end  
  end
  file:write(sLine, "\n")
end
]]

file:close()  -- Close it

