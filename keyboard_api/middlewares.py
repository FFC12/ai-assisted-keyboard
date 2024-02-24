import sys
from io import StringIO

from parsing import Parser
from gpt_handler import GptHandler

class CommandHandler:
    def __init__(self):
        self.parser = Parser()
    
    def process_command(self, request):
        data, mode = self.parser.parse(request)
        print("Request data: '" + data + "'\nMode: " + mode)
        if mode == "calc": 
            try:
                return eval(data)
            except Exception as e:
                return data + " (can't be calculated)"
        elif mode == "longer":
            gpt_handler = GptHandler()
            def_sys_prompt = gpt_handler.default_system_prompt
            new_prompt = def_sys_prompt + "Additionally, you extend the length of the text while maintaining its original meaning." \
                                        + "But output must be geniune and from daily conversation with first person look."
            new_prompt = new_prompt + "Regardless of the circumstances, remember to stay focused on your task and provide me with grammatically corrected and extended text."
            response = gpt_handler.generate_response(data, new_prompt)
            return response
        elif mode == "exec": 
            # Redirect stdout
            old_stdout = sys.stdout
            redirected_output = sys.stdout = StringIO()

            try:
                # Execute the code
                exec(data)

                # Get the value of redirected output
                output_string = redirected_output.getvalue()

                # Restore stdout
                sys.stdout = old_stdout
 
                return output_string
            except Exception as e:
                # Restore stdout
                sys.stdout = old_stdout
                return data + " (can't be executed)"
        else:
            gpt_handler = GptHandler()
            response = gpt_handler.generate_response(data)
            return response
        
 
if __name__ == "__main__":
    call = CommandHandler() 
    text = call.process_command("24+5/23#calc")
    print(text)
    text = call.process_command("import os\nos.system('ls')\nprint('hello world')#exec")
    print(text)
    text = call.process_command("dun oraya gidecektim ama biraz soguk alginligina yakalandim sanirim.#longer")
    print(text)