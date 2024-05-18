# MetaDefend-FIM
Description: 
MetaDefend-FIM  is a robust file integrity monitoring tool developed with PowerShell, using advanced metadata analysis and cryptographic hashing to ensure file integrity and detect unauthorized changes in real-time. By embedding watermarks and performing comprehensive metadata checks, it enhances security and authenticity for critical files.


The user will be provided with two options A and B
A. Collect new Baseline
B. Begin monitoring files with the saved Baseline
Select option A (by entering ‘A’ and click enter) to create new baseline files. The system will first delete the existing baseline files and creates new baseline files to stay updated with authorized changes.
Also, after selecting the option A, give the path details as input to the system. Provide folder path that contains all the files that are to be monitored and path where you want to save the baseline files after creation.

After creating the baseline files, run the PowerShell code again and now select for option B (by entering ‘B’ and click enter) to start monitoring the files.

Few text files and executable files are stored in the specified directory, test_files folder is available use it as test files for performing file monitoring.

After selecting option B, open any file from the specified directory and make changes in the file’s content and save the file. 

You can see the alerts shown on the screen regarding the file changes. 
Also, try creating new file in the specified directory while the system is running and try changing the watermark in the file to see how the system alerts the changes by monitoring files for every 2-3 seconds.
