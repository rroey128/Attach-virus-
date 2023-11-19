<h1>Attach virus program</h1>

<h2>Description</h2>
Many computer viruses attach themselves to executable files that may be part of legitimate programs. If a user attempts to launch an infected program, the virus code is executed before the infected program code. This project consists of a program that attaches its own code at the end of files in the current directory.
The C program uses sys_getdents in order to get all the entries in a current directory and print them, and when the -a{prefix} argument is provided it calls an assembly function that will attach the executable code to the desired files.
<br />


<h2>Languages and Utilities Used</h2>

- <b>C</b> 
- <b>Assembly</b>
- <b>System calls</b>
- <b>Memory management and low-level programming principles</b>

<h2>Environments Used </h2>

- <b>Linux Ubuntu 20.04 LTS</b> 
