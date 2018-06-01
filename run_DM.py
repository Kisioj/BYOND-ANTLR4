import os
os.system("antlr4 DM.g4 -o gen")
os.system("javac gen/DM*.java")
os.system("cd gen && grun DM startRule ../testfile.dm -tokens")
# os.system("cd gen && grun DM startRule ../testfile.dm -gui")
