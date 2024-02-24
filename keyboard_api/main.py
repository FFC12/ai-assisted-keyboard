from fastapi import FastAPI, Response
from payload import APIRequest, APIResponse
from middlewares import CommandHandler

app = FastAPI()

@app.post("/api/service")
async def service_dispatcher(request: APIRequest):
    if request.service.lower() == "fix":
        call = CommandHandler() 
        response = call.process_command(request.data)
        return APIResponse(response=str(response))
    else:
        # 400 bad request
        return Response(status_code=400)