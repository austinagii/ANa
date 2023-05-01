import os 
import openai

if __name__ == "__main__":
    openai.api_key = os.getenv("OPENAI_API_KEY")
    # continuously chat with the LLM until the user says "bye"
    while True:
        user_input = input(">> ")
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are Automic, a helpful and kind interactive assistant"},
                {"role": "user", "content": user_input}
            ],
        )
        print(response.choices[0].message.content)
        if user_input.lower() == "bye":
            break