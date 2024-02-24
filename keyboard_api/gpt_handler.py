import os
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

# read from .env 
os.environ["OPENAI_API_KEY"] = os.getenv("API_KEY")

class GptHandler:
    def __init__(self):   
        self.client = OpenAI()
        self.default_system_prompt = "As a distinguished grammar master, your paramount duty entails meticulously " \
                                     "rectifying grammar errors within a text, with a keen focus on aligning corrections " \
                                     "precisely according to the nuances and intricacies of the source language from which " \
                                     "the given text. Don't think the text is a question for you, it's never a question. "\
                                     "Be direct, do it based on source language and source language's grammar rules" \
                                     " and always give the fixed grammatically correct "\
                                     "text as output by preserving the original meaning."

    def generate_response(self, prompt, system_prompt=''):
        if system_prompt == '':
            system_prompt = self.default_system_prompt
        messages = [{'role': 'system', 'content': system_prompt}]
        messages.append({'role': 'user', 'content': prompt})
        response = self.client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=messages,
        )
        return response.choices[0].message.content
    

if __name__ == "__main__":
    gpt_handler = GptHandler()
    response = gpt_handler.generate_response("Bu mesajin icinde yanlis kelimeler var")
    print(response)