import pandas as pd
def estacion():
    df = pd.read_excel("Data/data.xlsx", sheet_name="Estacion")
    print(df)

