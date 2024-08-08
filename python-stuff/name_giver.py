import re
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize

nltk.download('punkt', quiet=True)
nltk.download('stopwords', quiet=True)

def suggest_variable_name(label, current_name):
    stop_words = set(stopwords.words('english'))
    
    # Clean and tokenize the label
    label = re.sub(r'[^\w\s]', '', label.lower())
    tokens = word_tokenize(label)
    
    # Remove stop words
    tokens = [word for word in tokens if word not in stop_words]
    
    # Create abbreviation from label
    label_abbr = ''.join([word[0] for word in tokens])
    
    # Clean current name
    current_name = current_name.lower()
    current_parts = re.findall(r'\w+', current_name)
    
    suggestions = [current_name]  # Start with the current name as first suggestion
    
    # If current name is an abbreviation, offer full words version
    if len(current_name) <= 5 and all(len(part) <= 3 for part in current_parts):
        full_words = '_'.join(tokens[:3])  # Use up to first 3 words
        if full_words != current_name:
            suggestions.append(full_words)
    
    # If current name is long, offer abbreviated version
    elif len(current_name) > 10:
        abbr = ''.join([part[0] for part in current_parts])
        if abbr != current_name and len(abbr) >= 3:
            suggestions.append(abbr)
    
    # If label abbreviation is different and meaningful, offer it
    if label_abbr != current_name and len(label_abbr) >= 3:
        suggestions.append(label_abbr)
    
    # Remove duplicates and limit to 3 suggestions
    suggestions = list(dict.fromkeys(suggestions))[:3]
    
    return suggestions

def main():
    print("Intelligent Variable Name Suggester")
    print("Enter 'quit' to exit the program.")
    
    while True:
        label = input("\nEnter variable label: ")
        if label.lower() == 'quit':
            break
        
        current_name = input("Enter current variable name: ")
        if current_name.lower() == 'quit':
            break
        
        suggestions = suggest_variable_name(label, current_name)
        
        print("\nSuggested variable names:")
        for i, suggestion in enumerate(suggestions, 1):
            print(f"{i}. {suggestion}")
        
        if len(suggestions) == 1:
            print("The current name seems optimal.")

if __name__ == "__main__":
    main()