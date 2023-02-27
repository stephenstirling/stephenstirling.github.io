---
title: Looking at American Life Expectancy with Python and JSON
author: Stephen
layout: post
categories:
  - blog
tags:
  - Python
  - JSON

---
![header](/assets/lifeexpectancy/header%2Bimage.png)

Being a data scientist means being prepared to work with a wide range of data sources. Thus far, I have relied solely on datasets in Excel and CSV formats. In the previous real-world examples, these datasets were easily obtained from online portals. These formats allow for easy access and mutability with Python and can also be read by programs like Tableau. While these formats are preferred for those reasons, I wanted to provide a real-world tutorial using a different format.  

Another format commonly offered by data portals is JavaScript Object Notation or JSON. This format uses JavaScript syntax and is easily parsed by web browsers. While working with Python, JSON offers an effortless approach to transferring data between servers and clients. JSON is especially useful when using real-time or consistently updated data such as currency conversions or weather information. In a real-time scenario, you could access a JSON API from a web server and pull down the latest data as necessary. For this post, I will be demonstrating a basic example using JSON to extract data and then create a simple Tableau visualization. 

I started by browsing the United States government’s Project Open Data catalog. The portal offers a filter for browsing by formats such as CVS, XML, or JSON. There, I found a dataset tracking life expectancy in the U.S.A. since 1900. This particular dataset was available in CSV as well as JSON. I want to note that this file includes additional filter criteria such as gender and ethnicity, however, for the simplicity of this post, I decided to only use the “all genders” and “all ethnicities” categories.  

We are going to start in Jupyter Notebook with the JSON module.

```typescript
import json

from urllib.request import urlopen

with urlopen("https://data.cdc.gov/api/views/w9j2-ggv5/rows.json?accessType=DOWNLOAD") as response: source = response.read()

In the code above, we start by importing the JSON library and then open the link to the dataset in read-only mode. 

data = json.loads(source)

Next, we convert the content of the file from a string to a JSON object. 

print(json.dumps(data, indent = 2))

By passing in the variable “data” from above, we can look at the JSON content in a legible format. From the code above, we can see details about the dataset. The data itself exists at the bottom of the file in a list format. 

age = []

year = []

for item in data["data"]: year.append(item[-5]) age.append(item[-2])

diction = dict(zip(year, age))

with open("years_and_ages.json", "w") as f: json.dump(diction, f, indent=2)
```
I set up the variables “age” and “year” as empty lists because these are the only variables I will be extracting for the visualization. Unfortunately, this dataset does not contain a Python dictionary-like format of keys and values. I, therefore, had to extract the age and year indicators using their index locations from the JSON list. I did this by using a for loop to iterate through all the items and assign the age and year variables to respective lists.

I then saved these two lists to a dictionary in key/value pairings. Finally, I used the JSON dump function to create a new file containing only the age/year dictionary. 

Finally, I simply copied the contents of the new JSON file into two columns in a new Excel spreadsheet. This new file was then read by Tableau Desktop to create the visualization below. 

<div class='tableauPlaceholder' id='viz1677533389441' style='position: relative'><noscript><a href='#'><img alt='Dashboard 1 ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;M3&#47;M3N5B956H&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='path' value='shared&#47;M3N5B956H' /> <param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;M3&#47;M3N5B956H&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /><param name='tabs' value='no' /><param name='filter' value='publish=yes' /><param name='increment_view_count' value='no' /></object></div>                <script type='text/javascript'>                    var divElement = document.getElementById('viz1677533389441');                    var vizElement = divElement.getElementsByTagName('object')[0];                    vizElement.style.width='100%';vizElement.style.height=(divElement.offsetWidth*0.75)+'px';                    var scriptElement = document.createElement('script');                    scriptElement.src = 'https://public.tableau.com/javascripts/api/viz_v1.js';                    vizElement.parentNode.insertBefore(scriptElement, vizElement);                </script>