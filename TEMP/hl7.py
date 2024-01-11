import tkinter as tk
from tkinter import filedialog, messagebox
import pandas as pd
from hl7apy.parser import parse_message

def load_file():
    file_path = filedialog.askopenfilename(filetypes=[("Excel files", "*.xlsx")])
    if file_path:
        try:
            data = pd.read_excel(file_path)
            process_hl7(data, file_path)
        except Exception as e:
            messagebox.showerror("Error", f"An error occurred: {e}")

def process_hl7(data, file_path):
    if "HL7" not in data.columns:
        messagebox.showerror("Error", "No 'HL7' column found in the file.")
        return

    meanings = []
    for hl7_message in data["HL7"]:
        hl7_message = hl7_message.replace('\n', '\r')
        parsed_message = parse_message(hl7_message)
        meanings.append(str(parsed_message))

    data['MEANING'] = meanings
    save_as(data)

def save_as(data):
    file_path = filedialog.asksaveasfilename(defaultextension=".xlsx", filetypes=[("Excel files", "*.xlsx")])
    if file_path:
        try:
            data.to_excel(file_path, index=False)
            messagebox.showinfo("Success", "File saved successfully!")
        except Exception as e:
            messagebox.showerror("Error", f"An error occurred: {e}")

root = tk.Tk()
root.title("HL7 Parser")
root.geometry("300x150")

load_button = tk.Button(root, text="Load Excel File", command=load_file)
load_button.pack(expand=True)

root.mainloop()
