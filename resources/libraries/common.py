"""A library for custom keywords
"""
import json
import re

def defineVariablesFromJsonFile(env):
    print(f'Looking for {env} environment')
    variables = {}
    environments_file_path = 'resources/environments/environments_' + env + '.json'
    try:
        with open(environments_file_path) as json_file:
            data = json.loads(json_file.read())
            if data["environment"] == env:
                print(f'Found an environment {env}!')
            for key, value in data.items():
                if type(value) == dict:
                    for key, value in value.items():
                        if key not in variables:
                            variables[key] = value
                elif type(value) == str:
                    if key not in variables:
                            variables[key] = value
    except:
        print(f'Failed loading data for {env} environment!')
    return variables
