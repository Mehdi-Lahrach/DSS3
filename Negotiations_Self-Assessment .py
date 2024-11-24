# List of questions from the table
questions = [
    "1. If the other party’s position seems very important to him or her, I may sacrifice my own position.",
    "2. I address problems and concerns directly without blame or judgment.",
    "3. I try to win by convincing the other party of the logic and benefits of my position.",
    "4. I tell the other person my ideas for and ask for his or hers in return.",
    "5. I try to find a compromise solution.",
    "6. I try to postpone discussions until I have had some time to think.",
    "7. I see achievement as more important than relational issues.",
    "8. I use body language that might be perceived as condescending or arrogant.",
    "9. Confronting someone about a problem is very uncomfortable for me.",
    "10. I give up some points in exchange for others.",
    "11. I propose a middle ground.",
    "12. I am likely to take a comment back or try to soften it if I realize that it hurt someone’s feelings.",
    "13. I think it is all right to ask for what I want or to explain how I feel.",
    "14. I find conflict stressful and will avoid it any way I can.",
    "15. I have been described as impatient, controlling, insensitive or emotionally detached.",
    "16. If asked to do something I don’t agree with or don’t want to do, I’ll do it but deliberately won’t do it as well as I could have.",
    "17. I let my body language communicate my feelings rather than telling people directly how I feel.",
    "18. I remain calm and confident when faced with aggression or criticism.",
    "19. I may overextend myself trying to meet everyone’s needs.",
    "20. I try to find fair combination of gains and losses for both of us.",
    "21. I look for and acknowledge common ground.",
    "22. I have a hard time being clear about what I want and need for fear of appearing demanding or selfish.",
    "23. I can overlook valuable ideas in favor of action.",
    "24. I may not be open to hear other points of view.",
    "25. I avoid taking positions that would create controversy."
]

# Column mapping based on question number
column_mapping = {
    "Avoidance": [6, 14, 16, 17, 25],
    "Aggression": [3, 7, 8, 15, 24],
    "Accommodation": [1, 9, 12, 19, 22],
    "Compromise": [5, 10, 11, 20, 23],
    "Collaboration": [2, 4, 14, 18, 21]
}

# Initialize scores for each column
scores = {"Avoidance": 0, "Aggression": 0, "Accommodation": 0, "Compromise": 0, "Collaboration": 0}

print("Score yourself on each statement on a scale of 0 – 5. \n 0 = never  1 = rarely 2 = sometimes 3 = occasionally 4 = frequently 5 = always\n")

# Loop through each question, ask for user input, and update the scores
for i, question in enumerate(questions, start=1):
    while True:
        try:
            # Display the question and get the user's score
            score = int(input(f"{question} (Enter a score from 0 to 5): "))
            if 0 <= score <= 5:
                break
            else:
                print("Please enter a valid score between 0 and 5.")
        except ValueError:
            print("Invalid input. Please enter an integer between 0 and 5.")

    # Update the scores based on the column mapping
    for column, questions_in_column in column_mapping.items():
        if i in questions_in_column:
            scores[column] += score

# Print the total scores for each column
print("\nTotal Scores:")
for column, total in scores.items():
    print(f"{column}: {total}")
