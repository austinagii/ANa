import os 
from openai import OpenAI

if __name__ == "__main__":
    client = OpenAI()
    
    # continuously chat with the LLM until the user says "bye"
    while True:
        user_input = input(">> ")
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are ANa, a helpful and kind interactive assistant"},
                {"role": "user", "content": user_input}
            ],
        )
        print("ANa: " + response.choices[0].message.content)
        if user_input.lower() == "bye":
            break
