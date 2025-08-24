import tkinter as tk

def dial():
    print("d")

#def dial(num):
#    print("d" + num)

def resize(e):
    size = e.width / 12
    mmbutton.config(font=("Helvetica", int(size)))

mWindow = tk.Tk()
mWindow.title('Dialing Control')
mWindow.attributes('-zoomed', True)  # This just maximizes it so we can see the window. It's nothing to do with fullscreen.
mWindow.attributes("-fullscreen", True)

# https://www.youtube.com/watch?v=bVnKX0315lo
# https://www.youtube.com/watch?v=rZxOe1kVF8Q

tk.Grid.rowconfigure(mWindow, 0, weight=1)
tk.Grid.columnconfigure(mWindow, 0, weight=1)
mWindow.bind('<Configure>', resize)

# You can set any height and width you want
mmbutton = tk.Button(mWindow, text="Tap here to dial.", command=dial)
mmbutton.grid(row=0, column=0, sticky="nsew")

#mWindow.bind("<Key-space>", dial()) # this does not work, it fires instantly
mWindow.mainloop()
