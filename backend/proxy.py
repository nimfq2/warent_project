import httpx
from fastapi import FastAPI, Request, Response
from fastapi.responses import StreamingResponse

# Этот прокси будет работать на порту 8080
app = FastAPI()

# Адрес нашего настоящего бэкенда
TARGET_HOST = "http://127.0.0.1:8000"

client = httpx.AsyncClient(base_url=TARGET_HOST)

@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"])
async def proxy(request: Request, path: str):
    """
    Эта функция перехватывает ВСЕ запросы и перенаправляет их 
    на наш основной бэкенд, работающий на порту 8000.
    """
    url = httpx.URL(path=request.url.path, query=request.url.query.encode("utf-8"))
    
    # Читаем тело и заголовки из оригинального запроса
    body = await request.body()
    headers = dict(request.headers)
    
    # httpx не любит некоторые заголовки, удаляем их
    headers.pop("host", None)
    headers.pop("content-length", None)
    
    # Отправляем запрос на настоящий бэкенд
    rp_req = client.build_request(
        method=request.method, url=url, headers=headers, content=body
    )
    rp_resp = await client.send(rp_req, stream=True)
    
    # Возвращаем ответ от настоящего бэкенда клиенту
    return StreamingResponse(
        rp_resp.aiter_raw(),
        status_code=rp_resp.status_code,
        headers=rp_resp.headers,
    )

# Запускаем сам прокси, если файл запущен напрямую
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8080)