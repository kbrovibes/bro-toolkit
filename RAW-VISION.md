# High levle idea of the project
Initialize this folder as a CLAUDE project which I will use to have a github repository of all my main reusable tools, RC files, CLAUDE skills etc etc. My intent is that anytime I am on a new computer, I should be just able to use this repo, and follow a single onclick installer and it
  does everything for me in terms of setting it up with all the tools unique to me.


# Things I need 
1. one click install, status, release date, vesion, release notes etc -- should be easy to fetch all of these and more in the future 
2. A binary / alias (multipke ones eventually) that can be used to do a lot of the convience scripts and tools that I later add. for eg: kbro --help -> could list all of the tools available. Then I could do kbro <tool> -- which essentailly is the same as directly invoking a specific tool (that now lives in a folder that is added to PATH) 
3. A good directory structure for RC file (ZSH, TMUX etc) , and also CLAUDE
4. Claude and TMUX are the main first use cases that I want to sort out 


# Important instruction till I mark the project as STABLE 
1. I should be able to run/test many times - which means I might need idempotency / cleanup ways -- incase we want to wipe and restart -- this is very important , because I dont want anything to be added to myzshrc that cant be easily undone 
2. For #1, one thing that is worth doing is having a minimal change in .zshrc which can be cleared easily and eveything goes away. 

# V1 
1. for now, lets get directory sturctures and scafooling etc ready, but the main focus is only on claude skills and plugins for now. Also CLAUDE PROMPTS - for eg: I have keyboard bindings for navigating between panes in tmux . Instead of backing up my tmuxrc into this project - for now we could start with saving a CLAUDE prompt that explains what I need , and later I could just refer to that one and ask claude to do it on my new computer. Not sure about this -- think and see if its better to just have custom TMUX RC files in this case and not rely on prompts (because the prompts dont guarantee the same output later on, but having RC files is deterministic. Actually the more I think about this, I think this usecase should be TMUXRC) 

# Research to do 

This step is very important - read through all our claude interactions and also my current workflows and compile a list of candidates that can go into this toolkit . Some of the ones I can think of are:

1. /pull claude skill for git pull and rebase 
2. Saving my preference that visualize should always return light mode themed output, in mordern and sleek styling 
3. tmux navigate between panes using alt + arrow
4. look at this tmux conf for brightness setting (active window is bright, other panes fade a little) . 
5. color code of tmux (border thickness, color , heading for window/pane etc) 
6 installing

# Things I need 
1. one click install, status, release date, vesion, release notes etc -- should be easy to fetch all of these and more in the future 
2. A binary / alias (multipke ones eventually) that can be used to do a lot of the convience scripts and tools that I later add. for eg: kbro --help -> could list all of the tools available. Then I could do kbro <tool> -- which essentailly is the same as directly invoking a specific tool (that now lives in a folder that is added to PATH) 
3. A good directory structure for RC file (ZSH, TMUX etc) , and also CLAUDE
4. Claude and TMUX are the main first use cases that I want to sort out 


# Important instruction till I mark the project as STABLE 
1. I should be able to run/test many times - which means I might need idempotency / cleanup ways -- incase we want to wipe and restart -- this is very important , because I dont want anything to be added to myzshrc that cant be easily undone 
2. For #1, one thing that is worth doing is having a minimal change in .zshrc which can be cleared easily and eveything goes away. 

# V1 
1. for now, lets get directory sturctures and scafooling etc ready, but the main focus is only on claude skills and plugins for now. Also CLAUDE PROMPTS - for eg: I have keyboard bindings for navigating between panes in tmux . Instead of backing up my tmuxrc into this project - for now we could start with saving a CLAUDE prompt that explains what I need , and later I could just refer to that one and ask claude to do it on my new computer. Not sure about this -- think and see if its better to just have custom TMUX RC files in this case and not rely on prompts (because the prompts dont guarantee the same output later on, but having RC files is deterministic. Actually the more I think about this, I think this usecase should be TMUXRC) 

# Research to do 

This step is very important - read through all our claude interactions and also my current workflows and compile a list of candidates that can go into this toolkit . Some of the ones I can think of are:

1. /pull claude skill for git pull and rebase 
2. Saving my preference that visualize should always return light mode themed output, in mordern and sleek styling 
3. tmux navigate between panes using alt + arrow
4. look at this tmux conf for brightness setting (active window is bright, other panes fade a little) . 
5. color code of tmux (border thickness, color , heading for window/pane etc) 
6

# Things I need 
1. one click install, status, release date, vesion, release notes etc -- should be easy to fetch all of these and more in the future 
2. A binary / alias (multipke ones eventually) that can be used to do a lot of the convience scripts and tools that I later add. for eg: kbro --help -> could list all of the tools available. Then I could do kbro <tool> -- which essentailly is the same as directly invoking a specific tool (that now lives in a folder that is added to PATH) 
3. A good directory structure for RC file (ZSH, TMUX etc) , and also CLAUDE
4. Claude and TMUX are the main first use cases that I want to sort out 


# Important instruction till I mark the project as STABLE 
1. I should be able to run/test many times - which means I might need idempotency / cleanup ways -- incase we want to wipe and restart -- this is very important , because I dont want anything to be added to myzshrc that cant be easily undone 
2. For #1, one thing that is worth doing is having a minimal change in .zshrc which can be cleared easily and eveything goes away. 

# V1 
1. for now, lets get directory sturctures and scafooling etc ready, but the main focus is only on claude skills and plugins for now. Also CLAUDE PROMPTS - for eg: I have keyboard bindings for navigating between panes in tmux . Instead of backing up my tmuxrc into this project - for now we could start with saving a CLAUDE prompt that explains what I need , and later I could just refer to that one and ask claude to do it on my new computer. Not sure about this -- think and see if its better to just have custom TMUX RC files in this case and not rely on prompts (because the prompts dont guarantee the same output later on, but having RC files is deterministic. Actually the more I think about this, I think this usecase should be TMUXRC) 

# Research to do 

This step is very important - read through all our claude interactions and also my current workflows and compile a list of candidates that can go into this toolkit . Some of the ones I can think of are:

1. /pull claude skill for git pull and rebase 
2. Saving my preference that visualize should always return light mode themed output, in mordern and sleek styling 
3. tmux navigate between panes using alt + arrow
4. look at this tmux conf for brightness setting (active window is bright, other panes fade a little) . 
5. color code of tmux (border thickness, color , heading for window/pane etc) 
6. installing claude HUD 
7. any thing else you can think of form history 

# other things needed for this project in github
1. README in detailed format with installation and usage instructions needed
2. BACKLOG and release notes should be there
3. project local claude skills to ensure that all commits add readme, etc.  
