import argparse
import csv
import re
import subprocess
import time

def get_args():
    """get command-line arguments"""

    parser = argparse.ArgumentParser(
        description='Create PGYR10_P063030 CSV Data',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    args = parser.parse_args()
    return args

def create_csv_data():
    print("Downloading raw data")
    subprocess.call("rm -rf /tmp/PGYR19_P012221", shell=True)
    subprocess.call("mkdir -p /tmp/PGYR19_P012221", shell=True)
    subprocess.call("curl https://download.cms.gov/openpayments/PGYR19_P012221.ZIP -o /tmp/PGYR19_P012221/PGYR19_P012221.ZIP", shell=True)
    print("\nUnzipping raw data")
    subprocess.call("unzip /tmp/PGYR19_P012221/PGYR19_P012221.ZIP -d /tmp/PGYR19_P012221", shell=True)

    output_file = '/tmp/PGYR19_P012221/bigdata.csv'
    input_file  = '/tmp/PGYR19_P012221/OP_DTL_GNRL_PGYR2019_P01222021.csv'
    input_file_lines_total = subprocess.check_output("wc -l "+input_file, shell=True)
    input_file_lines_total = int(re.findall(r'^\d+', input_file_lines_total.decode("utf-8"))[0])
    input_file_lines_count = 0
    print("\nCreating csv file")
    print("         Time     Time     Time")
    print("  %     Total    Spent     Left")
    time_start = time.perf_counter()
    percent_complete_prev = -1
    time_total_calc_prev = '--:--:--'
    time_spent_prev = '--:--:--'
    time_left_prev = '--:--:--'
    csv_file_out = open(output_file, mode='w')
    csv_file_in = open(input_file, mode='r')
    csv_reader = csv.reader(csv_file_in, delimiter=',')
    for row in csv_reader:
        row_size = 0
        for element in row:
            row_size += len(element)
        if (input_file_lines_count != 0):
            while ("'" in row[6]):   # Physician_First_Name
                row[6] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[6])

            while (',' in row[6]):   # Physician_First_Name
                row[6] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[6])

            while ("'" in row[7]):   # Physician_Middle_Name
                row[7] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[7])

            while (',' in row[7]):   # Physician_Middle_Name
                row[7] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[7])

            while ("'" in row[8]):   # Physician_Last_Name
                row[8] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[8])

            while (',' in row[8]):  # Physician_Last_Name
                row[8] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[8])

            while ("'" in row[9]):   # Physician_Name_Suffix
                row[9] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[9])

            while (',' in row[9]):  # Physician_Name_Suffix
                row[9] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[9])

            while ("'" in row[10]):   # Recipient_Primary_Business_Street_Address_Line1
                row[10] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[10])

            while ('"' in row[10]):  # Recipient_Primary_Business_Street_Address_Line1
                row[10] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[10])

            while (',' in row[10]):  # Recipient_Primary_Business_Street_Address_Line1
                row[10] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[10])

            while ("'" in row[11]):   # Recipient_Primary_Business_Street_Address_Line2
                row[11] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[11])

            while (',' in row[11]):  # Recipient_Primary_Business_Street_Address_Line2
                row[11] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[11])

            while ("'" in row[12]):   # Recipient_City
                row[12] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[12])

            while (',' in row[12]):  # Recipient_City
                row[12] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[12])

            while ("'" in row[19]):   # Physician_Specialty
                row[19] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[19])

            while (',' in row[19]):  # Physician_Specialty
                row[19] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[19])

            while ("'" in row[25]):   # Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name
                row[25] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[25])

            while (',' in row[25]):  # Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name
                row[25] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[25])

            while ("'" in row[27]):   # Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name
                row[27] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[27])

            while (',' in row[27]):  # Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name
                row[27] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[27])

            row[31] = re.sub(r'^(.*)(/)(.*)(/)(.*$)', r'\5-\1-\3', row[31]) #  Date_of_Payment

            while ("'" in row[33]):   # Form_of_Payment_or_Transfer_of_Value
                row[33] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[33])

            while (',' in row[33]):  # Form_of_Payment_or_Transfer_of_Value
                row[33] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[33])

            while ("'" in row[34]):   # Nature_of_Payment_or_Transfer_of_Value
                row[34] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[34])

            while (',' in row[34]):  # Nature_of_Payment_or_Transfer_of_Value
                row[34] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[34])

            while ("'" in row[35]):   # City_of_Travel
                row[35] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[35])

            while (',' in row[35]):  # City_of_Travel
                row[35] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[35])

            while ("'" in row[37]):   # Country_of_Travel
                row[37] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[37])

            while (',' in row[37]):  # Country_of_Travel
                row[37] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[37])

            while ("'" in row[40]):   # Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value
                row[40] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[40])

            while ('"' in row[40]):  # Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value
                row[40] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[40])

            while (',' in row[40]):  # Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value
                row[40] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[40])

            while ("'" in row[43]):   # Contextual_Information
                row[43] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[43])

            while (',' in row[43]):  # Contextual_Information
                row[43] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[43])

            while ("'" in row[49]):   # Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_1
                row[49] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[49])

            while (',' in row[49]):  # Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_1
                row[49] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[49])

            while ("'" in row[50]):   # Product_Category_or_Therapeutic_Area_1
                row[50] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[50])

            while (',' in row[50]):  # Product_Category_or_Therapeutic_Area_1
                row[50] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[50])

            while ("'" in row[51]):   # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_1
                row[51] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[51])

            while (',' in row[51]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_1
                row[51] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[51])

            while ('"' in row[51]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_1
                row[51] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[51])

            while ("'" in row[52]):   # Associated_Drug_or_Biological_NDC_1
                row[52] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[52])

            while (',' in row[52]):  # Associated_Drug_or_Biological_NDC_1
                row[52] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[52])

            while ("'" in row[54]):   # Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_2
                row[54] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[54])

            while (',' in row[54]):  # Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_2
                row[54] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[54])

            while ("'" in row[55]):   # Product_Category_or_Therapeutic_Area_2
                row[55] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[55])

            while (',' in row[55]):  # Product_Category_or_Therapeutic_Area_2
                row[55] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[55])

            while ("'" in row[56]):   # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_2
                row[56] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[56])

            while (',' in row[56]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_2
                row[56] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[56])

            while ('"' in row[56]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_2
                row[56] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[56])

            while ("'" in row[57]):   # Associated_Drug_or_Biological_NDC_2
                row[57] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[57])

            while (',' in row[57]):  # Associated_Drug_or_Biological_NDC_2
                row[57] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[57])

            while ("'" in row[60]):   # Product_Category_or_Therapeutic_Area_3
                row[60] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[60])

            while (',' in row[60]):  # Product_Category_or_Therapeutic_Area_3
                row[60] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[60])

            while ("'" in row[61]):   # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_3
                row[61] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[61])

            while (',' in row[61]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_3
                row[61] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[61])

            while ('"' in row[61]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_3
                row[61] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[61])

            while ("'" in row[62]):   # Associated_Drug_or_Biological_NDC_3
                row[62] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[62])

            while (',' in row[62]):  # Associated_Drug_or_Biological_NDC_3
                row[62] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[62])

            while ("'" in row[65]):   # Product_Category_or_Therapeutic_Area_4
                row[65] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[65])

            while (',' in row[65]):  # Product_Category_or_Therapeutic_Area_4
                row[65] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[65])

            while ("'" in row[66]):   # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_4
                row[66] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[66])

            while (',' in row[66]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_4
                row[66] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[66])

            while ('"' in row[66]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_4
                row[66] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[66])

            while ("'" in row[67]):   # Associated_Drug_or_Biological_NDC_4
                row[67] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[67])

            while (',' in row[67]):  # Associated_Drug_or_Biological_NDC_4
                row[67] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[67])

            while ("'" in row[70]):   # Product_Category_or_Therapeutic_Area_5
                row[70] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[70])

            while (',' in row[70]):  # Product_Category_or_Therapeutic_Area_5
                row[70] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[70])

            while ("'" in row[71]):   # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_5
                row[71] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[71])

            while (',' in row[71]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_5
                row[71] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[71])

            while ('"' in row[71]):  # Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_5
                row[71] = re.sub(r'^^(.*)(\")(.*$)', r'\1\3', row[71])

            while ("'" in row[72]):   # Associated_Drug_or_Biological_NDC_5
                row[72] = re.sub(r'^(.*)([\'])(.*$)', r'\1\3', row[72])

            while (',' in row[72]):  # Associated_Drug_or_Biological_NDC_5
                row[72] = re.sub(r'^(.*)([,])(.*$)', r'\1\3', row[72])

            row[74] = re.sub(r'^(.*)(/)(.*)(/)(.*$)', r'\5-\1-\3', row[74]) #  Payment_Publication_Date

            outrow = ""
            for i in range(75):
                if (i in [3,5,30,32,45,73]):  #numbers
                    if (len(row[i]) == 0):
                        outrow += "0,"
                    else:
                        outrow += row[i] + ","
                elif (i in [31,74]):    #dates
                    outrow += row[i] + ","
                else:
                    outrow += row[i] + ","

            csv_file_out.write(outrow[:-1]+"\n")

        input_file_lines_count += 1

        percent_complete_now = round(100 * (float(input_file_lines_count)/float(input_file_lines_total)))
        time_now = time.perf_counter()

        time_total_calc = (float(input_file_lines_total)/float(input_file_lines_count)) * (time_now - time_start)
        time_total_calc_now = time.strftime("%H:%M:%S", time.gmtime(time_total_calc))
        time_spent_now = time.strftime("%H:%M:%S", time.gmtime(time_now-time_start))
        time_left_now = time.strftime("%H:%M:%S", time.gmtime(time_total_calc - (time_now-time_start)))

        if ((percent_complete_now != percent_complete_prev) or (time_total_calc_now != time_total_calc_prev) or (time_spent_now != time_spent_prev) or (time_left_now != time_left_prev)):
            print(f"{percent_complete_now:3}  {time_total_calc_now} {time_spent_now} {time_left_now}", end='\r')
            percent_complete_prev = percent_complete_now
            time_total_calc_prev = time_total_calc_now
            time_spent_prev = time_spent_now
            time_left_prev = time_left_now

    print(f"{percent_complete_now:3}  {time_total_calc_now} {time_spent_now} {time_left_now}")
    csv_file_in.close()
    csv_file_out.close()

def main():
    args = get_args()
    create_csv_data()

    quit()

if __name__ == '__main__':
    main()

