#!/usr/bin/env python3

from tkinter import *
from tkinter import ttk
from tkinter import font
import time
import locale

def quit(*args):
	root.destroy()

def show_time():
	txt.set(time.strftime(" %X\n%x"))
	root.after(1000, show_time)

root = Tk()
root.attributes("-fullscreen", True)
root.configure(background='black')
root.bind("<Escape>", quit)
root.bind("x", quit)
root.after(1000, show_time)

fnt = font.Font(family='Courier', size=60, weight='bold')
txt = StringVar()
locale.setlocale(locale.LC_TIME, "de_DE.UTF-8")
txt.set(time.strftime("Init ..."))
lbl = ttk.Label(root, textvariable=txt, font=fnt, foreground="white", background="black")
lbl.place(relx=0.5, rely=0.5, anchor=CENTER)

root.mainloop()
