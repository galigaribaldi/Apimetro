import requests


headers = {'Content-Type': 'application/x-www-form-urlencoded'}

def get_response():
    ##GET
    data_send = {"idLine":"1"}
    response = requests.request("GET", "http://localhost:5001/stc/linea", headers=headers,params = data_send)

    print(response.json())

def post_respones():
    ##POST
    data_POST = {
    "linea_id": 4,
    "sistema": "STC Metro",
    "anio_inauguracion": 1969,
    "color_en": "ROJINEGRO",
    "color_esp": "ROJINEGRO",
    }

    response = requests.request(
        "POST", 
        "http://localhost:5001/stc/linea", 
        headers = headers,
        json = data_POST,
    )
    print(response.json())

#post_respones()
get_response()