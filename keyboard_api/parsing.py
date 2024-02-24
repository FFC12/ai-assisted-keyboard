class Parser:
    def __init__(self):
        pass

    def parse(self, text) -> tuple:
        if "#exec" in text: 
            return self._extract(text, "#exec"), "exec"
        if "#longer" in text:
            return self._extract(text, "#longer"), "longer"
        if "#calc" in text:
            return self._extract(text, "#calc"), "calc"
        else:
            return text, "fix"
        
    def _extract(self, text, command):  
        # find the position of 'command'
        position = text.find(command)

        # remove the 'command' from the text
        extracted_text = ""
        for i,c  in enumerate(text):
            if i < position:
                extracted_text += c
            else:
                pass

        return extracted_text

if __name__ == "__main__":
    exec = Parser()
    text = exec.parse("tests#exec")
    print(text)
    text = exec.parse("tests sdfsdf#longer")
    print(text)
    text = exec.parse("24+5/23#calc")
    print(text)