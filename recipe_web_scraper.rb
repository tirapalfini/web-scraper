# Web Scraper for Recipes Website
# Note: Permission from website owner was obtained prior to 
# creating web scraper program to collect data for a class project. 
# The url has been since been removed.

require 'nokogiri'
require 'open-uri'
require 'csv'

#Arrays to store information
docs = []
paths = []
recipe = []
instructions = []
ingred = []
ingredients = []
pics = []
ing = {}
rec = {}

#Remove Price from Ingredients
def convertIngredient(string)
    if string.include?("$")
         return string[0,string.index("$")]
    end
    return string
end

#Parse Amount from Ingredients
def amountIngredient(string)
    if string.include?(" ")
        substring = string[0,string.index(" ")]
        if substring =~ /^[^a-zA-Z].*/
            return substring
        end
        return
    end
    return string
end

#Parse Units from Ingredients
def unitsIngredient(string)
    unit = case string
            when /Tbsp/ then 'Tbsp'
            when /cups/ then 'cups'
            when /cup/ then 'cup'
            when /cloves/ then 'cloves'
            when /tsp/ then 'tsp'
            when /links/ then 'links'
            when /cans/ then 'cans'
            when /can/ then 'can'
            when /medium/ then ''
            when /oz./ then 'oz.'
            when /lb./ then 'lb.'
            when /bag/ then 'bag'
            when /bunch/ then 'bunch'
            else ' '
    end
    return unit
end

#Parse Units from Ingredients
def parsedIngredient(string)
    unit = case string
            when /Tbsp/ then 'Tbsp'
            when /cups/ then 'cups'
            when /cup/ then 'cup'
            when /cloves/ then 'cloves'
            when /tsp/ then 'tsp'
            when /links/ then 'links'
            when /cans/ then 'cans'
            when /can/ then 'can'
            when /medium/ then ' '
            when /oz./ then 'oz.'
            when /lb./ then 'lb.'
            when /bag/ then 'bag'
            when /bunch/ then 'bunch'
            else ' '
    end
    substring = string
    if (unit != ' ')
        substring = string.split(unit)[1]
    else 
        substring = string[string.index(" "), string.length]
    end
    return substring
end

recipeID = 1
ingredientID = 1

#Fetch and Parse HTML document
for i in 1 ...3
    docs << "http://www..com/2015/0#{i}/"
end
 
for doc in docs
    doc = Nokogiri::HTML(open("#{doc}"))
    doc.css("h2.entry-title a").each do |link|
         paths << link['href']
    end
end

#doc = Nokogiri::HTML(open("http://www..com/2016/09/"))

#DEBUGGING
#Show all a tags within h2 tags with class="entry-title"
#puts doc.css("h2.entry-title a")
#path = doc.css("h2.entry-title a")[0]['href']
# #Access description of the first item for sale with at_css
#recipePage = Nokogiri::HTML(open("#{path}"))

#Get recipe sites
for path in paths do
    recipePage = Nokogiri::HTML(open("#{path}"))
    
    #Recipe Data
    title = recipePage.css("h1")[0].text
    rec[title] = recipeID
    recipeID = recipeID + 1
    
    image = recipePage.css("div.entry-content p img")[0]
    image = image.to_s
    img1 = image.split("alt=")[0]
    img2 = img1.split("src=\"")[1]
    image = img2
    
    if recipePage.css("div.ERSServes span").text
        serv = recipePage.css("div.ERSServes span").text
    else 
        serve = ""
    end    
    if recipePage.css("div.ERSTimeItem")[0]
        prep = recipePage.css("div.ERSTimeItem")[0].text
    else
        prep = ""
    end
    
    if recipePage.css("div.ERSTimeItem")[1]
        cook = recipePage.css("div.ERSTimeItem")[1].text
    else
        cook = ""
    end
    
    #Recipe array
    recipe << "#{rec[title]}\t#{title}\t#{serv}\t#{prep}\t#{cook}\tBeth Moncel"
    
    # Instructions array
    stepNumber = 1
    recipePage.css("ol li.instruction").each do |step| 
        instructions << "#{rec[title]}\t#{stepNumber}\t" + step.text
        stepNumber = stepNumber + 1
    end
    
    
    #Ingred and Ingredients arrays
    recipePage.css("ul li.ingredient").each do |item|
        convertedItem = convertIngredient(item.text)
        amount = amountIngredient(convertedItem)
        unit = unitsIngredient(convertedItem)
        ingredient = parsedIngredient(convertedItem)
    
        isFound = false
        if ingredient != nil
            ingredientArray = ing.keys
            for item in ingredientArray
                if item != nil
                    if item.include? ingredient
                        isFound = true
                        ingredient = item
                    end
                end
            end
        end    
        if isFound == false
            ing[ingredient] = ingredientID
            ingredients << "#{ing[ingredient]}\t#{ingredient}"
            ingredientID = ingredientID + 1
        end
        if isFound == true
        end
        ingred << "#{rec[title]}\t#{ing[ingredient]}\t#{amount}\t#{unit}"
    end

    #Pics array
    pics << "#{rec[title]}\t#{image}"

end


#Step file
fname = "steps.txt"
file = File.open(fname, "w")
    instructions.each do |item|
        file.puts "#{item}"
end
file.close

#Ingredients_recipe file
fname2 = "recipe_ingredient.txt"
file = File.open(fname2, "w")
    #ingredients.each do |item|
    ingred.each do |item|
    file.puts "#{item}"
end
file.close

#Ingredients file
fname3 = "ingredients.txt"
file3 = File.open(fname3, "w")
    ingredients.each do |item|
        file3.puts "#{item}"
    end
file3.close

#Photo file
fname4 = "photo.txt"
file4 = File.open(fname4, "w")
    pics.each do |item|
        file4.puts "#{item}"
    end
file4.close

#Recipe file
fname5 = "recipe.txt"
file5 = File.open(fname5, "w")
    recipe.each do |item|
        file5.puts "#{item}"
    end
file5.close