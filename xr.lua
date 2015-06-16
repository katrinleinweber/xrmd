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

]]




xrFigInlineKey = "%!%[%a%a%a%:[%w%_*%-*]+.+%]%((.-)([^\\/]-%.?([^%.\\/]*))[%s+\"*\'*.\"*\'*]*%)" 
xrFigRefStyleKey = "%!%[.+%]%[%a%a%a%:[%w%_*%-*]+%]"
xrFigRefndpointKey = "%[%a%a%a%:[%w%_*%-*]+%]%:%s+(.-)([^\\/]-%.?([^%.\\/]*))%s+[\"*\'*.\"*\'*]*%s*[width=[\"*\'*.\"*\'*]]?"

xrLazyTargetKey = "%[%a%a%a%:[%w%_*%-*]+%]"
xrTargetKeys = {}
figcount=0
tabcount=0




sSearchKey



if sType == "md" then
  sSearchKey = xrmdrefendpointKey -- xrmdTargetKey
  sRepKey = xrmdRefKey
elseif sType == "html" then
  sSearchKey = xrhtmlTargetKey
  sRepKey = xrhtmlRefKey
else
  sSearchKey = xrmdTargetKey
  sRepKey = xrtxtRefKey
end

for sLine in io.lines(sInputfile) do 
  for sTemp in string.gmatch(sLine, sSearchKey) do
    s = sTemp:sub(2, -2)
    if xrTargetKeys[s] == nil then -- Don't Store Duplicates  
      if s:sub(1,3) == "fig" then
        figcount=figcount+1
        current=figcount
      elseif s:sub(1,3) == "tab" then
        tabcount=tabcount+1
        current=tabcount
      end
      xrTargetKeys[s] = current
    end  
  end
end

file = io.open(("xr"..sInputfile), "w")

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


  --[[ Write the line out here]]
end
file:close()

--[[







]]





