

import os
import sys
import time

import pandas as pd
from basic.excel import ExcelCls
from basic.login import LoginCls
import pdfplumber

from basic.pdf import decode_invoice

def read_inoice_no(file_path):
    columns_to_read = [0]  # Change this to your actual column names
    # Read the Excel file and load only the specified columns
    df = pd.read_excel(file_path, usecols=columns_to_read)
    return df

def get_invoice_distinct(df,file_path, save_as:str)->list:
    invoice_list=[]
    i = 0
    while i < len(df):
        pd_values = str(df.values[i][0])
        i = i + 1
        if file_path==save_as:
            invoice_list.append(pd_values)
            continue
        if pd_values.find("VAN")<0:
            continue
        values = pd_values.split("\n")
        for v in values:
            if v.find("VAN")<0:
                continue
            else:
                invalues = v.split(" ")
                for ins in invalues:
                    if ins.find("VAN")>=0 :
                        invoice_no = ins
                        find = False
                        for iv in invoice_list:
                            if iv == invoice_no:
                                find = True
                                break
                        if not find:
                            invoice_list.append(invoice_no)
    # invoice_list.sort()
    if not file_path==save_as :
        df = pd.DataFrame(invoice_list, columns=["Invoice No"])  # The first list is used as column headers
        df.to_excel(save_as, index=False, engine='openpyxl')
    return invoice_list

def init2run(url, username, password, username_id, password_id, login_form_id, login_confirm_element_path):
    file_path = "inv2.xlsx"
    save_as = "inv2.xlsx"
    df = read_inoice_no(file_path=file_path)
    invoice_list = get_invoice_distinct(df,file_path=file_path, save_as = save_as)
    login = LoginCls(login_url=url, user_name=username,password=password, 
                     login_form_id= login_form_id,
                     login_username_element_id=username_id, login_pasword_element_id=password_id,
                     login_confirm_element_path=login_confirm_element_path,output_excel="invoice")
    #locate the menu 
    main_menu = login.locate_main_menu("button","Global navigation bar show/hide")
    # sub_menu = login.expand_menuitems(main_menu,"Accounting")
    # login.find_menu(sub_menu,"Invoice List")
    # login.find_invoice(df.values[0][0])
    try:
        i = 0
        sheetIndex = 0
        contin = True
        while contin:
            if login.invoice_entered:
                while i < len(invoice_list):
                    print(f"reading {invoice_list[i]}")
                    try:
                        # contin1 = login.find_invoice('VAN32926')
                        contin1 = login.find_invoice(invoice_list[i])
                    except Exception as e:
                        print(f"An exception occurred: {e}")
                        contin1 = False
                    if not contin1:
                        print(f'last{i}')
                        login.write2Excel()
                        sheetIndex = sheetIndex + 1
                        login.quit()
                        login = LoginCls(login_url=url, user_name=username,password=password, 
                        login_form_id= login_form_id,
                        login_username_element_id=username_id, login_pasword_element_id=password_id,
                        login_confirm_element_path=login_confirm_element_path,output_excel=f"invoice{sheetIndex}")
                        main_menu = login.locate_main_menu("button","Global navigation bar show/hide")
                    else:
                        i = i + 1
                    time.sleep(3)
                    if i % 10 == 0:
                        time.sleep(10)
                contin = False
            pass
        login.write2Excel()
    except KeyboardInterrupt:
        print("Program stopped by user.")

def pdf2Excel(directory):
    # List all files and directories in the specified directory
    files = os.listdir(directory)
    excel = ExcelCls("invoice")
    # Filter only files (excluding directories)
    for f in files :
        if os.path.isfile(os.path.join(directory, f)) and f.lower().endswith('.pdf'):
            invoice = decode_invoice(os.path.join(directory, f))
            if invoice != None:
                excel.put_invoice2Excel(invoice)
    excel.write2Excel()
def bindAllExcels(count, directory, out_file):
    excel = ExcelCls("")
    excel.bind_excel_together(count=count, file_directory=directory,output_file=out_file)
if __name__ == '__main__':
    current_folder = os.getcwd() 
    # pdf_folder = current_folder + "/pdf"  
    # pdf2Excel(pdf_folder)
    folder = current_folder +"/4"
    bindAllExcels(3, folder,"invoiceout")
    # url = 'http://54.215.241.28:8001/acrocargo/Login.usr'
    # username = 'FA2'
    # password = 'i@m0_0$Sf'
    # username_id = 'login_id'
    # password_id = 'login_pw'
    # # confirm_element_text = 'LOGIN'
    # login_form_id = 'loginForm'
    # login_confirm_element_path = 'fieldset/button'
    # init2run(url, username, password, username_id, password_id,login_form_id,login_confirm_element_path)