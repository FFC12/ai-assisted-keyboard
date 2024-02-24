from pydantic import BaseModel

# Pydantic model for request data
class APIRequest(BaseModel):
    data: str
    service: str

# Pydantic model for response data
class APIResponse(BaseModel):
    response: str 