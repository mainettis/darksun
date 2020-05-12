# Using VS Code as a Neverwinter Nights Development Environment

I've used several development environments over the years and have found Visual Studio Code (VS Code) to be one of the best when it comes to integration, expansion and agility.  You are certainly not required to use VS Code in your development environment, but I've found it makes the [workflow](workflow.md) go much more quickly.  Some of the benefits I've found:

* There is an integrated command line utility, so you can use the command line from within VS Code and see the results of some commands directly in the working tree.
* VS Code integrates with source control providers, such as Git, so you can see which files in your repository have been changed, or are untracked, saved, unsaved, staged or committed.  You can also stage, commit and push individual files (or all your files) directly from within VS Code.  You can also directly see compared documents (red and gree highlighting) when staging/committing changes, mergine pulled files, etc.
* You can setup custom tasks to allow you to compile scripts from within VS Code instead of using the toolset.
* An NWN script coloring extension is available for NWScript in the marketplace.
* You can view documents/scripts side-by-side to make working with multiple documents easier.

## Disclaimer

There are **A LOT** of words here.  Don't let this scare you off of the idea of using VS Code.  I've chosen to add a lot of detail based on the assumption you've not worked with VS Code before.  If you have, you can ignore much of this.  There is some advanced usage here, but if you can work through the tutorial and get your questions answered on our discord channel, you should have a great addition to your development environment.  Also, I primarily use Windows, so there may be some difference with Mac OS or Linux.  If you run into an OS-related issue, please post on our discord or send me a DM (@tinygiant) and we'll try to get your an answer.

* [Installing VS Code](#installing-vs-code)
* [Installing the NWScript Extenstion](#installing-the-nwscript-extension)
* [Setting up a Workspace](#setting-up-your-workspace)
* [Customizing Workspace Settings](#customize-your-workplace-settings)
* [Creating Custom Tasks](#creating-custom-tasks)
* [Using Source Control](#using-source-control)

## Installing VS Code

Navigate to the [VS Code downloads page](https://code.visualstudio.com/download) and download the file appropriate for your operating system.  Open the file and install VS Code to your preferred location following all prompts in the process.  When you're all done, open VS Code.

## Installing the NWScript Extension

On the left side of the window, on the Activity Bar (several icons stacked vertically), you should see the markeplace icon.

![extensions icon](images/vscodeextensions.jpg)

Click it to open the VS Code extension manager.  at the top of the extention manager, there is a search bar.  In this bar, type in `nwscript` and press enter (or just wait, it's a live search).  Once you see the extension `nwscript 0.0.2`, click on the install button in the lower right corner of the extension.

That's it.  This extension will allow you to have your scripts color-coded if you've designated that file as a Neverwinter Script file.  You can change how the file is presented on-screen by selecting the language mode.  In the lower right corner of the window, you'll see some information in a status bar format.  It includes such information as line count, column count, tab indentation, etc.  For a new file, the default language mode is `Plain Text`.  You can click on it to change it to `Neverwinter Script`.  If you're working on a different file, you can change it to `Markdown`, `C` or whatever other language you're working in.  If you're looking at one of the converted .json files, it should say `JSON`.

## Setting up Your Workspace

The following steps assume you've setup your local repository as recommended in the [tool installation tutorial](tools.md/#git).  If not, you will have to modify where your workspace is pointing to ensure you can see all of your repository files.

1. Click on the `File` tab and select `Add Folder to Workspace...`.  Navigate to your darksun repository folder and select it.  Once you do that, open the explorer tab if it's not already open.  The explorer tab icon looks like this:

    ![explorer icon](images/vscodeexplorer.jpg)

    The number on the blue circular background means that I currently have one open modified file.  Once you have the explorer tab open, you should see your repository in the treeview on the left side of the window.

    VS Code should automatically recognize that your repository is, in fact, a repository and set it up for source control functions.  It cannot do this unless you have already [installed Git](tools.md/#git).  Initially, all of your files will be in a white font.  As you work, this will change.  New files that you have created, but aren't tracking yet, will appear in green font with a green `U` next to them.  Modified files will appear in orange font with an orange `M` next to them.  When you start tracking new files (using the `git add .` command), those files will appear in green font with a green `A` next to them.  This way, you always know the status of your files.  Once you stage, commit and push your files, all files will appear in white font again.  If you see a green or orange dot next to a folder name, that indicates the folder has a color-coded file in it somewhere.  Here is an example of untracked and modified file designations.

    ![working tree example](images/treegitexample.jpg)

2. Set up a task to compile your scripts within VS Code.  VS Code can be automated to compile your code and check for errors. NWNSC.exe, the script compiler that is included in the base repository, can also be used by VS Code to compile NWN scripts and provide more detailed output than the toolset compiler.  The feedback and error description aren't always intuitive, but are generally much better than the error description provided by the toolset compiler.

    * 

3. Create a shortcut to run the compilation task you just created.

4. Use the terminal (command line utility) to run git and nasher commands from within VS Code.  You can open the embedded terminal by navigating to View -> Terminal.  A terminal window will open at the bottom of the VS Code window.  Ensure you've navigated to the appropriate directory and you can run all of the command line commands referenced in any of the tutorials from there.  Additionally, the feedback will be formatted and color-coded in a much more user-friendly way compared to Git Bash, Powershell or other command line utilites I've seen.  Your mileage may vary.

![terminal example](images/terminalexample.jpg)











