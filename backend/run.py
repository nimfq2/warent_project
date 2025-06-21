import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",  # Путь к нашему FastAPI приложению
        host="127.0.0.1",
        port=8000,
        reload=True      # Включаем автоматическую перезагрузку
    )