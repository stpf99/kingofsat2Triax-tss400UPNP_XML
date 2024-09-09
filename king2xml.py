import sys
import os
import requests  # Use the requests library for downloading files
import re

def download_files(position, languages):
    """
    Downloads the channel data files for the specified position and languages.
    """
    for lang in languages:
        url = f"https://de.kingofsat.net/freqs.php?&pos={position}&standard=All&ordre=freq&filtre=Clear&cl={lang}"
        response = requests.get(url)
        if response.status_code == 200:
            with open(f"freqs_{lang}.php", "w", encoding="utf-8") as file:
                file.write(response.text)
            print(f"Downloaded data for language {lang} successfully.")
        else:
            print(f"Failed to download data for language {lang}. Status code: {response.status_code}")

def cleanup_files():
    """
    Removes old files matching specific patterns.
    """
    for filename in os.listdir():
        if filename.endswith(".php") or filename.endswith(".xml") or filename.startswith("freq"):
            os.remove(filename)

def merge_files(output_filename):
    """
    Merges all downloaded PHP files into a single PHP file for processing.
    """
    with open(output_filename, "w", encoding="utf-8") as outfile:
        for filename in os.listdir():
            if filename.startswith("freqs_") and filename.endswith(".php"):
                with open(filename, "r", encoding="utf-8") as infile:
                    outfile.write(infile.read())
    print(f"Merged files into {output_filename}.")

def process_file_with_script(input_filename, output_filename, source):
    """
    Calls the getchannels.py script to process the merged PHP file.
    """
    os.system(f"python getchannels.py newslave {input_filename} {source}")

def post_process_xml(input_filename, output_filename):
    """
    Performs additional processing on the generated XML file to clean up content.
    """
    with open(input_filename, "r", encoding="utf-8") as infile, open(output_filename, "w", encoding="utf-8") as outfile:
        for line in infile:
            # Replace placeholder NR with incremented numbers, remove '&', and adjust case for V/H
            line = re.sub(r"NR", lambda match, count=[0]: str(count[0] + 1), line)  # Increment counter for each match of NR
            line = line.replace("&", "").replace(">V<", ">v<").replace(">H<", ">h<")
            outfile.write(line)

def finalize_xml(output_filename):
    """
    Finalizes the XML output by adding the starting and ending tags.
    """
    STR2 = '<?xml version="1.0" encoding="UTF-8"?><channelTable msys="DVB-S">'
    STR3 = '</channelTable>'
    
    with open(output_filename, "r", encoding="utf-8") as infile:
        content = infile.read()
    
    with open(output_filename, "w", encoding="utf-8") as outfile:
        outfile.write(STR2 + "\n" + content + "\n" + STR3)
    
    print(f"Final XML structure prepared in {output_filename}.")

def main():
    # Check if the correct number of arguments is provided
    if len(sys.argv) < 4:
        print("Usage: python script.py <position> <source> <lang1> <lang2> <lang3> <lang4> ...")
        sys.exit(1)

    # Parameters from the command line
    position = sys.argv[1]  # Satellite position, e.g., '13E'
    source = sys.argv[2]  # Source identifier
    languages = sys.argv[3:]  # List of languages, e.g., 'pol', 'ger', 'ita', 'eng'

    # Create a language suffix to include in the filename
    lang_suffix = '-'.join(languages)  # Combine all language codes with '-'

    # Output file names
    merged_filename = f"tv-{position}-fta-langs.php"
    intermediate_xml_filename = f"tv-{position}-fta-langs.xml"
    final_output_filename = f"TV-{position}-FTA-langs-{lang_suffix}.xml"  # Updated filename to include languages

    # Start of script logic
    cleanup_files()  # Cleanup old files
    download_files(position, languages)  # Download files for specified languages
    merge_files(merged_filename)  # Merge downloaded files into a single PHP file
    process_file_with_script(merged_filename, intermediate_xml_filename, source)  # Process the merged file
    post_process_xml(intermediate_xml_filename, final_output_filename)  # Post-process the XML
    finalize_xml(final_output_filename)  # Add XML header and footer

    # Create output directory and move the file
    output_dir = "ONEPOSMULTILANG/"
    if not os.path.exists(output_dir):
        os.mkdir(output_dir)
    os.rename(final_output_filename, os.path.join(output_dir, final_output_filename))
    print(f"Final XML saved to {output_dir}{final_output_filename}")

    # Cleanup intermediate files
    cleanup_files()
    print("Cleanup completed.")

if __name__ == "__main__":
    main()
