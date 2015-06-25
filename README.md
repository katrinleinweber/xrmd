# Cross Reference MarkdownThis very small piece of code is my first attempt at coding in Lua. I used it to both learn the Lua language and to solve problems with a Paper I was writing. There are no test cases, it isn't complete yet, there are no comments, and it's my first attempt at Lua. The code went from 0 lines to 400 lines back to 100 lines so as you can see there was lots of refactoring. All this suggests '**buyer-beware**' (yes, I'm a terrible person). This said everything is saved to a separate file prefixed with 'xr' so it **should not** affect your original.If you like it or use it please make it better, or integrate it into your own tool.## UsageSimply the code looks for LaTeX like instances of cross-references. So is based on the predicate that the fig:xyz [method from LaTeX is used](https://en.wikibooks.org/wiki/LaTeX/Labels_and_Cross-referencing#Introduction)- cha:	chapter [**changed from LaTeX**]- sec:	section- ssc:	subsection [**changed from LaTeX**]- fig:	figure- tab:	table- equ:	equation [**changed from LaTeX**]- lst:	code listing- itm:	enumerated list item- alg:	algorithm- app:	appendix subsectionWhen it finds something like **fig:id** then it swaps it out something like **Figure 1**. However, it does it in a slightly more complex way to maintain readability and standard academic practice as follows:If you don't use one of these (say **peo:xyz**) then it swaps it out something like **General 1**.### Images```md!![fig:test: -- Some Text -- Other Text.](Figures/figure.jpg "Test")	changes to => ![Figure 1: Some Text -- Other Text.](Figures/figure.jpg "Figure 1: Test")[fig:test]: Figures/figure.jpg "Test"	changes to => [Figure 1]: Figures/figure.jpg "Figure 1: Test"	![Some Text -- Some Longer Text.][fig:xyz]	changes to => ![Figure 2: Some Text -- Some Longer Text.][Figure 2]```### MMD Table```md[Some text][tab:test]	changes to => ![Table 1: Some Text.][Table 1]```### Links```md(see [fig:test])	changes to => (see Figure 1)A [reference link][fig:test]	changes to => A [reference link][Figure 1][fig:test]: http://somesite.com "Test"	changes to => [Figure 1]: http://somesite.com "Figure 1: Test"[fig:test]: <http://somesite.com> (Test)	changes to => [Figure 1]: <http://somesite.com> (Figure 1: Test)		```## Command Line ArgumentsSpecify the source file.```bashlua xrmd.lua -s myfile.md```An additional optional prefix '-p' argument so that Figure 1 becomes Figure 1.1.```bashlua xrmd.lua -s myfile.md -p 1```Figure 1 becomes Figure Preamble.1.```bashlua xrmd.lua -s myfile.md -p Preamble```An additional optional verbose '-v' argument so that the log is printed.```bashlua xrmd.lua -s myfile.md -p 1 -v```## WarningCurrently, **I've only implemented ```fig``` and ```tab```**.