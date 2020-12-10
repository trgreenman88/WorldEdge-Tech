#Written by Trent Greenman
#This script takes a source file with billing information (source)
#and splits it into several csv files based on each Organization Name for each
#company. It also marks up the unit price and total based on the markup value
#found in the customers file (customers). This is designed to make separating the
#billing for each company much faster and easier.

import csv

###INPUT REQUIRED###
source = "Sherweb-details.csv" 
customers = "CustList.csv"

#opens the source file
with open(source, newline='', mode='r') as orgs:
    orgs_reader = csv.DictReader(orgs)
    orgs_set = set()
    #creates a set or all unique organization names called orgs_set
    for org in orgs_reader:
        orgs_set.add(org["OrganizationName"])
        date = org["InvoicingDate"]

    enddate = ""
    for char in date:
        if char != "/":
            enddate += char
    if len(enddate) < 8:
        enddate = "0" + enddate
            
    headers = ["Invoice Date",
         "Organization Name",
         "Meter",
         "Consumed Quantity",
         "Unit",
         "Unit Price",
         "Total",
         "Currency"]
    for name in orgs_set:
        #Creates a new csv file for each organization in the set
        with open("Azure Details " + name + " For " + enddate + ".csv", 'w') as new_file:
            writer = csv.writer(new_file, lineterminator = '\n')
            #adds the headers to the top of each csv file
            writer.writerow(headers)
            
            ###INPUT REQUIRED###
            with open(source, mode='r') as sourcefile:
                source_reader = csv.DictReader(sourcefile)
                #loops through each row of the source file
                for row1 in source_reader:    

                    if row1["OrganizationName"] == name:
                        
                        ###INPUT REQUIRED###
                        with open(customers, mode='r') as markups:
                            markups_reader = csv.reader(markups)
                            #Find the markup value for the organization
                            for row2 in markups_reader:
                                if row1["OrganizationName"] == row2[0]:
                                    markup = row2[1]
                                    break
                        #Calculates total and unit price after markup
                        revisedUP = (float(markup)*float(row1["UnitPrice"]))+float(row1["UnitPrice"])
                        total = revisedUP*float(row1["Qty"])
                        #creates a line that will be added to the new file
                        line = [row1["InvoicingDate"],
                            row1["OrganizationName"],
                            row1["Category"] + " - " + row1["SubCategory"] + " - " + row1["MeterName"],
                            row1["Qty"],
                            row1["Unit"],
                            revisedUP,
                            total,
                            row1["Currency"]]
                        writer.writerow(line)

print("Operation Successful!")
                

