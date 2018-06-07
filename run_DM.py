import os
os.system("antlr4 DM.g4 -o gen")
os.system("javac gen/DM*.java")
os.system("cd gen && grun DM start ../testfile.dm -tokens")
os.system("cd gen && grun DM start ../testfile.dm -gui")
