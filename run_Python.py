import os
os.system("antlr4 Python.g4 -o gen")
os.system("javac gen/Python*.java")
os.system("cd gen && grun Python file_input ../testfile.py -tokens")
# os.system("cd gen && grun Python startRule ../testfile.dm -gui")
