import pandas as pd
def Linea():
    df = pd.read_excel("Data/data.xlsx", sheet_name="Linea")
    print(df)


